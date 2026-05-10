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
    const brandId = searchParams.get('brand_id')

    let query = supabase
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
          followers_count,
          avg_rating
        ),
        creator_profile:profiles!agency_brand_pitches_creator_id_fkey (
          first_name,
          full_name,
          avatar_url
        )
      `)
      .eq('agency_id', user.id)

    if (status) {
      query = query.eq('status', status)
    }
    if (brandId) {
      query = query.eq('brand_id', brandId)
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

    const { brand_id, creator_id, pitch_title, pitch_description, proposed_amount, deliverables, collab_type } = body

    if (!brand_id || !creator_id) {
      return NextResponse.json({ error: 'brand_id and creator_id required' }, { status: 400 })
    }

    const { data: creator, error: creatorError } = await supabase
      .from('creator_profiles')
      .select('id')
      .eq('id', creator_id)
      .single()

    if (creatorError || !creator) {
      return NextResponse.json({ error: 'Creator not found' }, { status: 404 })
    }

    const { data: brand, error: brandError } = await supabase
      .from('brand_profiles')
      .select('id')
      .eq('id', brand_id)
      .single()

    if (brandError || !brand) {
      return NextResponse.json({ error: 'Brand not found' }, { status: 404 })
    }

    const { data: pitch, error } = await supabase
      .from('agency_brand_pitches')
      .insert({
        agency_id: user.id,
        brand_id,
        creator_id,
        pitch_title,
        pitch_description,
        proposed_amount,
        deliverables,
        collab_type,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    await supabase.from('notifications').insert({
      user_id: brand_id,
      type: 'agency_brand_pitch',
      title: 'Creator Recommendation',
      body: pitch_title || 'An agency wants to pitch a creator for your campaign',
      reference_id: pitch.id,
      reference_type: 'agency_brand_pitch',
    })

    return NextResponse.json({ pitch }, { status: 201 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}