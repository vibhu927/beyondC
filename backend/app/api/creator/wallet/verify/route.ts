import { NextRequest, NextResponse } from 'next/server'
import { createClient, createAdminClient } from '@/lib/supabase/server'
import { verifyPaymentSchema } from '@/lib/validators'
import crypto from 'crypto'

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const adminClient = createAdminClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate payment details
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = 
      verifyPaymentSchema.parse(body)

    // Verify signature
    const hmac = crypto.createHmac('sha256', process.env.RAZORPAY_KEY_SECRET!)
    hmac.update(`${razorpay_order_id}|${razorpay_payment_id}`)
    const generated_signature = hmac.digest('hex')

    if (generated_signature !== razorpay_signature) {
      return NextResponse.json({ error: 'Invalid payment signature' }, { status: 400 })
    }

    // Get transaction details
    const { data: transaction, error: txnError } = await adminClient
      .from('wallet_transactions')
      .select('*')
      .eq('reference_id', razorpay_order_id)
      .eq('creator_id', user.id)
      .single()

    if (txnError || !transaction) {
      return NextResponse.json({ error: 'Transaction not found' }, { status: 404 })
    }

    if (transaction.reason !== 'wallet_topup_pending') {
      return NextResponse.json({ error: 'Transaction already processed' }, { status: 400 })
    }

    // Get current wallet balance
    const { data: creatorProfile, error: profileError } = await adminClient
      .from('creator_profiles')
      .select('wallet_balance')
      .eq('id', user.id)
      .single()

    if (profileError) {
      return NextResponse.json({ error: profileError.message }, { status: 400 })
    }

    const newBalance = creatorProfile.wallet_balance + transaction.amount

    // Update wallet balance
    await adminClient
      .from('creator_profiles')
      .update({ wallet_balance: newBalance })
      .eq('id', user.id)

    // Update transaction
    await adminClient
      .from('wallet_transactions')
      .update({
        reason: 'wallet_topup_success',
        reference_id: razorpay_payment_id,
        balance_after: newBalance,
      })
      .eq('id', transaction.id)

    return NextResponse.json({
      message: 'Wallet topped up successfully',
      new_balance: newBalance,
      amount_added: transaction.amount,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
