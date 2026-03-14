import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { actionSchema } from '@/lib/validators'
import { getCollabFee } from '@/lib/collabFee'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get all bids for this campaign
    const { data: bids, error } = await supabase
      .from('bids')
      .select(`
        *,
        creator:creator_profiles!bids_creator_id_fkey (
          id,
          bio,
          niches,
          platforms,
          followers_count,
          avg_rating,
          tier
        )
      `)
      .eq('campaign_id', params.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    // Verify brand owns this campaign
    const { data: campaign } = await supabase
      .from('campaigns')
      .select('brand_id')
      .eq('id', params.id)
      .single()

    if (!campaign || campaign.brand_id !== user.id) {
      return NextResponse.json({ error: 'Campaign not found' }, { status: 404 })
    }

    return NextResponse.json({ bids })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
