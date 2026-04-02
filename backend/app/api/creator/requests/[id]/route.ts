import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { actionSchema } from '@/lib/validators'
import { getCollabFee } from '@/lib/collabFee'
import { sendPushNotification } from '@/lib/notifications/push'

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

    // Get request details
    const { data: collabRequest, error: requestError } = await supabase
      .from('collab_requests')
      .select(`
        *,
        brand:brand_profiles!collab_requests_brand_id_fkey(size)
      `)
      .eq('id', params.id)
      .eq('creator_id', user.id)
      .single()

    if (requestError || !collabRequest) {
      return NextResponse.json({ error: 'Request not found' }, { status: 404 })
    }

    if (collabRequest.status !== 'pending') {
      return NextResponse.json({ error: 'Request already processed' }, { status: 400 })
    }

    if (action === 'accept') {
      const { data: brandProfile, error: brandProfileError } = await supabase
        .from('brand_profiles')
        .select('credit_balance')
        .eq('id', collabRequest.brand_id)
        .single()

      if (brandProfileError || !brandProfile) {
        return NextResponse.json({ error: 'Brand profile not found' }, { status: 404 })
      }

      if ((brandProfile.credit_balance ?? 0) < 1) {
        return NextResponse.json(
          {
            error: 'Brand has insufficient credits',
            required: 1,
            current: brandProfile.credit_balance ?? 0,
          },
          { status: 400 }
        )
      }

      // Check wallet balance for collab fee
      const { data: creatorProfile, error: creatorError } = await supabase
        .from('creator_profiles')
        .select('wallet_balance')
        .eq('id', user.id)
        .single()

      if (creatorError || !creatorProfile) {
        return NextResponse.json({ error: 'Creator profile not found' }, { status: 404 })
      }

      const collabFee = getCollabFee(collabRequest.brand.size)
      if (creatorProfile.wallet_balance < collabFee) {
        return NextResponse.json(
          { 
            error: 'Insufficient wallet balance',
            required: collabFee,
            current: creatorProfile.wallet_balance,
          },
          { status: 400 }
        )
      }

      // Deduct collab fee from wallet
      const newBalance = creatorProfile.wallet_balance - collabFee
      
      await supabase
        .from('creator_profiles')
        .update({ wallet_balance: newBalance })
        .eq('id', user.id)

      // Record wallet transaction
      await supabase.from('wallet_transactions').insert({
        creator_id: user.id,
        type: 'deduct',
        amount: collabFee,
        reason: 'collab_fee_deducted',
        reference_id: params.id,
        balance_after: newBalance,
      })

      // Create collab
      const { data: collab, error: collabError } = await supabase
        .from('collabs')
        .insert({
          brand_id: collabRequest.brand_id,
          creator_id: user.id,
          source: 'direct_request',
          source_id: params.id,
          agreed_amount: collabRequest.budget,
          collab_type: collabRequest.collab_type,
          deliverables: collabRequest.deliverables,
        })
        .select()
        .single()

      if (collabError) {
        return NextResponse.json({ error: collabError.message }, { status: 400 })
      }

      // Update request status
      await supabase
        .from('collab_requests')
        .update({ status: 'accepted' })
        .eq('id', params.id)

      const nextCredits = (brandProfile.credit_balance ?? 0) - 1
      await supabase
        .from('brand_profiles')
        .update({ credit_balance: nextCredits })
        .eq('id', collabRequest.brand_id)

      await supabase.from('credit_transactions').insert({
        brand_id: collabRequest.brand_id,
        type: 'deduct',
        amount: 1,
        reason: 'direct_request_accepted',
        reference_id: params.id,
        balance_after: nextCredits,
      })

      // Notify brand
      await supabase.from('notifications').insert({
        user_id: collabRequest.brand_id,
        type: 'request_accepted',
        title: 'Collab Request Accepted',
        body: 'A creator accepted your collab request',
        reference_id: collab.id,
        reference_type: 'collab',
      })

      await sendPushNotification({
        userId: collabRequest.brand_id,
        title: 'Collab Request Accepted',
        body: 'A creator accepted your collab request',
        data: {
          type: 'collab_matched',
          collab_id: collab.id,
        },
      })

      return NextResponse.json({ 
        message: 'Request accepted',
        collab,
      })
    } else if (action === 'reject') {
      // Reject request
      await supabase
        .from('collab_requests')
        .update({ status: 'rejected' })
        .eq('id', params.id)

      // Notify brand
      await supabase.from('notifications').insert({
        user_id: collabRequest.brand_id,
        type: 'request_rejected',
        title: 'Collab Request Declined',
        body: 'A creator declined your collab request',
        reference_id: params.id,
        reference_type: 'request',
      })

      return NextResponse.json({ message: 'Request rejected' })
    }

    return NextResponse.json({ error: 'Invalid action' }, { status: 400 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
