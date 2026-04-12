import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const niche = searchParams.get('niche')
    const platform = searchParams.get('platform')
    const min_followers = searchParams.get('min_followers')
    const max_followers = searchParams.get('max_followers')
    const tier = searchParams.get('tier')
    const state = searchParams.get('state')
    const city = searchParams.get('city')
    const page = parseInt(searchParams.get('page') || '1')
    const limit = Math.min(parseInt(searchParams.get('limit') || '20'), 50)
    const offset = (page - 1) * limit

    const { data: brandProfile } = await supabase
      .from('profiles')
      .select('state, city')
      .eq('id', user.id)
      .single()

    const filterState = state ?? brandProfile?.state ?? null
    const filterCity = city ?? brandProfile?.city ?? null

    const runViewQuery = async (followersColumn: 'followers_count' | 'follower_count') => {
      let query = supabase
        .from('creator_discovery_view')
        .select('*', { count: 'exact' })

      if (niche) {
        query = query.contains('niche', [niche])
      }
      if (platform) {
        query = query.contains('platforms', [platform])
      }
      if (tier && ['nano', 'micro', 'mid', 'macro', 'mega'].includes(tier)) {
        query = query.eq('tier', tier)
      }
      if (min_followers) {
        query = query.gte(followersColumn, parseInt(min_followers))
      }
      if (max_followers) {
        query = query.lte(followersColumn, parseInt(max_followers))
      }
      if (state) {
        query = query.eq('state', state)
      }
      if (city) {
        query = query.eq('city', city)
      }

      query = query
        .order(followersColumn, { ascending: false })
        .range(offset, offset + limit - 1)

      return query
    }

    const locationScore = (creator: any) => {
      let score = 0
      if (filterCity && creator?.city === filterCity) score += 2
      if (filterState && creator?.state === filterState) score += 1
      return score
    }

    let creators: any[] | null = null
    let count: number | null = null

    const primary = await runViewQuery('followers_count')
    if (!primary.error) {
      creators = primary.data
      count = primary.count
    } else if ((primary.error.message || '').toLowerCase().includes('followers_count')) {
      const fallbackView = await runViewQuery('follower_count')
      if (fallbackView.error) {
        return NextResponse.json({ error: fallbackView.error.message }, { status: 400 })
      }
      creators = fallbackView.data
      count = fallbackView.count
    } else {
      return NextResponse.json({ error: primary.error.message }, { status: 400 })
    }

    // Some local/dev datasets may have creators not surfaced by creator_discovery_view
    // (for example when discoverability flags are not set yet). Fallback to direct tables.
    if ((creators ?? []).length === 0) {
      let fallbackQuery = supabase
        .from('creator_profiles')
        .select(
          `
            id,
            niche,
            content_type,
            platforms,
            tier,
            starting_price,
            avg_rating,
            total_collabs,
            engagement_rate,
            bio,
            portfolio_links,
            follower_count,
            instagram_verified,
            posts_count,
            profile:profiles!inner (
              first_name,
              avatar_url,
              is_onboarded,
              state,
              city
            )
          `,
          { count: 'exact' },
        )
        .eq('profile.is_onboarded', true)

      if (niche) {
        fallbackQuery = fallbackQuery.contains('niche', [niche])
      }
      if (platform) {
        fallbackQuery = fallbackQuery.contains('platforms', [platform])
      }
      if (tier && ['nano', 'micro', 'mid', 'macro', 'mega'].includes(tier)) {
        fallbackQuery = fallbackQuery.eq('tier', tier)
      }
      if (min_followers) {
        fallbackQuery = fallbackQuery.gte('follower_count', parseInt(min_followers))
      }
      if (max_followers) {
        fallbackQuery = fallbackQuery.lte('follower_count', parseInt(max_followers))
      }
      if (state) {
        fallbackQuery = fallbackQuery.eq('profile.state', state)
      }
      if (city) {
        fallbackQuery = fallbackQuery.eq('profile.city', city)
      }

      fallbackQuery = fallbackQuery
        .order('follower_count', { ascending: false })
        .range(offset, offset + limit - 1)

      const { data: fallbackCreators, error: fallbackError, count: fallbackCount } = await fallbackQuery

      if (fallbackError) {
        return NextResponse.json({ error: fallbackError.message }, { status: 400 })
      }

      const normalized = (fallbackCreators ?? []).map((item: any) => {
        const profile = item.profile ?? {}
        const followers = item.follower_count ?? 0

        const followerRange =
          followers < 5000
            ? '1K-5K'
            : followers < 10000
              ? '5K-10K'
              : followers < 50000
                ? '10K-50K'
                : followers < 100000
                  ? '50K-100K'
                  : followers < 500000
                    ? '100K-500K'
                    : '500K+'

        return {
          id: item.id,
          first_name: profile.first_name ?? 'Creator',
          avatar_url: profile.avatar_url ?? null,
          state: profile.state ?? null,
          city: profile.city ?? null,
          niche: item.niche ?? [],
          content_type: item.content_type ?? [],
          platforms: item.platforms ?? [],
          tier: item.tier ?? 'micro',
          starting_price: item.starting_price ?? 0,
          avg_rating: item.avg_rating ?? 0,
          total_collabs: item.total_collabs ?? 0,
          engagement_rate: item.engagement_rate ?? 0,
          bio: item.bio ?? '',
          portfolio_links: item.portfolio_links ?? [],
          follower_count: followers,
          followers_count: followers,
          follower_range: followerRange,
          instagram_verified: item.instagram_verified ?? false,
          posts_count: item.posts_count ?? 0,
        }
      })

      return NextResponse.json({
        creators: normalized.sort((a, b) => locationScore(b) - locationScore(a)),
        pagination: {
          page,
          limit,
          total: fallbackCount || 0,
          total_pages: Math.ceil((fallbackCount || 0) / limit),
        },
      })
    }

    return NextResponse.json({
      creators: (creators ?? []).sort((a, b) => locationScore(b) - locationScore(a)),
      pagination: {
        page,
        limit,
        total: count || 0,
        total_pages: Math.ceil((count || 0) / limit),
      },
    })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
