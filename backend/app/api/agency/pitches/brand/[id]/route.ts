import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const supabase = createClient()
    const pitchId = params.id

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

    const { data: pitch, error } = await supabase
      .from('agency_brand_pitches')
      .select(`
        *,
        brand:brand_profiles!agency_brand_pitches_brand_id_fkey (
          id,
          brand_name,
          brand_category,
          logo_url,
          size
        ),
        creator:creator_profiles!agency_brand_pitches_creator_id_fkey (
          id,
          bio,
          niches,
          platforms,
          followers_count
        ),
        creator_profile:profiles!agency_brand_pitches_creator_id_fkey (
          first_name,
          full_name,
          avatar_url
        )
      `)
      .eq('id', pitchId)
      .eq('agency_id', user.id)
      .single()

    if (error || !pitch) {
      return NextResponse.json({ error: 'Pitch not found' }, { status: 404 })
    }

    return NextResponse.json({ pitch })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function PATCH(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const supabase = createClient()
    const body = await request.json()
    const pitchId = params.id

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

    const { status } = body
    if (!status || !['accepted', 'rejected', 'cancelled'].includes(status)) {
      return NextResponse.json({ error: 'Valid status: accepted, rejected, or cancelled' }, { status: 400 })
    }

    const { data: pitch, error: fetchError } = await supabase
      .from('agency_brand_pitches')
      .select('*')
      .eq('id', pitchId)
      .eq('agency_id', user.id)
      .single()

    if (fetchError || !pitch) {
      return NextResponse.json({ error: 'Pitch not found' }, { status: 404 })
    }

    const updates: any = { status, updated_at: new Date().toISOString() }
    if (status === 'accepted' || status === 'rejected') {
      updates.responded_at = new Date().toISOString()
    }

    const { error } = await supabase
      .from('agency_brand_pitches')
      .update(updates)
      .eq('id', pitchId)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    if (status === 'accepted') {
      await supabase.from('notifications').insert({
        user_id: pitch.creator_id,
        type: 'collab_offered',
        title: 'Collaboration Offered',
        body: 'A brand has accepted to work with you',
        reference_id: pitchId,
        reference_type: 'agency_brand_pitch',
      })
    }

    return NextResponse.json({ ok: true })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}