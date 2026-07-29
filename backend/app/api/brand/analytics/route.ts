import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()
    const { searchParams } = new URL(request.url)
    const campaignId = searchParams.get('campaign_id')

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get brand's campaigns
    let campaignsQuery = supabase
      .from('campaigns')
      .select('id, title, status, niche, collab_type, budget_min, budget_max')
      .eq('brand_id', user.id)
      .order('created_at', { ascending: false })

    if (campaignId) {
      campaignsQuery = campaignsQuery.eq('id', campaignId)
    }

    const { data: campaigns, error: campaignsError } = await campaignsQuery

    if (campaignsError) {
      return NextResponse.json({ error: campaignsError.message }, { status: 400 })
    }

    // Get collabs for these campaigns
    const campaignIds = (campaigns ?? []).map(c => c.id)
    
    const { data: collabs, error: collabsError } = await supabase
      .from('collabs')
      .select('id, campaign_id, status, agreed_amount_paise, rating, completed_at')
      .in('campaign_id', campaignIds)

    if (collabsError) {
      return NextResponse.json({ error: collabsError.message }, { status: 400 })
    }

    // Get content submissions count
    const collabIds = (collabs ?? []).map(c => c.id)
    
    const { data: submissions, error: submissionsError } = await supabase
      .from('content_submissions')
      .select('collab_id, status')
      .in('collab_id', collabIds)

    if (submissionsError) {
      return NextResponse.json({ error: submissionsError.message }, { status: 400 })
    }

    // Calculate analytics
    const totalCampaigns = (campaigns ?? []).length
    const activeCampaigns = (campaigns ?? []).filter(c => c.status === 'active').length
    const completedCollabs = (collabs ?? []).filter(c => c.status === 'completed').length
    const totalSpent = (collabs ?? []).reduce((sum, c) => sum + (c.agreed_amount_paise ?? 0), 0)
    const ratings = (collabs ?? []).filter(c => c.rating != null).map(c => c.rating!)
    const avgRating = ratings.length > 0 ? ratings.reduce((a, b) => a + b, 0) / ratings.length : 0

    // Campaign-level analytics
    const campaignAnalytics = (campaigns ?? []).map(campaign => {
      const campaignCollabs = (collabs ?? []).filter(c => c.campaign_id === campaign.id)
      const campaignSubmissions = (submissions ?? []).filter(s => 
        campaignCollabs.some(c => c.id === s.collab_id)
      )
      const approvedSubmissions = campaignSubmissions.filter(s => s.status === 'approved').length
      const totalSubmissions = campaignSubmissions.length

      return {
        id: campaign.id,
        title: campaign.title,
        status: campaign.status,
        niche: campaign.niche,
        collab_type: campaign.collab_type,
        collabs_count: campaignCollabs.length,
        completed_collabs: campaignCollabs.filter(c => c.status === 'completed').length,
        total_submissions: totalSubmissions,
        approved_submissions: approvedSubmissions,
        completion_rate: totalSubmissions > 0 ? Math.round(approvedSubmissions / totalSubmissions * 100) : 0,
        avg_rating: campaignCollabs.filter(c => c.rating != null).length > 0
          ? campaignCollabs.filter(c => c.rating != null).reduce((sum, c) => sum + (c.rating ?? 0), 0) / 
            campaignCollabs.filter(c => c.rating != null).length
          : 0,
        total_spent_paise: campaignCollabs.reduce((sum, c) => sum + (c.agreed_amount_paise ?? 0), 0),
      }
    })

    return NextResponse.json({
      total_campaigns: totalCampaigns,
      active_campaigns: activeCampaigns,
      completed_collabs: completedCollabs,
      total_spent_paise: totalSpent,
      avg_rating: avgRating ? Math.round(avgRating * 10) / 10 : 0,
      campaigns: campaignAnalytics,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
