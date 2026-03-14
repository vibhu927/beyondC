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
          location,
          image_url,
          brand:brand_profiles!events_brand_id_fkey (
            brand_name,
            logo_url
          )
        )
      `)
      .eq('creator_id', user.id)
      .order('created_at', { ascending: false })

    if (status && ['pending', 'accepted', 'declined'].includes(status)) {
      query = query.eq('status', status)
    }

    const { data: invites, error } = await query

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ invites })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
