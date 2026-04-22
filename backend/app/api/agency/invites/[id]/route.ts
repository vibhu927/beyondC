import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const supabase = createClient()
    const body = await request.json()
    const { action } = body

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })

    // Only creators can accept/reject agency invites
    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'creator') return NextResponse.json({ error: 'Forbidden: only creators can respond' }, { status: 403 })

    const inviteId = params.id
    const { data: invite, error: inviteError } = await supabase
      .from('agency_creators')
      .select('*')
      .eq('id', inviteId)
      .single()

    if (inviteError || !invite) return NextResponse.json({ error: 'Invite not found' }, { status: 404 })
    if (invite.creator_id !== user.id) return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })

    if (action === 'accept') {
      const { error: updateError } = await supabase
        .from('agency_creators')
        .update({ status: 'accepted', accepted_at: new Date().toISOString() })
        .eq('id', inviteId)

      if (updateError) return NextResponse.json({ error: updateError.message }, { status: 400 })

      // Increment agency partnered creators count
      await supabase
        .from('agency_profiles')
        .update({ total_partnered_creators: (invite.total_partnered_creators ?? 0) + 1 })
        .eq('id', invite.agency_id)

      // Notify agency
      await supabase.from('notifications').insert({
        user_id: invite.agency_id,
        type: 'invite_accepted',
        title: 'Creator Joined Your Roster',
        body: `Creator accepted your invite`,
        reference_id: inviteId,
        reference_type: 'agency_invite',
      })

      return NextResponse.json({ ok: true })
    } else if (action === 'reject') {
      const { error: updateError } = await supabase
        .from('agency_creators')
        .update({ status: 'rejected' })
        .eq('id', inviteId)

      if (updateError) return NextResponse.json({ error: updateError.message }, { status: 400 })

      return NextResponse.json({ ok: true })
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
