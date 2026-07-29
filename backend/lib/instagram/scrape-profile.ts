import { createAdminClient } from '@/lib/supabase/server'
import { getCachedStats, setCachedStats } from '@/lib/scraping/rate-limiter'
import { withRetry } from '@/lib/scraping/retry'
import { checkInstagramNotClaimed } from '@/lib/instagram/helpers'
import type { InstagramStats } from '@/lib/scraping/instagram-scraper'

export type ScrapeProfileResult = {
  success: boolean
  stats?: InstagramStats
  error?: string
  error_code?: string
  statusCode?: number
}

export async function scrapeAndUpdateProfile(
  userId: string,
  username: string,
  role: string = 'creator'
): Promise<ScrapeProfileResult> {
  const supabase = createAdminClient()
  const targetTable = role === 'brand' ? 'brand_profiles' : 'creator_profiles'

  try {
    let stats = getCachedStats<InstagramStats>(username)

    if (!stats) {
      const { scrapeInstagramProfile } = await import('@/lib/scraping/instagram-scraper')
      stats = await withRetry(() => scrapeInstagramProfile(username), 3, 2000)
      setCachedStats(username, stats)
    }

    if (stats.is_private) {
      await supabase
        .from(targetTable)
        .update({
          instagram_username: null,
          instagram_verified: false,
          instagram_oauth_token: null,
          instagram_user_id: null,
          instagram_connected_at: null,
          is_discoverable: role === 'creator' ? false : undefined,
        })
        .eq('id', userId)

      return {
        success: false,
        error_code: 'ACCOUNT_PRIVATE',
        error:
          'Oops! Your Instagram account is private. Please make it public and connect again to verify your profile.',
        statusCode: 400,
      }
    }

    const claimedError = await checkInstagramNotClaimed(supabase, username, userId)
    if (claimedError) {
      return { success: false, error: claimedError, statusCode: 409 }
    }

    const updateData: Record<string, unknown> = {
      instagram_username: username,
      instagram_verified: true,
      instagram_connected_at: new Date().toISOString(),
      stats_fetched_at: new Date().toISOString(),
    }

    if (role === 'creator') {
      updateData.is_discoverable = true
    }

    if (stats.followers_count != null) {
      updateData.followers_count = stats.followers_count
      if (role === 'creator') updateData.follower_count = stats.followers_count
    }
    if (stats.following_count != null) updateData.following_count = stats.following_count
    if (stats.posts_count != null) updateData.posts_count = stats.posts_count
    if (stats.engagement_rate != null) updateData.engagement_rate = stats.engagement_rate
    if (stats.highest_video_views != null) updateData.highest_video_views = stats.highest_video_views
    if (stats.avg_video_views != null) updateData.avg_video_views = stats.avg_video_views
    if (stats.avg_likes != null) updateData.avg_likes = stats.avg_likes
    if (stats.avg_comments != null) updateData.avg_comments = stats.avg_comments

    await supabase
      .from(targetTable)
      .update(updateData)
      .eq('id', userId)

    const { data: profile } = await supabase
      .from('profiles')
      .select('avatar_url')
      .eq('id', userId)
      .maybeSingle()

    if (!profile?.avatar_url && stats.profile_pic_url) {
      await supabase
        .from('profiles')
        .update({ avatar_url: stats.profile_pic_url })
        .eq('id', userId)
    }

    return { success: true, stats }
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown scrape failure'
    console.error(`Scrape failed for @${username}: ${message}`)

    const errClaimedError = await checkInstagramNotClaimed(supabase, username, userId)
    if (errClaimedError) {
      return { success: false, error: errClaimedError, statusCode: 409 }
    }

    const errorUpdate: Record<string, unknown> = { instagram_verified: true }
    if (role === 'creator') errorUpdate.is_discoverable = true

    await supabase
      .from(targetTable)
      .update(errorUpdate)
      .eq('id', userId)

    return {
      success: false,
      error: 'Could not fetch stats - account verified but stats unavailable',
      statusCode: 206,
    }
  }
}
