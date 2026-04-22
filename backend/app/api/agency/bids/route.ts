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

    const { campaign_id, assigned_creator_id, bid_amount, deliverables, message, include_barter } = body
    if (!campaign_id) return NextResponse.json({ error: 'campaign_id required' }, { status: 400 })

    const insert = {
      campaign_id,
      creator_id: assigned_creator_id || null,
      bid_amount,
      deliverables,
      message,
      include_barter: include_barter || false,
      bidder_type: 'agency',
      agency_id: user.id
    }

    const { error } = await supabase.from('bids').insert(insert)
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

    const { data: bids, error } = await supabase.from('bids').select('*, campaign:campaigns (*)').eq('agency_id', user.id).order('created_at', { ascending: false })
    if (error) return NextResponse.json({ error: error.message }, { status: 400 })

    return NextResponse.json({ bids })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
