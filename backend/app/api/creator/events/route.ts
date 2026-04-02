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
    const status = searchParams.get('status')

    let query = supabase
      .from('event_invites')
      .select(`
        *,
        event:events (
          id,
          title,
          description,
          event_date,
          location:venue_address,
          venue_name,
          city,
          is_virtual,
          virtual_link,
          image_url,
          brand_id
        )
      `)
      .eq('creator_id', user.id)
      .order('created_at', { ascending: false })

    if (status && ['pending', 'accepted', 'declined'].includes(status)) {
      query = query.eq('status', status)
    }

    const { data: invites, error } = await query

    if (error) {
      console.error('[creator/events] query error:', error.message)
      return NextResponse.json({ invites: [] })
    }

    const brandIds = Array.from(
      new Set((invites ?? []).map((invite: any) => invite?.event?.brand_id).filter(Boolean))
    )

    let brandMap = new Map<string, { brand_name: string | null; logo_url: string | null }>()
    if (brandIds.length > 0) {
      const { data: brands } = await supabase
        .from('brand_profiles')
        .select('id,brand_name,logo_url')
        .in('id', brandIds)

      brandMap = new Map(
        (brands ?? []).map((brand: any) => [
          String(brand.id),
          {
            brand_name: brand.brand_name ?? null,
            logo_url: brand.logo_url ?? null,
          },
        ])
      )
    }

    const enrichedInvites = (invites ?? []).map((invite: any) => {
      const event = invite?.event ?? null
      const brandId = event?.brand_id ? String(event.brand_id) : null
      const brand = brandId ? brandMap.get(brandId) ?? null : null

      return {
        ...invite,
        event: event
          ? {
              ...event,
              brand,
            }
          : event,
      }
    })

    return NextResponse.json({ invites: enrichedInvites })
  } catch (error: any) {
    console.error('[creator/events] unexpected error:', error?.message || error)
    return NextResponse.json({ invites: [] })
  }
}
