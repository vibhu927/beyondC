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
    const status = searchParams.get('status')
    const creatorId = searchParams.get('creator_id')

    let query = supabase
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
      .eq('agency_id', user.id)

    if (status) {
      query = query.eq('status', status)
    }
    if (creatorId) {
      query = query.eq('creator_id', creatorId)
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

    if (profileRow?.role !== 'agency') {
      return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })
    }

    const { creator_id, pitch_type, monthly_fee, profit_ratio, pitch_title, pitch_message, deliverables, collab_type, proposed_amount } = body

    if (!creator_id || !pitch_type) {
      return NextResponse.json({ error: 'creator_id and pitch_type required' }, { status: 400 })
    }

    if (!['monthly_fee', 'profit_ratio'].includes(pitch_type)) {
      return NextResponse.json({ error: 'pitch_type must be monthly_fee or profit_ratio' }, { status: 400 })
    }

    if (pitch_type === 'monthly_fee' && !monthly_fee) {
      return NextResponse.json({ error: 'monthly_fee required when pitch_type is monthly_fee' }, { status: 400 })
    }

    if (pitch_type === 'profit_ratio' && !profit_ratio) {
      return NextResponse.json({ error: 'profit_ratio required when pitch_type is profit_ratio' }, { status: 400 })
    }

    const { data: existingPitch } = await supabase
      .from('agency_creator_pitches')
      .select('id')
      .eq('agency_id', user.id)
      .eq('creator_id', creator_id)
      .in('status', ['pending', 'accepted'])
      .single()

    if (existingPitch) {
      return NextResponse.json({ error: 'Pitch already exists with this creator' }, { status: 400 })
    }

    const { data: pitch, error } = await supabase
      .from('agency_creator_pitches')
      .insert({
        agency_id: user.id,
        creator_id,
        pitch_type,
        monthly_fee,
        profit_ratio,
        pitch_title,
        pitch_message,
        deliverables,
        collab_type,
        proposed_amount,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    await supabase.from('notifications').insert({
      user_id: creator_id,
      type: 'agency_pitch_received',
      title: 'New Agency Pitch',
      body: pitch_title || 'An agency wants to represent you',
      reference_id: pitch.id,
      reference_type: 'agency_creator_pitch',
    })

    return NextResponse.json({ pitch }, { status: 201 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}