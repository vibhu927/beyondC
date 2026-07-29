import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { updateCreatorProfileSchema } from '@/lib/validators'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get creator profile with base profile data
    const { data, error } = await supabase
      .from('creator_profiles')
      .select(`
        *,
        profiles (*)
      `)
      .eq('id', user.id)
      .single()

    if (error) {
      const status = error.code === 'PGRST116' ? 404 : 400
      return NextResponse.json({ error: error.message }, { status })
    }

    return NextResponse.json({ profile: data })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate request body
    const validatedData = updateCreatorProfileSchema.parse(body)

    const normalizedDisplayName = validatedData.display_name?.trim()
    const derivedFirstName = normalizedDisplayName
      ? normalizedDisplayName.split(/\s+/).filter(Boolean)[0]
      : undefined

    // Separate profile fields from creator_profile fields
    const profileFields = {
      full_name: normalizedDisplayName,
      first_name: derivedFirstName,
      avatar_url: validatedData.avatar_url,
      state: validatedData.state,
      city: validatedData.city,
      is_onboarded: validatedData.onboarded,
    }

    const creatorFields = {
      bio: validatedData.bio,
      niches: validatedData.niches,
      platforms: validatedData.platforms,
      starting_price: validatedData.starting_price,
      youtube_handle: validatedData.youtube_handle,
      twitter_handle: validatedData.twitter_handle,
      followers_count: validatedData.followers_count,
      engagement_rate: validatedData.engagement_rate,
      portfolio_links: validatedData.portfolio_links,
    }

    // Update profiles table (filter out undefined)
    const cleanProfileFields = Object.fromEntries(
      Object.entries(profileFields).filter(([_, v]) => v !== undefined)
    )
    
    if (Object.keys(cleanProfileFields).length > 0) {
      const { error: profileError } = await supabase
        .from('profiles')
        .update(cleanProfileFields)
        .eq('id', user.id)

      if (profileError) {
        return NextResponse.json({ error: profileError.message }, { status: 400 })
      }
    }

    // Update creator_profiles table
    const cleanCreatorFields = Object.fromEntries(
      Object.entries(creatorFields).filter(([_, v]) => v !== undefined)
    )

    if (Object.keys(cleanCreatorFields).length > 0) {
      const { error: creatorError } = await supabase
        .from('creator_profiles')
        .update(cleanCreatorFields)
        .eq('id', user.id)

      if (creatorError) {
        // Backward-compatible fallback for older schema names:
        // niche/content_type/follower_count instead of niches/platforms/followers_count.
        const shouldTryLegacyFallback = /(niches|platforms|followers_count)/i.test(
          creatorError.message
        )

        if (!shouldTryLegacyFallback) {
          return NextResponse.json({ error: creatorError.message }, { status: 400 })
        }

        const legacyCreatorFields = {
          bio: validatedData.bio,
          niche: validatedData.niches,
          content_type: validatedData.platforms,
          starting_price: validatedData.starting_price,
          youtube_handle: validatedData.youtube_handle,
          twitter_handle: validatedData.twitter_handle,
          follower_count: validatedData.followers_count,
          engagement_rate: validatedData.engagement_rate,
          portfolio_links: validatedData.portfolio_links,
        }

        const cleanLegacyCreatorFields = Object.fromEntries(
          Object.entries(legacyCreatorFields).filter(([_, v]) => v !== undefined)
        )

        const { error: legacyCreatorError } = await supabase
          .from('creator_profiles')
          .update(cleanLegacyCreatorFields)
          .eq('id', user.id)

        if (legacyCreatorError) {
          return NextResponse.json({ error: legacyCreatorError.message }, { status: 400 })
        }
      }
    }

    // Mark as onboarded if not already
    await supabase
      .from('profiles')
      .update({ is_onboarded: true })
      .eq('id', user.id)

    return NextResponse.json({ message: 'Profile updated successfully' })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
