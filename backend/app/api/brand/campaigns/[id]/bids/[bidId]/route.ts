import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { actionSchema } from '@/lib/validators'
import { getCollabFee } from '@/lib/collabFee'
import { sendPushNotification } from '@/lib/notifications/push'

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string; bidId: string } }
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

    // Get bid with campaign details
    const { data: bid, error: bidError } = await supabase
      .from('bids')
      .select(`
        *,
        campaign:campaigns (
          brand_id,
          title,
          budget,
          collab_type,
          deliverables
        )
      `)
      .eq('id', params.bidId)
      .eq('campaign_id', params.id)
      .single()

    if (bidError || !bid) {
      return NextResponse.json({ error: 'Bid not found' }, { status: 404 })
    }

    // Verify brand owns the campaign
    if (bid.campaign.brand_id !== user.id) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
    }

    if (bid.status !== 'pending') {
      return NextResponse.json({ error: 'Bid already processed' }, { status: 400 })
    }

    if (action === 'accept') {
      // Create collab from accepted bid
      const { data: collab, error: collabError } = await supabase
        .from('collabs')
        .insert({
          brand_id: user.id,
          creator_id: bid.creator_id,
          source: 'campaign_bid',
          source_id: params.bidId,
          agreed_amount: bid.campaign.budget,
          collab_type: bid.campaign.collab_type,
          deliverables: bid.campaign.deliverables,
        })
        .select()
        .single()

      if (collabError) {
        return NextResponse.json({ error: collabError.message }, { status: 400 })
      }

      // Update bid status
      await supabase
        .from('bids')
        .update({ status: 'accepted' })
        .eq('id', params.bidId)

      // Notify creator
      await supabase.from('notifications').insert({
        user_id: bid.creator_id,
        type: 'bid_accepted',
        title: 'Bid Accepted!',
        body: `Your bid on "${bid.campaign.title}" was accepted`,
        reference_id: collab.id,
        reference_type: 'collab',
      })

      await sendPushNotification({
        userId: bid.creator_id,
        title: 'Bid Accepted!',
        body: `Your bid on "${bid.campaign.title}" was accepted`,
        data: {
          type: 'bid_accepted',
          collab_id: collab.id,
        },
      })

      return NextResponse.json({ 
        message: 'Bid accepted',
        collab,
      })
    } else if (action === 'reject') {
      // Reject bid
      await supabase
        .from('bids')
        .update({ status: 'rejected' })
        .eq('id', params.bidId)

      // Notify creator
      await supabase.from('notifications').insert({
        user_id: bid.creator_id,
        type: 'bid_rejected',
        title: 'Bid Not Selected',
        body: `Your bid on "${bid.campaign.title}" was not selected`,
        reference_id: params.id,
        reference_type: 'campaign',
      })

      return NextResponse.json({ message: 'Bid rejected' })
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
