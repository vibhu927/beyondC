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
    const normalizedNiche = Array.isArray(validatedData.niche)
      ? validatedData.niche
      : [validatedData.niche]
    const normalizedBudgetMin = validatedData.budget_min ?? validatedData.budget
    const normalizedBudgetMax = validatedData.budget_max ?? validatedData.budget

    // Create campaign
    const { data: campaign, error } = await supabase
      .from('campaigns')
      .insert({
        brand_id: user.id,
        title: validatedData.title,
        description: validatedData.description,
        niche: normalizedNiche,
        collab_type: validatedData.collab_type,
        budget_min: normalizedBudgetMin,
        budget_max: normalizedBudgetMax,
        deliverables: validatedData.deliverables,
        requirements: validatedData.requirements,
        deadline: validatedData.deadline,
        slots: validatedData.slots,
        target_state: validatedData.target_state ?? null,
        target_city: validatedData.target_city ?? null,
        status: validatedData.status,
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
