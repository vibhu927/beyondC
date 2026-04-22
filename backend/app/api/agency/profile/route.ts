import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    let { data: profile, error } = await supabase
      .from('profiles')
      .select(`*, agency:agency_profiles (*)`)
      .eq('id', user.id)
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    if (profile?.role !== 'agency') {
      return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })
    }

    const currentAgency = Array.isArray(profile?.agency) ? profile.agency[0] : profile?.agency

    if (!currentAgency) {
      const fallbackName = profile?.full_name || profile?.display_name || profile?.email?.split('@')?.[0] || 'Agency'

      const { error: createError } = await supabase
        .from('agency_profiles')
        .insert({ id: user.id, agency_name: fallbackName, credit_balance: 0 })

      if (createError) {
        return NextResponse.json({ error: createError.message }, { status: 400 })
      }

      const refetch = await supabase
        .from('profiles')
        .select(`*, agency:agency_profiles (*)`)
        .eq('id', user.id)
        .single()

      profile = refetch.data
      error = refetch.error

      if (error) return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ profile })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const supabase = createClient()
    const body = await request.json()

    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    const { data: profileRow } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()

    if (profileRow?.role !== 'agency') {
      return NextResponse.json({ error: 'Forbidden: not an agency' }, { status: 403 })
    }

    const profileFields: any = {}
    const agencyFields: any = {}

    if (body.display_name !== undefined) profileFields.display_name = body.display_name
    if (body.avatar_url !== undefined) profileFields.avatar_url = body.avatar_url
    if (body.state !== undefined) profileFields.state = body.state
    if (body.city !== undefined) profileFields.city = body.city
    if (body.onboarded !== undefined) profileFields.onboarded = body.onboarded

    if (body.agency_name !== undefined) agencyFields.agency_name = body.agency_name
    if (body.tagline !== undefined) agencyFields.tagline = body.tagline
    if (body.description !== undefined) agencyFields.description = body.description
    if (body.logo_url !== undefined) agencyFields.logo_url = body.logo_url
    if (body.website !== undefined) agencyFields.website = body.website
    if (body.gst_number !== undefined) agencyFields.gst_number = body.gst_number
    if (body.niche !== undefined) agencyFields.niche = body.niche
    if (body.instagram_handle !== undefined) agencyFields.instagram_handle = body.instagram_handle
    if (body.youtube_channel !== undefined) agencyFields.youtube_channel = body.youtube_channel
    if (body.size !== undefined) agencyFields.size = body.size

    if (Object.keys(profileFields).length > 0) {
      const { error: profileError } = await supabase
        .from('profiles')
        .update(profileFields)
        .eq('id', user.id)

      if (profileError) return NextResponse.json({ error: profileError.message }, { status: 400 })
    }

    if (Object.keys(agencyFields).length > 0) {
      const { error: agencyError } = await supabase
        .from('agency_profiles')
        .update(agencyFields)
        .eq('id', user.id)

      if (agencyError) return NextResponse.json({ error: agencyError.message }, { status: 400 })
    }

    const { data: profile, error } = await supabase
      .from('profiles')
      .select(`*, agency:agency_profiles (*)`)
      .eq('id', user.id)
      .single()

    if (error) return NextResponse.json({ error: error.message }, { status: 400 })

    return NextResponse.json({ profile })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
