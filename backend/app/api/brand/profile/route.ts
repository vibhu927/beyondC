import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'
import { updateBrandProfileSchema } from '@/lib/validators'

export async function GET(request: NextRequest) {
  try {
    const supabase = createClient()

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Get brand profile with all details
    const { data: profile, error } = await supabase
      .from('profiles')
      .select(`
        *,
        brand:brand_profiles (*)
      `)
      .eq('id', user.id)
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
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

    // Get current user
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return NextResponse.json({ error: 'Not authenticated' }, { status: 401 })
    }

    // Validate update data
    const validatedData = updateBrandProfileSchema.parse(body)

    // Separate profile and brand_profile fields
    const profileFields: any = {}
    const brandFields: any = {}

    if (validatedData.display_name !== undefined) profileFields.display_name = validatedData.display_name
    if (validatedData.avatar_url !== undefined) profileFields.avatar_url = validatedData.avatar_url
    if (validatedData.onboarded !== undefined) profileFields.onboarded = validatedData.onboarded

    if (validatedData.brand_name !== undefined) brandFields.brand_name = validatedData.brand_name
    if (validatedData.brand_category !== undefined) brandFields.brand_category = validatedData.brand_category
    if (validatedData.description !== undefined) brandFields.description = validatedData.description
    if (validatedData.logo_url !== undefined) brandFields.logo_url = validatedData.logo_url
    if (validatedData.website !== undefined) brandFields.website = validatedData.website
    if (validatedData.contact_email !== undefined) brandFields.contact_email = validatedData.contact_email
    if (validatedData.size !== undefined) brandFields.size = validatedData.size

    // Update profiles table
    if (Object.keys(profileFields).length > 0) {
      const { error: profileError } = await supabase
        .from('profiles')
        .update(profileFields)
        .eq('id', user.id)

      if (profileError) {
        return NextResponse.json({ error: profileError.message }, { status: 400 })
      }
    }

    // Update brand_profiles table
    if (Object.keys(brandFields).length > 0) {
      const { error: brandError } = await supabase
        .from('brand_profiles')
        .update(brandFields)
        .eq('id', user.id)

      if (brandError) {
        return NextResponse.json({ error: brandError.message }, { status: 400 })
      }
    }

    // Fetch updated profile
    const { data: profile, error } = await supabase
      .from('profiles')
      .select(`
        *,
        brand:brand_profiles (*)
      `)
      .eq('id', user.id)
      .single()

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({ profile })
  } catch (error: any) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }
}
