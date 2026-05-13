import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: pitches, error } = await supabase
      .from('agency_creator_pitches')
      .select('*')
      .eq('creator_id', user.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const enrichedPitches = []
    for (const p of pitches) {
      let agencyProfile = null
      let agencyData = null
      
      try {
        const ap = await supabase
          .from('agency_profiles')
          .select('id, agency_name, logo_url')
          .eq('id', p.agency_id)
          .maybeSingle()
        agencyData = ap.data
      } catch (e) {}

      try {
        const pf = await supabase
          .from('profiles')
          .select('id, first_name, full_name, avatar_url')
          .eq('id', p.agency_id)
          .maybeSingle()
        agencyProfile = pf.data
      } catch (e) {}

      enrichedPitches.push({
        ...p,
        agency: agencyData || {},
        agency_profile: agencyProfile || {},
      })
    }

    return NextResponse.json({ pitches: enrichedPitches })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}