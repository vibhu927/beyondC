import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const niche = searchParams.get('niche')
    const platform = searchParams.get('platform')
    const min_followers = searchParams.get('min_followers')
    const max_followers = searchParams.get('max_followers')
    const tier = searchParams.get('tier')
    const page = parseInt(searchParams.get('page') || '1')
    const limit = Math.min(parseInt(searchParams.get('limit') || '20'), 50)
    const offset = (page - 1) * limit

    // Use privacy view for creator discovery
    let query = supabase
      .from('creator_discovery_view')
      .select('*', { count: 'exact' })

    // Apply filters
    if (niche) {
      query = query.contains('niche', [niche])
    }
    if (platform) {
      query = query.contains('platforms', [platform])
    }
    if (tier && ['nano', 'micro', 'mid', 'macro', 'mega'].includes(tier)) {
      query = query.eq('tier', tier)
    }
    if (min_followers) {
      query = query.gte('followers_count', parseInt(min_followers))
    }
    if (max_followers) {
      query = query.lte('followers_count', parseInt(max_followers))
    }

    // Apply pagination
    query = query
      .order('followers_count', { ascending: false })
      .range(offset, offset + limit - 1)

    const { data: creators, error, count } = await query

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({
      creators,
      pagination: {
        page,
        limit,
        total: count || 0,
        total_pages: Math.ceil((count || 0) / limit),
      },
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
