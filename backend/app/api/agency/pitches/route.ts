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
      const pitchType = monthly_fee ? 'monthly_fee' : (profit_ratio ? 'profit_ratio' : null);
      const { error } = await supabase.from('agency_creator_pitches').insert({
        agency_id: user.id,
        creator_id: target_id,
        pitch_type: pitchType,
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
        .select('*')
        .eq('agency_id', user.id)
        .order('created_at', { ascending: false })

      if (!creatorError && creatorPitches && creatorPitches.length > 0) {
        for (const p of creatorPitches) {
          const profileRes = await supabase
            .from('profiles')
            .select('id, first_name, full_name, avatar_url')
            .eq('id', p.creator_id)
            .maybeSingle()
          
          const creatorRes = await supabase
            .from('creator_profiles')
            .select('id, bio, niche')
            .eq('id', p.creator_id)
            .maybeSingle()
          
          pitches.push({
            ...p,
            pitch_direction: 'to_creator',
            creator: creatorRes.data || {},
            creator_profile: profileRes.data || {},
          })
        }
      }
    }

    if (!type || type === 'brand') {
      const { data: brandPitches, error: brandError } = await supabase
        .from('agency_brand_pitches')
        .select('*')
        .eq('agency_id', user.id)
        .order('created_at', { ascending: false })

      if (!brandError && brandPitches && brandPitches.length > 0) {
        for (const p of brandPitches) {
          let brandProfile = null
          let creatorProfile = null
          let creatorProfileData = null
          
          try {
            const bp = await supabase.from('brand_profiles').select('id, brand_name, brand_category, logo_url, size').eq('id', p.brand_id).maybeSingle()
            brandProfile = bp.data
          } catch (e) {}
          
          try {
            const cp = await supabase.from('creator_profiles').select('id, bio, niches, followers_count').eq('id', p.creator_id).maybeSingle()
            creatorProfile = cp.data
          } catch (e) {}
          
          try {
            const cpf = await supabase.from('profiles').select('first_name, full_name, avatar_url').eq('id', p.creator_id).maybeSingle()
            creatorProfileData = cpf.data
          } catch (e) {}
          
          pitches.push({
            ...p,
            pitch_direction: 'to_brand',
            brand: brandProfile || {},
            creator: creatorProfile || {},
            creator_profile: creatorProfileData || {},
          })
        }
      }
    }

    return NextResponse.json({ pitches })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function DELETE(request: NextRequest) {
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

    const { pitch_id, pitch_type } = body

    if (!pitch_id || !pitch_type) {
      return NextResponse.json({ error: 'pitch_id and pitch_type required' }, { status: 400 })
    }

    const table = pitch_type === 'creator' ? 'agency_creator_pitches' : 'agency_brand_pitches'

    const { error: updateError } = await supabase
      .from(table)
      .update({ status: 'cancelled', updated_at: new Date().toISOString() })
      .eq('id', pitch_id)
      .eq('agency_id', user.id)
      .eq('status', 'pending')

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 })
    }

    return NextResponse.json({ message: 'Pitch withdrawn successfully' })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
