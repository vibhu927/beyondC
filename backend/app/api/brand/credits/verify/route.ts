import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'
import { verifyPaymentSchema } from '@/lib/validators'
import { getRazorpay } from '@/lib/razorpay'
import crypto from 'crypto'

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const service = createServiceClient()
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

    // Prevent duplicate processing
    const { data: existing } = await service
      .from('credit_transactions')
      .select('id')
      .eq('razorpay_payment_id', razorpay_payment_id)
      .maybeSingle()

    if (existing) {
      return NextResponse.json({ error: 'Transaction already processed' }, { status: 400 })
    }

    // Get credit amount from Razorpay order notes
    const razorpay = getRazorpay()
    const razorpayOrder = await razorpay.orders.fetch(razorpay_order_id)
    const creditAmount = Number(razorpayOrder.notes?.credits) || 0

    if (creditAmount <= 0) {
      return NextResponse.json({ error: 'Invalid credit amount' }, { status: 400 })
    }

    // Get current credits balance
    const { data: brandProfile, error: profileError } = await service
      .from('brand_profiles')
      .select('credit_balance')
      .eq('id', user.id)
      .single()

    if (profileError) {
      return NextResponse.json({ error: profileError.message }, { status: 400 })
    }

    const newBalance = (brandProfile?.credit_balance ?? 0) + creditAmount

    // Insert transaction and update balance
    await service.from('credit_transactions').insert({
      brand_id: user.id,
      type: 'topup',
      amount: creditAmount,
      reason: 'credit_pack_purchase',
      razorpay_order_id,
      razorpay_payment_id,
      balance_after: newBalance,
    })

    await service
      .from('brand_profiles')
      .update({ credit_balance: newBalance })
      .eq('id', user.id)

    return NextResponse.json({
      message: 'Credits purchased successfully',
      new_balance: newBalance,
      credits_added: creditAmount,
    })
  } catch (error: any) {
    console.error('[brand/credits/verify POST] failed:', error)
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
