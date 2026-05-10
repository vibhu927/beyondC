import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient, createClient } from '@/lib/supabase/server'
import { getRazorpay } from '@/lib/razorpay'
import crypto from 'crypto'

export async function POST(request: NextRequest) {
  try {
    const razorpay = getRazorpay()
    const supabase = createClient()
    const adminClient = createAdminClient()
    const body = await request.json()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = body

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
      return NextResponse.json({ error: 'Missing payment verification details' }, { status: 400 })
    }

    const secret = process.env.RAZORPAY_KEY_SECRET
    if (!secret) {
      return NextResponse.json({ error: 'Payment configuration error' }, { status: 500 })
    }

    const generatedSignature = crypto
      .createHmac('sha256', secret)
      .update(`${razorpay_order_id}|${razorpay_payment_id}`)
      .digest('hex')

    if (generatedSignature !== razorpay_signature) {
      return NextResponse.json({ error: 'Invalid payment signature' }, { status: 400 })
    }

    const orderDetails = await razorpay.orders.fetch(razorpay_order_id)
    const creditsPurchased = orderDetails?.notes?.credits
    const pack = orderDetails?.notes?.pack

    if (!creditsPurchased) {
      return NextResponse.json({ error: 'Could not determine credits purchased' }, { status: 400 })
    }

    const { data: agencyProfile, error: fetchError } = await supabase
      .from('agency_profiles')
      .select('credit_balance')
      .eq('id', user.id)
      .single()

    if (fetchError) {
      return NextResponse.json({ error: fetchError.message }, { status: 400 })
    }

    const currentBalance = agencyProfile?.credit_balance ?? 0
    const newBalance = currentBalance + creditsPurchased

    const { error: updateError } = await adminClient
      .from('agency_profiles')
      .update({ credit_balance: newBalance })
      .eq('id', user.id)

    if (updateError) {
      throw new Error(`Failed to update credit balance: ${updateError.message}`)
    }

    return NextResponse.json({
      message: 'Payment successful',
      credits_added: creditsPurchased,
      new_balance: newBalance,
    })
  } catch (error: any) {
    const message = error?.message || 'Payment verification failed'
    console.error('[agency/credits/verify POST] failed:', error)
    return NextResponse.json({ error: message }, { status: 400 })
  }
}