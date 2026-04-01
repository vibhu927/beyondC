import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const { data: profile } = await supabase
      .from('creator_profiles')
      .select('instagram_username, stats_fetched_at, instagram_verified')
      .eq('id', user.id)
      .maybeSingle()

    if (!profile?.instagram_verified || !profile.instagram_username) {
      return NextResponse.json({ error: 'Instagram not connected' }, { status: 400 })
    }

    const lastFetch = profile.stats_fetched_at ? new Date(profile.stats_fetched_at) : null
    const hoursSinceFetch = lastFetch ? (Date.now() - lastFetch.getTime()) / (1000 * 60 * 60) : 999

    if (hoursSinceFetch < 24) {
      return NextResponse.json(
        {
          error: `Stats can be refreshed after ${Math.ceil(24 - hoursSinceFetch)} hours`,
        },
        { status: 429 }
      )
    }

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || request.nextUrl.origin
    const internalSecret = process.env.INTERNAL_API_SECRET
    if (!internalSecret) {
      return NextResponse.json({ error: 'INTERNAL_API_SECRET is not configured' }, { status: 500 })
    }

    const scrapeUrl = new URL('/api/instagram/scrape', appUrl)

    const triggerResponse = await fetch(scrapeUrl.toString(), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-internal-secret': internalSecret,
      },
      body: JSON.stringify({
        userId: user.id,
        username: profile.instagram_username,
      }),
    })

    if (!triggerResponse.ok) {
      const result = await triggerResponse.json().catch(() => ({ error: 'Could not start stats refresh' }))
      return NextResponse.json(result, { status: triggerResponse.status })
    }

    const result = await triggerResponse.json().catch(() => ({ success: true }))
    return NextResponse.json({ success: true, message: 'Stats refresh started', ...result })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Could not refresh stats'
    return NextResponse.json({ error: message }, { status: 500 })
  }
}
