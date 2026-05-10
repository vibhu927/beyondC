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
      .from('agency_creator_pitches')
      .select(`
        *,
        creator:creator_profiles!agency_creator_pitches_creator_id_fkey (
          id,
          bio,
          niches,
          platforms,
          starting_price,
          followers_count
        ),
        creator_profile:profiles!agency_creator_pitches_creator_id_fkey (
          first_name,
          full_name,
          avatar_url,
          state,
          city
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
      return NextResponse.json({ error: 'Valid status required: accepted, rejected, or cancelled' }, { status: 400 })
    }

    const { data: pitch, error: fetchError } = await supabase
      .from('agency_creator_pitches')
      .select('*, creator:creator_profiles!agency_creator_pitches_creator_id_fkey(*)')
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
      .from('agency_creator_pitches')
      .update(updates)
      .eq('id', pitchId)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    if (status === 'accepted') {
      const { error: agentError } = await supabase
        .from('agency_creators')
        .upsert({
          agency_id: user.id,
          creator_id: pitch.creator_id,
          status: 'accepted',
          accepted_at: new Date().toISOString(),
          what_agency_offers: pitch.pitch_message,
          monthly_charge: pitch.monthly_fee,
        }, { onConflict: 'agency_id,creator_id' })

      if (agentError) {
        console.error('Error adding creator to agency roster:', agentError)
      }

      await supabase.from('notifications').insert({
        user_id: pitch.creator_id,
        type: 'agency_pitch_accepted',
        title: 'Pitch Accepted',
        body: 'Your pitch has been accepted by the agency',
        reference_id: pitchId,
        reference_type: 'agency_creator_pitch',
      })
    }

    return NextResponse.json({ ok: true })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}