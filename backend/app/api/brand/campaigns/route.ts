import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createCampaignSchema, updateCampaignSchema } from '@/lib/validators'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const status = searchParams.get('status')

    let query = supabase
      .from('campaigns')
      .select('*, bids:bids(count)')
      .eq('brand_id', user.id)
      .order('created_at', { ascending: false })

    if (status && ['draft', 'active', 'closed'].includes(status)) {
      query = query.eq('status', status)
    }

    const { data: campaigns, error } = await query

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ campaigns })
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

    // Validate campaign data
    const validatedData = createCampaignSchema.parse(body)

    // Create campaign
    const { data: campaign, error } = await supabase
      .from('campaigns')
      .insert({
        brand_id: user.id,
        ...validatedData,
      })
      .select()
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ campaign })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
