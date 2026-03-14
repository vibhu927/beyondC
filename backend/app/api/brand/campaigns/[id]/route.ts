import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { updateCampaignSchema } from '@/lib/validators'

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate update data
    const validatedData = updateCampaignSchema.parse(body)

    // Update campaign (RLS ensures brand owns it)
    const { data: campaign, error } = await supabase
      .from('campaigns')
      .update(validatedData)
      .eq('id', params.id)
      .eq('brand_id', user.id)
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
