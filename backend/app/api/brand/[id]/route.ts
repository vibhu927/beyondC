import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()
    const service = createServiceClient()
    const { id } = params

    const { data: profile, error } = await service
      .from('profiles')
      .select(`
        id,
        display_name,
        avatar_url,
        state,
        city,
        brand:brand_profiles (
          brand_name,
          brand_category,
          description,
          website,
          logo_url,
          verified,
          total_collabs,
          avg_rating,
          size,
          portfolio_links
        )
      `)
      .eq('id', id)
      .eq('role', 'brand')
      .single()

    if (error || !profile) {
      return NextResponse.json({ error: 'Brand not found' }, { status: 404 })
    }

    const brand = Array.isArray(profile.brand) ? profile.brand[0] : profile.brand

    if (!brand) {
      return NextResponse.json({ error: 'Brand profile not found' }, { status: 404 })
    }

    return NextResponse.json({
      brand: {
        id: profile.id,
        brand_name: brand.brand_name,
        brand_category: brand.brand_category,
        description: brand.description,
        website: brand.website,
        logo_url: brand.logo_url,
        verified: brand.verified,
        total_collabs: brand.total_collabs,
        avg_rating: brand.avg_rating,
        size: brand.size,
        city: profile.city,
        state: profile.state,
        portfolio_links: brand.portfolio_links || [],
      },
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
