import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient, createClient } from '@/lib/supabase/server'
import { createCreditPurchaseSchema } from '@/lib/validators'
import { getRazorpay } from '@/lib/razorpay'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: agencyProfile, error: profileError } = await supabase
      .from('agency_profiles')
      .select('credit_balance')
      .eq('id', user.id)
      .maybeSingle()

    if (profileError) {
      return NextResponse.json({ error: profileError.message }, { status: 400 })
    }

    if (!agencyProfile) {
      return NextResponse.json({ error: 'Agency not found' }, { status: 404 })
    }

    return NextResponse.json({
      balance: agencyProfile?.credit_balance ?? 0,
      transactions: [],
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

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'agency') {
      return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })
    }

    const { pack } = createCreditPurchaseSchema.parse(body)

    const CREDIT_PACKS: Record<string, { credits: number; amount: number }> = {
      starter: { credits: 3, amount: 14900 },
      growth: { credits: 7, amount: 29900 },
      pro: { credits: 12, amount: 49900 },
    }

    const selectedPack = CREDIT_PACKS[pack]
    if (!selectedPack) {
      return NextResponse.json({ error: 'Invalid credit pack' }, { status: 400 })
    }

    const receipt = `ag_${user.id.slice(0, 8)}_${Date.now().toString(36)}`

    const order = await razorpay.orders.create({
      amount: selectedPack.amount,
      currency: 'INR',
      receipt,
      notes: {
        agency_id: user.id,
        type: 'credit_purchase',
        pack,
        credits: selectedPack.credits,
      },
    })

    return NextResponse.json({
      order_id: order.id,
      amount: order.amount,
      currency: order.currency,
      credits: selectedPack.credits,
      key_id: process.env.RAZORPAY_KEY_ID || process.env.NEXT_PUBLIC_RAZORPAY_KEY_ID,
    })
  } catch (error: any) {
    const message =
      error?.error?.description ||
      error?.description ||
      error?.message ||
      'Failed to create credit order'

    console.error('[agency/credits POST] failed:', error)
    return NextResponse.json({ error: message }, { status: 400 })
  }
}