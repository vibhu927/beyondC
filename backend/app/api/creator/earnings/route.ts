import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET() {
  try {
    const supabase = createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get completed collabs for this creator
    const { data: collabs, error: collabsError } = await supabase
      .from('collabs')
      .select(`
        id,
        campaign_id,
        brand_id,
        agreed_amount_paise,
        rating,
        status,
        completed_at,
        campaign:campaign_id (title),
        brand:brand_id (brand_name, brand_profiles(brand_name))
      `)
      .eq('creator_id', user.id)
      .eq('status', 'completed')
      .order('completed_at', { ascending: false })

    if (collabsError) {
      return NextResponse.json({ error: collabsError.message }, { status: 400 })
    }

    // Calculate earnings stats
    const completedCollabs = collabs ?? []
    const totalEarned = completedCollabs.reduce((sum, c) => sum + (c.agreed_amount_paise ?? 0), 0)
    const collabsCompleted = completedCollabs.length
    const ratings = completedCollabs.filter(c => c.rating != null).map(c => c.rating!)
    const avgRating = ratings.length > 0 ? ratings.reduce((a, b) => a + b, 0) / ratings.length : 0
    const totalRatings = ratings.length

    // Recent collabs
    const recentCollabs = completedCollabs.slice(0, 5).map(c => {
      const brand = c.brand as any
      const brandName = brand?.brand_profiles?.brand_name ?? brand?.brand_name ?? 'Brand'
      const campaign = c.campaign as any
      
      return {
        id: c.id,
        brand_name: brandName,
        campaign_title: campaign?.title ?? 'Campaign',
        amount_paise: c.agreed_amount_paise,
        rating: c.rating,
        completed_at: c.completed_at,
      }
    })

    return NextResponse.json({
      total_earned_paise: totalEarned,
      collabs_completed: collabsCompleted,
      avg_rating: avgRating ? Math.round(avgRating * 10) / 10 : 0,
      total_ratings: totalRatings,
      recent_collabs: recentCollabs,
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
