import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'agency') return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })

    const { pitch_type, target_id, pitch_title, pitch_description, pitch_message, monthly_fee, profit_ratio, deliverables, collab_type, proposed_amount } = body

    if (!pitch_type || !target_id) return NextResponse.json({ error: 'pitch_type and target_id required' }, { status: 400 })

    if (pitch_type === 'creator') {
      const { error } = await supabase.from('agency_creator_pitches').insert({
        agency_id: user.id,
        creator_id: target_id,
        pitch_title,
        pitch_message: pitch_message,
        monthly_fee: monthly_fee,
        profit_ratio: profit_ratio,
        deliverables: deliverables,
        collab_type: collab_type,
        proposed_amount: proposed_amount,
      })
      if (error) return NextResponse.json({ error: error.message }, { status: 400 })
    } else if (pitch_type === 'brand') {
      const { brand_id, creator_id } = target_id
      const { error } = await supabase.from('agency_brand_pitches').insert({
        agency_id: user.id,
        brand_id,
        creator_id,
        pitch_title,
        pitch_description: pitch_message,
        proposed_amount,
        deliverables,
        collab_type,
      })
      if (error) return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ ok: true })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()
    const { searchParams } = new URL(request.url)
    const type = searchParams.get('type')

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'agency') return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })

    let pitches: any[] = []

    if (!type || type === 'creator') {
      const { data: creatorPitches, error: creatorError } = await supabase
        .from('agency_creator_pitches')
        .select(`
          *,
          creator:creator_profiles!agency_creator_pitches_creator_id_fkey (id, bio, niches, platforms, followers_count),
          creator_profile:profiles!agency_creator_pitches_creator_id_fkey (first_name, full_name, avatar_url, state, city)
        `)
        .eq('agency_id', user.id)
        .order('created_at', { ascending: false })

      if (!creatorError && creatorPitches) {
        pitches = [...pitches, ...creatorPitches.map(p => ({ ...p, pitch_direction: 'to_creator' }))]
      }
    }

    if (!type || type === 'brand') {
      const { data: brandPitches, error: brandError } = await supabase
        .from('agency_brand_pitches')
        .select(`
          *,
          brand:brand_profiles!agency_brand_pitches_brand_id_fkey (id, brand_name, brand_category, logo_url, size),
          creator:creator_profiles!agency_brand_pitches_creator_id_fkey (id, bio, niches, followers_count),
          creator_profile:profiles!agency_brand_pitches_creator_id_fkey (first_name, full_name, avatar_url)
        `)
        .eq('agency_id', user.id)
        .order('created_at', { ascending: false })

      if (!brandError && brandPitches) {
        pitches = [...pitches, ...brandPitches.map(p => ({ ...p, pitch_direction: 'to_brand' }))]
      }
    }

    return NextResponse.json({ pitches })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
