import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

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

    const { data: roster, error } = await supabase.from('agency_creators').select('*, creator:creator_profiles ( * ), profile:profiles ( first_name, avatar_url, state, city )').eq('agency_id', user.id).eq('status', 'accepted').order('accepted_at', { ascending: false })
    if (error) return NextResponse.json({ error: error.message }, { status: 400 })

    return NextResponse.json({ roster })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const supabase = createClient()
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })

    const { searchParams } = new URL(request.url)
    const creatorId = searchParams.get('creator_id')
    if (!creatorId) return NextResponse.json({ error: 'creator_id required' }, { status: 400 })

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'agency') return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })

    const { error } = await supabase.from('agency_creators').update({ status: 'removed' }).eq('agency_id', user.id).eq('creator_id', creatorId)
    if (error) return NextResponse.json({ error: error.message }, { status: 400 })

    return NextResponse.json({ ok: true })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
