import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'
import { actionSchema } from '@/lib/validators'
import { sendPushNotification } from '@/lib/notifications/push'

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string; bidId: string } }
) {
  try {
    const supabase = createClient()
    const service = createServiceClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate action
    const { action } = actionSchema.parse(body)

    // Get bid with campaign details
    const { data: bid, error: bidError } = await service
      .from('bids')
      .select(`
        *,
        campaign:campaigns (
          brand_id,
          title,
          budget_min,
          budget_max,
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
      const { data: brandProfile, error: brandProfileError } = await service
        .from('brand_profiles')
        .select('credit_balance')
        .eq('id', user.id)
        .single()

      if (brandProfileError || !brandProfile) {
        return NextResponse.json({ error: 'Brand profile not found' }, { status: 404 })
      }

      if ((brandProfile.credit_balance ?? 0) < 1) {
        return NextResponse.json(
          {
            error: 'Insufficient credits',
            required: 1,
            current: brandProfile.credit_balance ?? 0,
          },
          { status: 400 }
        )
      }

      const nextCredits = (brandProfile.credit_balance ?? 0) - 1
      const { error: creditUpdateError } = await service
        .from('brand_profiles')
        .update({ credit_balance: nextCredits })
        .eq('id', user.id)

      if (creditUpdateError) {
        return NextResponse.json({ error: creditUpdateError.message }, { status: 400 })
      }

      await service.from('credit_transactions').insert({
        brand_id: user.id,
        type: 'deduct',
        amount: 1,
        reason: 'bid_accepted',
        reference_id: params.bidId,
        balance_after: nextCredits,
      })

      // Create collab from accepted bid
      const agreedAmount =
        bid.bid_amount ??
        bid.campaign.budget_min ??
        bid.campaign.budget_max ??
        0

      const { data: collab, error: collabError } = await service
        .from('collabs')
        .insert({
          brand_id: user.id,
          creator_id: bid.creator_id,
          source: 'bid',
          source_id: params.bidId,
          campaign_id: params.id,
          agreed_amount: agreedAmount,
          collab_type: bid.campaign.collab_type,
          deliverables: bid.campaign.deliverables,
        })
        .select()
        .single()

      if (collabError) {
        return NextResponse.json({ error: collabError.message }, { status: 400 })
      }

      // Update bid status
      await service
        .from('bids')
        .update({ status: 'accepted' })
        .eq('id', params.bidId)

      // Notify creator
      await service.from('notifications').insert({
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
      await service
        .from('bids')
        .update({ status: 'rejected' })
        .eq('id', params.bidId)

      // Notify creator
      await service.from('notifications').insert({
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
