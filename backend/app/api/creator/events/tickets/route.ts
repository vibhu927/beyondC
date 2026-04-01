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

    // Get all accepted event invites with full event details
    const { data: tickets, error } = await supabase
      .from('event_invites')
      .select(`
        id,
        qr_code_data,
        status,
        created_at,
        event:events (
          id,
          title,
          description,
          event_date,
          location,
          image_url,
          brand_id
        )
      `)
      .eq('creator_id', user.id)
      .eq('status', 'accepted')
      .order('event:event_date', { ascending: true })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const brandIds = Array.from(
      new Set((tickets ?? []).map((ticket: any) => ticket?.event?.brand_id).filter(Boolean))
    )

    let brandMap = new Map<
      string,
      {
        brand_name: string | null
        logo_url: string | null
        website: string | null
        contact_email: string | null
      }
    >()

    if (brandIds.length > 0) {
      const { data: brands } = await supabase
        .from('brand_profiles')
        .select('id,brand_name,logo_url,website,contact_email')
        .in('id', brandIds)

      brandMap = new Map(
        (brands ?? []).map((brand: any) => [
          String(brand.id),
          {
            brand_name: brand.brand_name ?? null,
            logo_url: brand.logo_url ?? null,
            website: brand.website ?? null,
            contact_email: brand.contact_email ?? null,
          },
        ])
      )
    }

    const enrichedTickets = (tickets ?? []).map((ticket: any) => {
      const event = ticket?.event ?? null
      const brandId = event?.brand_id ? String(event.brand_id) : null
      const brand = brandId ? brandMap.get(brandId) ?? null : null

      return {
        ...ticket,
        event: event
          ? {
              ...event,
              brand,
            }
          : event,
      }
    })

    return NextResponse.json({ tickets: enrichedTickets })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
