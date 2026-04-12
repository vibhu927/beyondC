import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase/server'
import { getCachedStats, setCachedStats } from '@/lib/scraping/rate-limiter'
import { withRetry } from '@/lib/scraping/retry'
import type { InstagramStats } from '@/lib/scraping/instagram-scraper'

export const runtime = 'nodejs'

const INTERNAL_SECRET = process.env.INTERNAL_API_SECRET

type ScrapeBody = {
  userId?: string
  username?: string
}

export async function POST(request: NextRequest) {
  const authHeader = request.headers.get('x-internal-secret')

  if (!INTERNAL_SECRET || authHeader !== INTERNAL_SECRET) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }

  const body = (await request.json()) as ScrapeBody
  const userId = body.userId?.trim()
  const username = body.username?.trim().replace(/^@+/, '')

  if (!userId || !username) {
    return NextResponse.json({ error: 'userId and username required' }, { status: 400 })
  }

  const supabase = createAdminClient()

  try {
    let stats = getCachedStats<InstagramStats>(username)

    if (!stats) {
      const { scrapeInstagramProfile } = await import('@/lib/scraping/instagram-scraper')
      stats = await withRetry(() => scrapeInstagramProfile(username), 3, 2000)
      setCachedStats(username, stats)
    }

    if (stats.is_private) {
      await supabase
        .from('creator_profiles')
        .update({
          instagram_username: null,
          instagram_verified: false,
          instagram_oauth_token: null,
          instagram_user_id: null,
          instagram_connected_at: null,
          is_discoverable: false,
        })
        .eq('id', userId)

      return NextResponse.json(
        {
          success: false,
          error_code: 'ACCOUNT_PRIVATE',
          error:
            'Oops! Your Instagram account is private. Please make it public and connect again to verify your profile.',
        },
        { status: 400 }
      )
    }

    await supabase
      .from('creator_profiles')
      .update({
        instagram_username: username,
        instagram_verified: true,
        instagram_connected_at: new Date().toISOString(),
        is_discoverable: true,
        followers_count: stats.followers_count,
        follower_count: stats.followers_count,
        following_count: stats.following_count,
        posts_count: stats.posts_count,
        engagement_rate: stats.engagement_rate,
        highest_video_views: stats.highest_video_views,
        avg_video_views: stats.avg_video_views,
        avg_likes: stats.avg_likes,
        avg_comments: stats.avg_comments,
        stats_fetched_at: new Date().toISOString(),
      })
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

    return NextResponse.json({ success: true, stats })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Unknown scrape failure'
    console.error(`Scrape failed for @${username}: ${message}`)

    await supabase
      .from('creator_profiles')
      .update({
        instagram_verified: true,
        is_discoverable: true,
        stats_fetched_at: new Date().toISOString(),
      })
      .eq('id', userId)

    return NextResponse.json(
      {
        success: false,
        error: 'Could not fetch stats - account verified but stats unavailable',
      },
      { status: 206 }
    )
  }
}
