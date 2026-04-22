import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'agency') {
      return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })
    }

    const { searchParams } = new URL(request.url)
    const niche = searchParams.get('niche')
    const platform = searchParams.get('platform')
    const min_followers = searchParams.get('min_followers')
    const max_followers = searchParams.get('max_followers')
    const tier = searchParams.get('tier')
    const state = searchParams.get('state')
    const city = searchParams.get('city')
    const page = parseInt(searchParams.get('page') || '1')
    const limit = Math.min(parseInt(searchParams.get('limit') || '20'), 50)
    const offset = (page - 1) * limit

    const runViewQuery = async (followersColumn: 'followers_count' | 'follower_count') => {
      let query = supabase
        .from('creator_discovery_view')
        .select('*', { count: 'exact' })

      if (niche) query = query.contains('niche', [niche])
      if (platform) query = query.contains('platforms', [platform])
      if (tier && ['nano', 'micro', 'mid', 'macro', 'mega'].includes(tier)) query = query.eq('tier', tier)
      if (min_followers) query = query.gte(followersColumn, parseInt(min_followers))
      if (max_followers) query = query.lte(followersColumn, parseInt(max_followers))
      if (state) query = query.eq('state', state)
      if (city) query = query.eq('city', city)

      query = query.order(followersColumn, { ascending: false }).range(offset, offset + limit - 1)
      return query
    }

    const primary = await runViewQuery('followers_count')
    if (!primary.error) {
      return NextResponse.json({ creators: primary.data, pagination: { page, limit, total: primary.count || 0, total_pages: Math.ceil((primary.count || 0)/limit) } })
    }

    // Fallback to direct table if view unsupported
    const fallback = await runViewQuery('follower_count')
    if (fallback.error) {
      return NextResponse.json({ error: fallback.error.message }, { status: 400 })
    }

    return NextResponse.json({ creators: fallback.data, pagination: { page, limit, total: fallback.count || 0, total_pages: Math.ceil((fallback.count || 0)/limit) } })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
