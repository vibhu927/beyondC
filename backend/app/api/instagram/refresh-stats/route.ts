import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { scrapeAndUpdateProfile } from '@/lib/instagram/scrape-profile'

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

    const { data: userRecord } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .in('role', ['creator', 'brand'])
      .maybeSingle()

    if (!userRecord) {
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 })
    }

    const userRole = userRecord.role
    const targetTable = userRole === 'brand' ? 'brand_profiles' : 'creator_profiles'

    const { data: profile } = await supabase
      .from(targetTable)
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

    const result = await scrapeAndUpdateProfile(user.id, profile.instagram_username, userRole)

    if (!result.success) {
      return NextResponse.json(
        { error: result.error },
        { status: result.statusCode ?? 400 }
      )
    }

    return NextResponse.json({ success: true, message: 'Stats refreshed successfully' })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Could not refresh stats'
    return NextResponse.json({ error: message }, { status: 500 })
  }
}
