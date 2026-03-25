import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()
    const { searchParams } = new URL(request.url)
    const statusFilter = (searchParams.get('status') ?? '').toLowerCase()
    const statuses = statusFilter == 'completed' ? ['completed'] : ['active', 'in_progress']

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: collabs, error } = await supabase
      .from('collabs')
      .select('id,creator_id,campaign_id,status,agreed_amount,started_at,created_at')
      .eq('brand_id', user.id)
      .in('status', statuses)
      .order('created_at', { ascending: false })
      .limit(20)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const creatorIds = Array.from(new Set((collabs ?? []).map((item) => item.creator_id).filter(Boolean)))
    const campaignIds = Array.from(new Set((collabs ?? []).map((item) => item.campaign_id).filter(Boolean)))

    const [{ data: creators }, { data: campaigns }] = await Promise.all([
      creatorIds.length > 0
        ? supabase.from('profiles').select('id,first_name,full_name').in('id', creatorIds)
        : Promise.resolve({ data: [] as any[] }),
      campaignIds.length > 0
        ? supabase.from('campaigns').select('id,title').in('id', campaignIds)
        : Promise.resolve({ data: [] as any[] }),
    ])

    const creatorById = new Map((creators ?? []).map((row: any) => [row.id, row]))
    const campaignById = new Map((campaigns ?? []).map((row: any) => [row.id, row]))

    const enriched = (collabs ?? []).map((item) => {
      const creator = creatorById.get(item.creator_id)
      const campaign = campaignById.get(item.campaign_id)
      const creatorName = creator?.full_name || creator?.first_name || 'Creator'

      return {
        ...item,
        creator_name: creatorName,
        campaign_title: campaign?.title || 'Campaign',
      }
    })

    return NextResponse.json({ collabs: enriched })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
