import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()
    const { searchParams } = new URL(request.url)

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Parse query params
    const niche = searchParams.get('niche')
    const collab_type = searchParams.get('collab_type')
    const budget_min = searchParams.get('budget_min')
    const budget_max = searchParams.get('budget_max')
    const state = searchParams.get('state')
    const city = searchParams.get('city')
    const includePanIndia = searchParams.get('include_pan_india') !== 'false'
    const page = parseInt(searchParams.get('page') || '1')
    const limit = parseInt(searchParams.get('limit') || '20')
    const offset = (page - 1) * limit

    // Build query
    let query = supabase
      .from('campaigns')
      .select(`
        *,
        brand:brand_profiles!campaigns_brand_id_fkey (
          brand_name,
          brand_category,
          logo_url,
          avg_rating
        ),
        bid_count:bids(count)
      `, { count: 'exact' })
      .eq('status', 'active')

    // Apply filters
    if (niche) {
      query = query.contains('niche', [niche])
    }
    if (collab_type) {
      query = query.eq('collab_type', collab_type)
    }
    if (budget_min) {
      query = query.gte('budget_max', parseInt(budget_min))
    }
    if (budget_max) {
      query = query.lte('budget_min', parseInt(budget_max))
    }

    if (state) {
      if (includePanIndia) {
        query = query.or(`target_state.eq.${state},target_state.is.null`)
      } else {
        query = query.eq('target_state', state)
      }
    }

    if (city) {
      if (includePanIndia) {
        query = query.or(`target_city.eq.${city},target_city.is.null`)
      } else {
        query = query.eq('target_city', city)
      }
    }

    // Apply pagination and ordering
    const { data, error, count } = await query
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({
      campaigns: data,
      pagination: {
        page,
        limit,
        total: count || 0,
        totalPages: Math.ceil((count || 0) / limit),
      },
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
