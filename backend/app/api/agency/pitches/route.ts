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

    const { brand_id, assigned_creator_id, pitch_title, pitch_description, proposed_amount, collab_type, deliverables } = body
    if (!brand_id || !pitch_title) return NextResponse.json({ error: 'brand_id and pitch_title required' }, { status: 400 })

    const { error } = await supabase.from('agency_pitches').insert({ agency_id: user.id, brand_id, assigned_creator_id, pitch_title, pitch_description, proposed_amount, collab_type, deliverables })
    if (error) return NextResponse.json({ error: error.message }, { status: 400 })

    return NextResponse.json({ ok: true })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'agency') return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })

    const { data: pitches, error } = await supabase.from('agency_pitches').select('*, brand:brand_profiles (*)').eq('agency_id', user.id).order('created_at', { ascending: false })
    if (error) return NextResponse.json({ error: error.message }, { status: 400 })

    return NextResponse.json({ pitches })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
