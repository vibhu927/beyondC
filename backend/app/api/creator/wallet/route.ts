import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient, createClient } from '@/lib/supabase/server'
import { createTopupSchema } from '@/lib/validators'
import { getRazorpay } from '@/lib/razorpay'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get wallet balance
    const { data: creatorProfile, error: profileError } = await supabase
      .from('creator_profiles')
      .select('wallet_balance')
      .eq('id', user.id)
      .single()

    if (profileError) {
      return NextResponse.json({ error: profileError.message }, { status: 400 })
    }

    // Get recent transactions
    const { data: transactions, error: txnError } = await supabase
      .from('wallet_transactions')
      .select('*')
      .eq('creator_id', user.id)
      .order('created_at', { ascending: false })
      .limit(20)

    if (txnError) {
      return NextResponse.json({ error: txnError.message }, { status: 400 })
    }

    return NextResponse.json({
      balance: creatorProfile.wallet_balance,
      transactions,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const razorpay = getRazorpay()
    const supabase = createClient()
    const adminClient = createAdminClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate topup amount
    const { amount } = createTopupSchema.parse(body)

    const receipt = `wt_${user.id.slice(0, 8)}_${Date.now().toString(36)}`

    // Create Razorpay order
    const order = await razorpay.orders.create({
      amount, // in paise
      currency: 'INR',
      receipt,
      notes: {
        creator_id: user.id,
        type: 'wallet_topup',
      },
    })

    // Store pending transaction
    await adminClient.from('wallet_transactions').insert({
      creator_id: user.id,
      type: 'topup',
      amount,
      reason: 'wallet_topup',
      razorpay_order_id: order.id,
      balance_after: 0, // Will be updated on verification
    })

    return NextResponse.json({
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
      key_id: process.env.RAZORPAY_KEY_ID || process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID,
    })
  } catch (error: any) {
    console.error('[creator/wallet POST] failed:', error)
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
