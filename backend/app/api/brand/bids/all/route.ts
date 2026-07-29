import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(_request: NextRequest) {
  try {
    const supabase = createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: campaigns } = await supabase
      .from('campaigns')
      .select('id, title')
      .eq('brand_id', user.id)

    if (!campaigns || campaigns.length === 0) {
      return NextResponse.json({ bids: [] })
    }

    const campaignIds = campaigns.map((c) => c.id)
    const campaignMap = new Map(campaigns.map((c) => [c.id, c.title]))

    const { data: bids, error } = await supabase
      .from('bids')
      .select('id, creator_id, campaign_id, bid_amount, message, status, created_at')
      .in('campaign_id', campaignIds)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const creatorIds = Array.from(new Set((bids ?? []).map((b) => b.creator_id).filter(Boolean)))

    const { data: creators } = creatorIds.length
      ? await supabase
          .from('creator_profiles')
          .select('id, tier, profiles!inner(first_name, avatar_url)')
          .in('id', creatorIds)
      : { data: [] as any[] }

    const creatorMap = new Map<string, any>()
    for (const c of creators || []) {
      creatorMap.set(c.id, c)
    }

    const enriched = (bids ?? []).map((bid) => {
      const cp = creatorMap.get(bid.creator_id) || {}
      const p = cp.profiles || {}
      return {
        id: bid.id,
        creator_id: bid.creator_id,
        campaign_id: bid.campaign_id,
        campaign_title: campaignMap.get(bid.campaign_id) || 'Unknown Campaign',
        bid_amount: bid.bid_amount || 0,
        message: bid.message,
        status: bid.status,
        created_at: bid.created_at,
        creator_first_name: p.first_name || 'Creator',
        creator_avatar_url: p.avatar_url || null,
        creator_tier: cp.tier || null,
      }
    })

    return NextResponse.json({ bids: enriched })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
