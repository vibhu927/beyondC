import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createBidSchema } from '@/lib/validators'
import { getCollabFee } from '@/lib/collabFee'

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate request body
    const validatedData = createBidSchema.parse(body)

    // Get campaign details
    const { data: campaign, error: campaignError } = await supabase
      .from('campaigns')
      .select('*, brand:brand_profiles!campaigns_brand_id_fkey(size)')
      .eq('id', validatedData.campaign_id)
      .single()

    if (campaignError || !campaign) {
      return NextResponse.json({ error: 'Campaign not found' }, { status: 404 })
    }

    if (campaign.status !== 'active') {
      return NextResponse.json({ error: 'Campaign is not active' }, { status: 400 })
    }

    // Check if creator has enough wallet balance for collab fee
    const { data: creatorProfile, error: creatorError } = await supabase
      .from('creator_profiles')
      .select('wallet_balance')
      .eq('id', user.id)
      .single()

    if (creatorError || !creatorProfile) {
      return NextResponse.json({ error: 'Creator profile not found' }, { status: 404 })
    }

    const collabFee = getCollabFee(campaign.brand.size)
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

    // Create bid
    const { data: bid, error: bidError } = await supabase
      .from('bids')
      .insert({
        campaign_id: validatedData.campaign_id,
        creator_id: user.id,
        message: validatedData.message,
      })
      .select()
      .single()

    if (bidError) {
      return NextResponse.json({ error: bidError.message }, { status: 400 })
    }

    // Create notification for brand
    await supabase.from('notifications').insert({
      user_id: campaign.brand_id,
      type: 'bid_received',
      title: 'New Bid Received',
      body: `You received a new bid on "${campaign.title}"`,
      reference_id: bid.id,
      reference_type: 'bid',
    })

    return NextResponse.json({ bid }, { status: 201 })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get all bids by creator
    const { data: bids, error } = await supabase
      .from('bids')
      .select(`
        *,
        campaign:campaigns (
          *,
          brand:brand_profiles!campaigns_brand_id_fkey (
            brand_name,
            brand_category,
            logo_url
          )
        )
      `)
      .eq('creator_id', user.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ bids })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
