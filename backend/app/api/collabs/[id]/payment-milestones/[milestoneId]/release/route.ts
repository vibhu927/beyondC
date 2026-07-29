import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function POST(
  request: NextRequest,
  { params }: { params: { id: string; milestoneId: string } }
) {
  try {
    const supabase = createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: collab, error: collabError } = await supabase
      .from('collabs')
      .select('*')
      .eq('id', params.id)
      .eq('brand_id', user.id)
      .single()

    if (collabError || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    const { data: milestone, error: milestoneError } = await supabase
      .from('payment_milestones')
      .select('*')
      .eq('id', params.milestoneId)
      .eq('collab_id', params.id)
      .single()

    if (milestoneError || !milestone) {
      return NextResponse.json({ error: 'Milestone not found' }, { status: 404 })
    }

    if (milestone.status === 'released') {
      return NextResponse.json({ error: 'Milestone already released' }, { status: 400 })
    }

    const { data: creatorProfile, error: creatorError } = await supabase
      .from('creator_profiles')
      .select('wallet_balance')
      .eq('id', collab.creator_id)
      .single()

    if (creatorError || !creatorProfile) {
      return NextResponse.json({ error: 'Creator wallet not found' }, { status: 404 })
    }

    const newBalance = creatorProfile.wallet_balance + milestone.amount_paise

    // Record transaction before updating balance so we can detect failures
    const { error: txnInsertError } = await supabase
      .from('wallet_transactions')
      .insert({
        creator_id: collab.creator_id,
        type: 'credit',
        amount: milestone.amount_paise,
        reason: 'payment_milestone_released',
        reference_id: params.id,
        balance_after: newBalance,
      })

    if (txnInsertError) {
      return NextResponse.json({ error: txnInsertError.message }, { status: 400 })
    }

    const { error: walletUpdateError } = await supabase
      .from('creator_profiles')
      .update({ wallet_balance: newBalance })
      .eq('id', collab.creator_id)

    if (walletUpdateError) {
      return NextResponse.json({ error: walletUpdateError.message }, { status: 400 })
    }

    await supabase
      .from('payment_milestones')
      .update({
        status: 'released',
        released_at: new Date().toISOString(),
      })
      .eq('id', params.milestoneId)

    await supabase.from('notifications').insert({
      user_id: collab.creator_id,
      type: 'payment_released',
      title: 'Payment Released',
      body: `₹${(milestone.amount_paise / 100).toFixed(0)} released for "${milestone.name}"`,
      reference_id: params.id,
      reference_type: 'collab',
    })

    return NextResponse.json({
      message: 'Payment released',
      amount: milestone.amount_paise,
      milestone: milestone.name,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
