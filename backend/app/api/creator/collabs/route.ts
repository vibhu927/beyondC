import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()
    const { searchParams } = new URL(request.url)
    const statusFilter = (searchParams.get('status') ?? '').toLowerCase()
    const statuses = statusFilter === 'completed' ? ['completed'] : ['active', 'in_progress']

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: collabs, error } = await supabase
      .from('collabs')
      .select(`
        id,
        brand_id,
        creator_id,
        campaign_id,
        status,
        agreed_amount,
        collab_type,
        brief_shared,
        draft_submitted,
        draft_approved,
        content_posted,
        started_at,
        completed_at,
        created_at,
        brand:brand_profiles!collabs_brand_id_fkey (
          id,
          brand_name,
          brand_category
        ),
        campaign:campaigns!collabs_campaign_id_fkey (
          id,
          title
        )
      `)
      .eq('creator_id', user.id)
      .in('status', statuses)
      .order('created_at', { ascending: false })
      .limit(30)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const enriched = (collabs ?? []).map((item: any) => {
      const milestoneStatus = item.content_posted
        ? 'content_posted'
        : item.draft_submitted
            ? 'draft_submitted'
            : item.brief_shared
                ? 'brief_reviewed'
                : null

      return {
        ...item,
        milestone_status: milestoneStatus,
        brand_name: item.brand?.brand_name ?? 'Brand',
        brand_category: item.brand?.brand_category ?? 'General',
        campaign_title: item.campaign?.title ?? 'Campaign',
      }
    })

    return NextResponse.json({ collabs: enriched })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
