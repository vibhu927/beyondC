import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'
import { actionSchema } from '@/lib/validators'
import { getCollabFee } from '@/lib/collabFee'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()
    const service = createServiceClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
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

    // Get all bids for this campaign
    const { data: bids, error } = await supabase
      .from('bids')
      .select(`
        *,
        campaign:campaigns!bids_campaign_id_fkey (
          budget,
          budget_min,
          budget_max
        ),
        creator:creator_profiles!bids_creator_id_fkey (
          id,
          bio,
          niche,
          content_type,
          platforms,
          follower_count,
          engagement_rate,
          avg_rating,
          tier
        )
      `)
      .eq('campaign_id', params.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const creatorIds = Array.from(
      new Set((bids ?? []).map((item: any) => item.creator_id).filter(Boolean))
    )

    const { data: creatorUsers } = creatorIds.length
      ? await service
          .from('profiles')
          .select('id,first_name,full_name,avatar_url')
          .in('id', creatorIds)
      : { data: [] as any[] }

    const creatorUserById = new Map((creatorUsers ?? []).map((row: any) => [row.id, row]))

    const enriched = (bids ?? []).map((item: any) => {
      const creatorUser = creatorUserById.get(item.creator_id)
      return {
        ...item,
        creator_first_name: creatorUser?.first_name ?? null,
        creator_full_name: creatorUser?.full_name ?? null,
        creator_avatar_url: creatorUser?.avatar_url ?? null,
        creator: {
          ...(item.creator ?? {}),
          first_name: creatorUser?.first_name ?? null,
          full_name: creatorUser?.full_name ?? null,
          avatar_url: creatorUser?.avatar_url ?? null,
        },
      }
    })

    return NextResponse.json({ bids: enriched })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
