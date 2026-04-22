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

    const { creator_id, message, what_agency_offers, monthly_charge } = body
    if (!creator_id) return NextResponse.json({ error: 'creator_id required' }, { status: 400 })

    // Prevent inviting a creator who already has accepted agency
    const { data: existing } = await supabase.from('agency_creators').select('*').eq('creator_id', creator_id).eq('status', 'accepted').single()
    if (existing) return NextResponse.json({ error: 'This creator is already managed by an agency' }, { status: 400 })

    const { error } = await supabase.from('agency_creators').insert({ agency_id: user.id, creator_id, message, what_agency_offers, monthly_charge })
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

    const { data: invites, error } = await supabase.from('agency_creators').select('*, creator:creator_profiles ( * )').eq('agency_id', user.id).order('invited_at', { ascending: false })
    if (error) return NextResponse.json({ error: error.message }, { status: 400 })

    return NextResponse.json({ invites })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
