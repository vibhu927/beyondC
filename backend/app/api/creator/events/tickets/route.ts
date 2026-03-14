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
          brand:brand_profiles!events_brand_id_fkey (
            brand_name,
            logo_url,
            website,
            contact_email
          )
        )
      `)
      .eq('creator_id', user.id)
      .eq('status', 'accepted')
      .order('event:event_date', { ascending: true })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ tickets })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
