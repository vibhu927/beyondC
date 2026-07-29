import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { createServiceClient } from '@/lib/supabase/service'

export async function GET() {
  try {
    const supabase = createClient()
    const service = createServiceClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: saved, error } = await supabase
      .from('saved_creators')
      .select('id, creator_id, created_at')
      .eq('brand_id', user.id)
      .order('created_at', { ascending: false })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const creatorIds = (saved || []).map((s) => s.creator_id)

    // Fetch creator_profiles with anon client (brands can read via RLS)
    const { data: creatorProfiles, error: cpError } = await supabase
      .from('creator_profiles')
      .select('id, niche, tier, follower_count, engagement_rate, starting_price')
      .in('id', creatorIds)

    if (cpError) {
      return NextResponse.json({ error: cpError.message }, { status: 400 })
    }

    // Fetch profile names/avatars with service client (bypasses RLS that blocks brands from reading other users' profiles)
    const { data: profileData } = creatorIds.length
      ? await service
          .from('profiles')
          .select('id, first_name, full_name, avatar_url, state, city')
          .in('id', creatorIds)
      : { data: [] as any[] }

    const creatorProfileMap = new Map<string, any>((creatorProfiles || []).map((c) => [c.id, c]))
    const profileMap = new Map<string, any>((profileData || []).map((p) => [p.id, p]))

    const flattened = (saved || []).map((item) => {
      const cp = creatorProfileMap.get(item.creator_id) || {}
      const p = profileMap.get(item.creator_id) || {}
      return {
        id: item.id,
        creator_id: item.creator_id,
        created_at: item.created_at,
        creator_first_name: p.first_name || 'Creator',
        creator_full_name: p.full_name || p.first_name || 'Creator',
        creator_tier: cp.tier || null,
        creator_followers: cp.follower_count ?? null,
        creator_niches: cp.niche || [],
        creator_avatar_url: p.avatar_url || null,
        creator_starting_price: cp.starting_price ?? null,
        creator_engagement_rate: cp.engagement_rate ?? null,
        creator_state: p.state || null,
        creator_city: p.city || null,
      }
    })

    return NextResponse.json({ saved_creators: flattened })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { creator_id } = body
    if (!creator_id) {
      return NextResponse.json({ error: 'creator_id is required' }, { status: 400 })
    }

    const { data, error } = await supabase
      .from('saved_creators')
      .upsert({
        brand_id: user.id,
        creator_id,
      }, {
        onConflict: 'brand_id,creator_id',
        ignoreDuplicates: true,
      })
      .select()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    const saved = data?.[0] || { brand_id: user.id, creator_id }
    return NextResponse.json({ saved_creator: saved })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
