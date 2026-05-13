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
    const brand_category = searchParams.get('brand_category')
    const size = searchParams.get('size')
    const state = searchParams.get('state')
    const city = searchParams.get('city')
    const page = parseInt(searchParams.get('page') || '1')
    const limit = Math.min(parseInt(searchParams.get('limit') || '20'), 50)
    const offset = (page - 1) * limit

    let query = supabase
      .from('brand_profiles')
      .select(`
        id,
        brand_name,
        brand_category,
        brand_tagline,
        description,
        logo_url,
        website,
        instagram_handle,
        size,
        total_campaigns,
        active_campaigns,
        avg_rating,
        profile:profiles!inner (
          id,
          first_name,
          avatar_url,
          state,
          city,
          is_onboarded
        )
      `, { count: 'exact' })

    if (brand_category) query = query.eq('brand_category', brand_category)
    if (size && ['startup', 'small', 'medium', 'enterprise'].includes(size)) query = query.eq('size', size)
    if (state) query = query.eq('profile.state', state)
    if (city) query = query.eq('profile.city', city)

    query = query.order('total_campaigns', { ascending: false }).range(offset, offset + limit - 1)

    const { data: brands, error, count } = await query

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    // Filter to show any brand with a profile (not just onboarded)
    const filteredBrands = brands?.filter((b: any) => b.profile?.id) ?? []
    const filteredCount = count != null ? (brands?.length ?? 0) : null

    const normalized = (filteredBrands).map((item: any) => {
      const profile = item.profile ?? {}
      return {
        id: item.id,
        brand_name: item.brand_name ?? profile.first_name ?? 'Brand',
        brand_category: item.brand_category ?? null,
        brand_tagline: item.brand_tagline ?? null,
        description: item.description ?? null,
        logo_url: item.logo_url ?? profile.avatar_url ?? null,
        website: item.website ?? null,
        instagram_handle: item.instagram_handle ?? null,
        size: item.size ?? null,
        total_campaigns: item.total_campaigns ?? 0,
        active_campaigns: item.active_campaigns ?? 0,
        avg_rating: item.avg_rating ?? 0,
        state: profile.state ?? null,
        city: profile.city ?? null,
      }
    })

    return NextResponse.json({
      brands: normalized,
      pagination: {
        page,
        limit,
        total: filteredCount ?? normalized.length,
        total_pages: Math.ceil((filteredCount ?? normalized.length) / limit),
      },
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
