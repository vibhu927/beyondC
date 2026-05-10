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

    if (profileRow?.role !== 'creator') {
      return NextResponse.json({ error: 'Forbidden: not a creator' }, { status: 403 })
    }

    const { searchParams } = new URL(request.url)
    const status = searchParams.get('status')

    let query = supabase
      .from('creator_agency_pitches')
      .select(`
        *,
        agency:agency_profiles!creator_agency_pitches_agency_id_fkey (
          id,
          agency_name,
          tagline,
          description,
          logo_url,
          niche,
          total_partnered_creators,
          avg_rating
        )
      `)
      .eq('creator_id', user.id)

    if (status) {
      query = query.eq('status', status)
    }

    const { data: pitches, error } = await query.order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ pitches })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'creator') {
      return NextResponse.json({ error: 'Forbidden: not a creator' }, { status: 403 })
    }

    const { agency_id, pitch_title, pitch_message, expected_monthly_fee, expected_profit_ratio, portfolio_links } = body

    if (!agency_id) {
      return NextResponse.json({ error: 'agency_id required' }, { status: 400 })
    }

    const { data: existingPitch } = await supabase
      .from('creator_agency_pitches')
      .select('id')
      .eq('creator_id', user.id)
      .eq('agency_id', agency_id)
      .in('status', ['pending', 'accepted'])
      .single()

    if (existingPitch) {
      return NextResponse.json({ error: 'Pitch already exists with this agency' }, { status: 400 })
    }

    const { data: pitch, error } = await supabase
      .from('creator_agency_pitches')
      .insert({
        creator_id: user.id,
        agency_id,
        pitch_title,
        pitch_message,
        expected_monthly_fee,
        expected_profit_ratio,
        portfolio_links,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    await supabase.from('notifications').insert({
      user_id: agency_id,
      type: 'creator_pitch_received',
      title: 'Creator Seeking Representation',
      body: pitch_title || 'A creator wants you to represent them',
      reference_id: pitch.id,
      reference_type: 'creator_agency_pitch',
    })

    return NextResponse.json({ pitch }, { status: 201 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'creator') {
      return NextResponse.json({ error: 'Forbidden: not a creator' }, { status: 403 })
    }

    const { pitch_id, status } = body

    if (!pitch_id || !status) {
      return NextResponse.json({ error: 'pitch_id and status required' }, { status: 400 })
    }

    if (!['accepted', 'rejected', 'withdrawn'].includes(status)) {
      return NextResponse.json({ error: 'Valid statuses: accepted, rejected, withdrawn' }, { status: 400 })
    }

    const { data: pitch, error: fetchError } = await supabase
      .from('creator_agency_pitches')
      .select('*')
      .eq('id', pitch_id)
      .eq('creator_id', user.id)
      .single()

    if (fetchError || !pitch) {
      return NextResponse.json({ error: 'Pitch not found' }, { status: 404 })
    }

    const updates: any = { status, updated_at: new Date().toISOString() }
    if (status === 'accepted' || status === 'rejected') {
      updates.responded_at = new Date().toISOString()
    }

    const { error } = await supabase
      .from('creator_agency_pitches')
      .update(updates)
      .eq('id', pitch_id)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    if (status === 'accepted') {
      await supabase.from('agency_creators').upsert({
        agency_id: pitch.agency_id,
        creator_id: user.id,
        status: 'accepted',
        accepted_at: new Date().toISOString(),
      }, { onConflict: 'agency_id,creator_id' })

      await supabase.from('notifications').insert({
        user_id: pitch.agency_id,
        type: 'creator_pitch_accepted',
        title: 'Creator Accepted',
        body: 'A creator has accepted your representation',
        reference_id: pitch_id,
        reference_type: 'creator_agency_pitch',
      })
    }

    return NextResponse.json({ ok: true })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}