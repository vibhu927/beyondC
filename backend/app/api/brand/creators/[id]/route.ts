import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'

export async function GET(
  _request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const supabase = createClient()
    const service = createServiceClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { id } = await params

    const { data: cp, error: cpError } = await supabase
      .from('creator_profiles')
      .select('*')
      .eq('id', id)
      .single()

    if (cpError || !cp) {
      return NextResponse.json({ error: 'Creator not found' }, { status: 404 })
    }

    // Use service client to bypass RLS on profiles (brand cannot read other users' profile rows)
    const { data: p } = await service
      .from('profiles')
      .select('first_name, full_name, avatar_url, state, city')
      .eq('id', id)
      .single()

    const { data: collab } = await supabase
      .from('collabs')
      .select('id')
      .eq('brand_id', user.id)
      .eq('creator_id', id)
      .in('status', ['active', 'in_progress', 'completed'])
      .maybeSingle()

    const hasCollab = !!collab

    const creator = {
      id: cp.id,
      first_name: p?.first_name || 'Creator',
      full_name: p?.full_name || p?.first_name || 'Creator',
      avatar_url: p?.avatar_url || null,
      bio: cp.bio,
      tier: cp.tier || null,
      starting_price: cp.starting_price || null,
      niches: cp.niche || [],
      content_types: cp.content_type || [],
      state: p?.state || null,
      city: p?.city || null,
      instagram_verified: !!cp.instagram_verified,
      followers_count: cp.followers_count ?? cp.follower_count ?? null,
      engagement_rate: cp.engagement_rate ? Number(cp.engagement_rate) : null,
      avg_rating: cp.avg_rating ? Number(cp.avg_rating) : null,
      total_collabs: cp.total_collabs || 0,
      portfolio_links: cp.portfolio_links || [],
      posts_count: cp.posts_count || null,
      avg_video_views: cp.avg_video_views || null,
      instagram_username: hasCollab ? (cp.instagram_username || null) : null,
    }

    return NextResponse.json({ creator })
  } catch (err) {
    console.error('Error fetching creator detail:', err)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}
