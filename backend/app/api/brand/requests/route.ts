import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createCollabRequestSchema } from '@/lib/validators'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get all requests sent by this brand
    const { data: requests, error } = await supabase
      .from('collab_requests')
      .select(`
        *,
        creator:creator_profiles!collab_requests_creator_id_fkey (
          id,
          bio,
          niches,
          platforms,
          followers_count,
          avg_rating,
          tier
        )
      `)
      .eq('brand_id', user.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ requests })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate request data
    const validatedData = createCollabRequestSchema.parse(body)

    // Check if brand has enough credits
    const { data: brandProfile, error: brandError } = await supabase
      .from('brand_profiles')
      .select('credits_balance')
      .eq('id', user.id)
      .single()

    if (brandError || !brandProfile) {
      return NextResponse.json({ error: 'Brand profile not found' }, { status: 404 })
    }

    if (brandProfile.credits_balance < 1) {
      return NextResponse.json(
        { error: 'Insufficient credits', required: 1, current: brandProfile.credits_balance },
        { status: 400 }
      )
    }

    // Deduct 1 credit
    const newCredits = brandProfile.credits_balance - 1
    
    await supabase
      .from('brand_profiles')
      .update({ credits_balance: newCredits })
      .eq('id', user.id)

    // Record credit transaction
    await supabase.from('credit_transactions').insert({
      brand_id: user.id,
      type: 'deduct',
      amount: 1,
      reason: 'collab_request_sent',
      balance_after: newCredits,
    })

    // Create collab request
    const { data: collabRequest, error: requestError } = await supabase
      .from('collab_requests')
      .insert({
        brand_id: user.id,
        creator_id: validatedData.creator_id,
        collab_type: validatedData.collab_type,
        message: validatedData.message,
        budget: validatedData.budget,
        deliverables: validatedData.deliverables,
      })
      .select()
      .single()

    if (requestError) {
      return NextResponse.json({ error: requestError.message }, { status: 400 })
    }

    // Notify creator
    await supabase.from('notifications').insert({
      user_id: validatedData.creator_id,
      type: 'collab_request',
      title: 'New Collab Request',
      body: 'A brand sent you a collaboration request',
      reference_id: collabRequest.id,
      reference_type: 'request',
    })

    return NextResponse.json({ 
      message: 'Request sent successfully',
      request: collabRequest,
      credits_remaining: newCredits,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
