import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { actionSchema } from '@/lib/validators'
import crypto from 'crypto'
import { sendPushNotification } from '@/app/api/notifications/send-push/route'

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate action
    const { action } = actionSchema.parse(body)

    // Get invite details
    const { data: invite, error: inviteError } = await supabase
      .from('event_invites')
      .select(`
        *,
        event:events (
          id,
          title,
          event_date,
          brand_id
        )
      `)
      .eq('id', params.id)
      .eq('creator_id', user.id)
      .single()

    if (inviteError || !invite) {
      return NextResponse.json({ error: 'Invite not found' }, { status: 404 })
    }

    if (invite.status !== 'pending') {
      return NextResponse.json({ error: 'Invite already processed' }, { status: 400 })
    }

    const newStatus = action === 'accept' ? 'accepted' : 'declined'
    
    // Generate QR code data if accepting
    let qrData = null
    if (action === 'accept') {
      qrData = crypto.randomBytes(16).toString('hex')
    }

    // Update invite status
    const { data: updatedInvite, error: updateError } = await supabase
      .from('event_invites')
      .update({ 
        status: newStatus,
        qr_code_data: qrData,
      })
      .eq('id', params.id)
      .select()
      .single()

    if (updateError) {
      return NextResponse.json({ error: updateError.message }, { status: 400 })
    }

    // Notify brand
    await supabase.from('notifications').insert({
      user_id: invite.event.brand_id,
      type: action === 'accept' ? 'invite_accepted' : 'invite_declined',
      title: `Event Invite ${action === 'accept' ? 'Accepted' : 'Declined'}`,
      body: `A creator ${action === 'accept' ? 'accepted' : 'declined'} your event invite`,
      reference_id: invite.event.id,
      reference_type: 'event',
    })

    await sendPushNotification({
      userId: invite.event.brand_id,
      title: `Event Invite ${action === 'accept' ? 'Accepted' : 'Declined'}`,
      body: `A creator ${action === 'accept' ? 'accepted' : 'declined'} your event invite`,
      data: {
        type: action === 'accept' ? 'invite_accepted' : 'invite_declined',
        event_id: invite.event.id,
      },
    })

    return NextResponse.json({ 
      message: `Invite ${newStatus}`,
      invite: updatedInvite,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
