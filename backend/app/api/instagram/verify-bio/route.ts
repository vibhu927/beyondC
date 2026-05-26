import { NextRequest, NextResponse } from 'next/server'
import { createClient, createAdminClient } from '@/lib/supabase/server'
import { getCachedStats, setCachedStats } from '@/lib/scraping/rate-limiter'
import { withRetry } from '@/lib/scraping/retry'
import { checkInstagramNotClaimed } from '@/lib/instagram/helpers'
import type { InstagramStats } from '@/lib/scraping/instagram-scraper'

type VerifyBody = {
  username?: string
}

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const admin = createAdminClient()

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const {
      data: profile,
      error: profileError,
    } = await admin
      .from('creator_profiles')
      .select('instagram_verification_code, instagram_verified')
      .eq('id', user.id)
      .maybeSingle()

    if (profileError) {
      console.error('[verify-bio] Supabase profile query error:', profileError)
      return NextResponse.json(
        { verified: false, error: 'Database error while looking up profile.' },
        { status: 500 }
      )
    }

    if (!profile) {
      return NextResponse.json(
        { verified: false, error: 'Creator profile not found. Please complete your creator setup first.' },
        { status: 404 }
      )
    }

    if (profile.instagram_verified) {
      return NextResponse.json({ verified: true })
    }

    const storedCode = profile.instagram_verification_code
    if (!storedCode) {
      return NextResponse.json(
        { verified: false, error: 'No verification code found. Please tap "Generate Code" first.' },
        { status: 400 }
      )
    }

    const body = (await request.json()) as VerifyBody
    const username = body.username?.trim().replace(/^@+/, '')

    if (!username) {
      return NextResponse.json({ error: 'Username is required' }, { status: 400 })
    }

    let stats: InstagramStats
    try {
      stats = getCachedStats<InstagramStats>(username)
      if (!stats) {
        const { scrapeInstagramProfile } = await import('@/lib/scraping/instagram-scraper')
        stats = await withRetry(() => scrapeInstagramProfile(username), 3, 2000)
        setCachedStats(username, stats)
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Scrape failed'
      console.error('[verify-bio] Instagram scrape failed:', message)
      return NextResponse.json(
        {
          verified: false,
          error:
            'Could not verify your Instagram profile. This usually happens when Instagram blocks automated requests. Please try connecting via the main "Connect Instagram" option instead.',
        },
        { status: 502 }
      )
    }

    if (stats.is_private) {
      return NextResponse.json(
        {
          verified: false,
          error:
            'Your Instagram account is private. Please make it public, add the code to your bio, and try again.',
        },
        { status: 400 }
      )
    }

    const bioContainsCode = stats.bio?.includes(storedCode) ?? false

    if (!bioContainsCode) {
      return NextResponse.json(
        {
          verified: false,
          error:
            "Verification code not found in your bio. Make sure you've copied the code exactly and saved your Instagram bio.",
        },
        { status: 400 }
      )
    }

    const claimedError = await checkInstagramNotClaimed(admin, username, user.id)
    if (claimedError) {
      return NextResponse.json({ verified: false, error: claimedError }, { status: 409 })
    }

    const { error: updateError } = await admin
      .from('creator_profiles')
      .update({
        instagram_username: username,
        instagram_verified: true,
        instagram_oauth_token: null,
        instagram_user_id: null,
        instagram_connected_at: new Date().toISOString(),
        instagram_verification_code: null,
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
      .eq('id', user.id)

    if (updateError) {
      console.error('[verify-bio] Failed to update creator profile:', updateError)
      return NextResponse.json(
        { verified: false, error: 'Failed to save verification. Please try again.' },
        { status: 500 }
      )
    }

    const { data: profileRow } = await admin
      .from('profiles')
      .select('avatar_url')
      .eq('id', user.id)
      .maybeSingle()

    if (!profileRow?.avatar_url && stats.profile_pic_url) {
      await admin
        .from('profiles')
        .update({ avatar_url: stats.profile_pic_url })
        .eq('id', user.id)
    }

    return NextResponse.json({ verified: true, username })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Verification failed'
    console.error('[verify-bio] Unexpected error:', error)
    return NextResponse.json({ verified: false, error: message }, { status: 500 })
  }
}
