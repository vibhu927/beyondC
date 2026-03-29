import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createCreditPurchaseSchema } from '@/lib/validators'
import { getRazorpay } from '@/lib/razorpay'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get credits balance
    let { data: brandProfile, error: profileError } = await supabase
      .from('brand_profiles')
      .select('credit_balance')
      .eq('id', user.id)
      .maybeSingle()

    if (profileError) {
      return NextResponse.json({ error: profileError.message }, { status: 400 })
    }

    if (!brandProfile) {
      const { data: profile } = await supabase
        .from('profiles')
        .select('full_name,display_name,email')
        .eq('id', user.id)
        .maybeSingle()

      const fallbackBrandName = profile?.full_name || profile?.display_name || profile?.email?.split('@')?.[0] || 'Brand'

      const created = await supabase
        .from('brand_profiles')
        .insert({
          id: user.id,
          brand_name: fallbackBrandName,
          credit_balance: 0,
        })
        .select('credit_balance')
        .single()

      if (created.error) {
        return NextResponse.json({ error: created.error.message }, { status: 400 })
      }

      brandProfile = created.data
    }

    // Get recent transactions
    const { data: transactions, error: txnError } = await supabase
      .from('credit_transactions')
      .select('*')
      .eq('brand_id', user.id)
      .order('created_at', { ascending: false })
      .limit(20)

    if (txnError) {
      return NextResponse.json({ error: txnError.message }, { status: 400 })
    }

    return NextResponse.json({
      balance: brandProfile?.credit_balance ?? 0,
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
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate credit pack
    const { pack } = createCreditPurchaseSchema.parse(body)

    // Define credit packs (amount in paise)
    const CREDIT_PACKS: Record<string, { credits: number; amount: number }> = {
      starter: { credits: 3, amount: 14900 }, // ₹149
      growth: { credits: 7, amount: 29900 }, // ₹299
      pro: { credits: 12, amount: 49900 }, // ₹499
    }

    const selectedPack = CREDIT_PACKS[pack]
    if (!selectedPack) {
      return NextResponse.json({ error: 'Invalid credit pack' }, { status: 400 })
    }

    // Create Razorpay order
    const order = await razorpay.orders.create({
      amount: selectedPack.amount,
      currency: 'INR',
      receipt: `credits_${user.id}_${Date.now()}`,
      notes: {
        brand_id: user.id,
        type: 'credit_purchase',
        pack,
        credits: selectedPack.credits,
      },
    })

    // Store pending transaction
    await supabase.from('credit_transactions').insert({
      brand_id: user.id,
      type: 'topup',
      amount: selectedPack.credits,
      reason: 'credit_purchase_pending',
      reference_id: order.id,
      balance_after: 0, // Will be updated on verification
    })

    return NextResponse.json({
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
      credits: selectedPack.credits,
      key_id: process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
