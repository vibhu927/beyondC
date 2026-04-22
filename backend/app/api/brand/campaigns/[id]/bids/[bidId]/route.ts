import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'
import { actionSchema } from '@/lib/validators'
import { sendPushNotification } from '@/lib/notifications/push'
import { getCollabFee } from '@/lib/collabFee'

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

    // Validate action (manual fallback keeps this route resilient if shared schema is stale)
    const parsedAction = typeof body?.action === 'string' ? body.action.trim() : ''
    if (!['accept', 'reject', 'cancel_collab'].includes(parsedAction)) {
      const parsed = actionSchema.safeParse(body)
      if (!parsed.success) {
        return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
      }
    }
    const action = parsedAction as 'accept' | 'reject' | 'cancel_collab'

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
          deliverables,
          slots,
          slots_filled,
          status
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

    if (action === 'accept' && bid.status !== 'pending') {
      return NextResponse.json({ error: 'Bid already processed' }, { status: 400 })
    }

    if (action === 'accept') {
      const totalSlots = Number(bid.campaign.slots ?? 1)
      const filledSlots = Number(bid.campaign.slots_filled ?? 0)
      if (filledSlots >= totalSlots) {
        return NextResponse.json(
          { error: 'All campaign slots are already filled' },
          { status: 400 }
        )
      }

      // If this bid was placed by an agency, deduct credit from the agency
      if (bid.bidder_type === 'agency' && bid.agency_id) {
        const { data: agencyProfile, error: agencyError } = await service
          .from('agency_profiles')
          .select('credit_balance')
          .eq('id', bid.agency_id)
          .single()

        if (agencyError || !agencyProfile) {
          return NextResponse.json({ error: 'Agency profile not found' }, { status: 404 })
        }

        if ((agencyProfile.credit_balance ?? 0) < 1) {
          return NextResponse.json(
            {
              error: 'Agency has insufficient credits',
              required: 1,
              current: agencyProfile.credit_balance ?? 0,
            },
            { status: 400 }
          )
        }

        const nextAgencyCredits = (agencyProfile.credit_balance ?? 0) - 1
        const { error: agencyCreditUpdateError } = await service
          .from('agency_profiles')
          .update({ credit_balance: nextAgencyCredits })
          .eq('id', bid.agency_id)

        if (agencyCreditUpdateError) {
          return NextResponse.json({ error: agencyCreditUpdateError.message }, { status: 400 })
        }

        await service.from('credit_transactions').insert({
          agency_id: bid.agency_id,
          type: 'deduct',
          amount: 1,
          reason: 'bid_accepted',
          reference_id: params.bidId,
          balance_after: nextAgencyCredits,
        })
      } else {
        // Default behavior: deduct from brand
        const { data: brandProfile, error: brandProfileError } = await service
          .from('brand_profiles')
          .select('credit_balance, size')
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
      }

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

      const nextSlotsFilled = Math.min(totalSlots, filledSlots + 1)
      const nextCampaignStatus =
        nextSlotsFilled >= totalSlots ? 'completed' : bid.campaign.status

      await service
        .from('campaigns')
        .update({
          slots_filled: nextSlotsFilled,
          status: nextCampaignStatus,
        })
        .eq('id', params.id)

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
    } else if (action === 'cancel_collab') {
      const { data: directCollab, error: collabLookupError } = await service
        .from('collabs')
        .select('id, creator_id, status')
        .eq('campaign_id', params.id)
        .eq('source', 'bid')
        .eq('source_id', params.bidId)
        .eq('brand_id', user.id)
        .maybeSingle()

      let collab = directCollab
      if (!collab) {
        const { data: fallbackCollab } = await service
          .from('collabs')
          .select('id, creator_id, status')
          .eq('campaign_id', params.id)
          .eq('creator_id', bid.creator_id)
          .eq('brand_id', user.id)
          .in('status', ['active', 'in_progress', 'completed'])
          .order('created_at', { ascending: false })
          .limit(1)
          .maybeSingle()
        collab = fallbackCollab
      }

      if (collabLookupError || !collab) {
        return NextResponse.json({ error: 'Active collab not found for this bid' }, { status: 404 })
      }

      const { data: creatorProfile, error: creatorProfileError } = await service
        .from('creator_profiles')
        .select('wallet_balance, follower_count')
        .eq('id', collab.creator_id)
        .single()

      if (creatorProfileError || !creatorProfile) {
        return NextResponse.json({ error: 'Creator wallet profile not found' }, { status: 404 })
      }

      const { data: brandForRefund } = await service
        .from('brand_profiles')
        .select('size')
        .eq('id', user.id)
        .maybeSingle()

      const brandSize =
        brandForRefund && ['micro', 'mid', 'big'].includes(String(brandForRefund.size))
          ? (brandForRefund.size as 'micro' | 'mid' | 'big')
          : 'micro'
      const refundAmount = getCollabFee(brandSize)
      const currentWalletBalance = Number(creatorProfile.wallet_balance ?? 0)
      const nextWalletBalance = currentWalletBalance + refundAmount

      const { error: walletUpdateError } = await service
        .from('creator_profiles')
        .update({ wallet_balance: nextWalletBalance })
        .eq('id', collab.creator_id)

      if (walletUpdateError) {
        return NextResponse.json({ error: walletUpdateError.message }, { status: 400 })
      }

      const { error: walletTxnError } = await service.from('wallet_transactions').insert({
        creator_id: collab.creator_id,
        type: 'topup',
        amount: refundAmount,
        reason: 'refund',
        reference_id: collab.id,
        balance_after: nextWalletBalance,
      })

      if (walletTxnError) {
        // Legacy fallback: some environments may not allow `refund` reason.
        const { error: walletTxnFallbackError } = await service
          .from('wallet_transactions')
          .insert({
            creator_id: collab.creator_id,
            type: 'topup',
            amount: refundAmount,
            reason: 'wallet_topup',
            reference_id: collab.id,
            balance_after: nextWalletBalance,
          })

        if (walletTxnFallbackError) {
          return NextResponse.json({ error: walletTxnFallbackError.message }, { status: 400 })
        }
      }

      await service
        .from('collabs')
        .update({ status: 'cancelled', completed_at: new Date().toISOString() })
        .eq('id', collab.id)

      await service
        .from('bids')
        .update({ status: 'rejected' })
        .eq('id', params.bidId)

      const totalSlots = Number(bid.campaign.slots ?? 1)
      const filledSlots = Number(bid.campaign.slots_filled ?? 0)
      const nextSlotsFilled = Math.max(0, Math.min(totalSlots, filledSlots - 1))
      const priorCampaignStatus = String(bid.campaign.status ?? '').toLowerCase()
      const nextCampaignStatus =
        (priorCampaignStatus === 'completed' || priorCampaignStatus === 'closed') &&
        nextSlotsFilled < totalSlots
          ? 'active'
          : bid.campaign.status

      const { error: campaignUpdateError } = await service
        .from('campaigns')
        .update({
          slots_filled: nextSlotsFilled,
          status: nextCampaignStatus,
        })
        .eq('id', params.id)

      if (campaignUpdateError) {
        // Fallback for schema variants with different status enums/columns.
        await service
          .from('campaigns')
          .update({
            slots_filled: nextSlotsFilled,
          })
          .eq('id', params.id)
      }

      await service.from('notifications').insert({
        user_id: collab.creator_id,
        type: 'collab_cancelled',
        title: 'Collab Cancelled',
        body: `Your collaboration on "${bid.campaign.title}" was cancelled. Wallet fee refunded.`,
        reference_id: collab.id,
        reference_type: 'collab',
      })

      return NextResponse.json({
        message: 'Collab cancelled and creator wallet refunded',
      })
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
