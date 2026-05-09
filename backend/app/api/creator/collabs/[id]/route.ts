import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const supabase = createClient()

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: collab, error } = await supabase
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
        rating,
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
      .eq('id', params.id)
      .eq('creator_id', user.id)
      .maybeSingle()

    if (error || !collab) {
      return NextResponse.json({ error: 'Collab not found' }, { status: 404 })
    }

    const milestoneStatus = collab.content_posted
      ? 'content_posted'
      : collab.draft_submitted
          ? 'draft_submitted'
          : collab.brief_shared
              ? 'brief_reviewed'
              : null

    return NextResponse.json({
      collab: {
        ...collab,
        milestone_status: milestoneStatus,
        brand_name: collab.brand?.brand_name ?? 'Brand',
        brand_category: collab.brand?.brand_category ?? 'General',
        campaign_title: collab.campaign?.title ?? 'Campaign',
      },
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
