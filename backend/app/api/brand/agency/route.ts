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

    if (profileRow?.role !== 'brand') {
      return NextResponse.json({ error: 'Forbidden: not a brand' }, { status: 403 })
    }

    const { searchParams } = new URL(request.url)
    const status = searchParams.get('status')
    const agencyId = searchParams.get('agency_id')

    let query = supabase
      .from('brand_agency_pitches')
      .select(`
        *,
        agency:agency_profiles!brand_agency_pitches_agency_id_fkey (
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
      .eq('brand_id', user.id)

    if (status) {
      query = query.eq('status', status)
    }
    if (agencyId) {
      query = query.eq('agency_id', agencyId)
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

    if (profileRow?.role !== 'brand') {
      return NextResponse.json({ error: 'Forbidden: not a brand' }, { status: 403 })
    }

    const { agency_id, pitch_title, pitch_message, budget_min, budget_max, required_niches, required_follower_min, required_follower_max, required_platforms, deliverables } = body

    if (!agency_id) {
      return NextResponse.json({ error: 'agency_id required' }, { status: 400 })
    }

    const { data: agency, error: agencyError } = await supabase
      .from('agency_profiles')
      .select('id')
      .eq('id', agency_id)
      .single()

    if (agencyError || !agency) {
      return NextResponse.json({ error: 'Agency not found' }, { status: 404 })
    }

    const { data: existingPitch } = await supabase
      .from('brand_agency_pitches')
      .select('id')
      .eq('brand_id', user.id)
      .eq('agency_id', agency_id)
      .in('status', ['pending', 'accepted'])
      .single()

    if (existingPitch) {
      return NextResponse.json({ error: 'Pitch already exists with this agency' }, { status: 400 })
    }

    const { data: pitch, error } = await supabase
      .from('brand_agency_pitches')
      .insert({
        brand_id: user.id,
        agency_id,
        pitch_title,
        pitch_message,
        budget_min,
        budget_max,
        required_niches,
        required_follower_min,
        required_follower_max,
        required_platforms,
        deliverables,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    await supabase.from('notifications').insert({
      user_id: agency_id,
      type: 'brand_pitch_received',
      title: 'Brand Seeking Creators',
      body: pitch_title || 'A brand is looking for creators from your agency',
      reference_id: pitch.id,
      reference_type: 'brand_agency_pitch',
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

    if (profileRow?.role !== 'brand') {
      return NextResponse.json({ error: 'Forbidden: not a brand' }, { status: 403 })
    }

    const { pitch_id, status } = body

    if (!pitch_id || !status) {
      return NextResponse.json({ error: 'pitch_id and status required' }, { status: 400 })
    }

    if (!['accepted', 'rejected', 'withdrawn'].includes(status)) {
      return NextResponse.json({ error: 'Valid statuses: accepted, rejected, withdrawn' }, { status: 400 })
    }

    const { data: pitch, error: fetchError } = await supabase
      .from('brand_agency_pitches')
      .select('*')
      .eq('id', pitch_id)
      .eq('brand_id', user.id)
      .single()

    if (fetchError || !pitch) {
      return NextResponse.json({ error: 'Pitch not found' }, { status: 404 })
    }

    const updates: any = { status, updated_at: new Date().toISOString() }
    if (status === 'accepted' || status === 'rejected') {
      updates.responded_at = new Date().toISOString()
    }

    const { error } = await supabase
      .from('brand_agency_pitches')
      .update(updates)
      .eq('id', pitch_id)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    if (status === 'accepted') {
      await supabase.from('notifications').insert({
        user_id: pitch.agency_id,
        type: 'brand_pitch_accepted',
        title: 'Brand Accepted Pitch',
        body: 'A brand has accepted your pitch',
        reference_id: pitch_id,
        reference_type: 'brand_agency_pitch',
      })
    }

    return NextResponse.json({ ok: true })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}