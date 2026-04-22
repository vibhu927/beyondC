import { NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase/server'

type SignupBody = {
  email?: string
  password?: string
  role?: 'creator' | 'brand' | 'agency'
  first_name?: string
  full_name?: string
  agency_name?: string
  contact_name?: string
  phone?: string
  state?: string
  city?: string
  niche?: string[]
  content_type?: string[]
  starting_price?: number | null
  brand_name?: string
  brand_category?: string
  website?: string | null
  gst_number?: string | null
  description?: string | null
}

export async function POST(request: Request) {
  try {
    const body = (await request.json()) as SignupBody
    const { email, password, role, first_name, full_name, phone, state, city, ...roleData } = body

    if (!email || !password || !role) {
      return NextResponse.json({ error: 'Missing required fields' }, { status: 400 })
    }

    if (password.length < 8) {
      return NextResponse.json({ error: 'Password too short' }, { status: 400 })
    }

    if (role === 'creator') {
      const creatorNiches = Array.isArray(roleData.niche) ? roleData.niche : []
      const creatorTypes = Array.isArray(roleData.content_type) ? roleData.content_type : []

      if (creatorNiches.length === 0 || creatorTypes.length === 0) {
        return NextResponse.json({ error: 'Missing required fields' }, { status: 400 })
      }
    }

    if (role === 'brand') {
      if (!roleData.brand_name?.trim() || !roleData.brand_category?.trim()) {
        return NextResponse.json({ error: 'Missing required fields' }, { status: 400 })
      }
    }

    if (role === 'agency') {
      if (!roleData.agency_name?.trim() || !roleData.contact_name?.trim()) {
        return NextResponse.json({ error: 'Missing required fields' }, { status: 400 })
      }
    }

    const supabase = createAdminClient()

    const { data: authData, error: authError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        role,
        first_name: first_name ?? null,
        full_name: full_name ?? null,
        phone: phone ?? null,
        state: state ?? null,
        city: city ?? null,
      },
    })

    if (authError || !authData.user) {
      if (authError?.message?.toLowerCase().includes('already registered')) {
        return NextResponse.json({ error: 'User already registered' }, { status: 409 })
      }
      return NextResponse.json({ error: authError?.message || 'Could not create user' }, { status: 400 })
    }

    const userId = authData.user.id

    const { error: profileError } = await supabase
      .from('profiles')
      .upsert({
        id: userId,
        role,
        first_name,
        full_name,
        email,
        phone: phone ?? null,
        state,
        city,
        is_onboarded: true,
      })

    if (profileError) {
      return NextResponse.json({ error: profileError.message }, { status: 400 })
    }

    if (role === 'creator') {
      const { error: creatorError } = await supabase.from('creator_profiles').upsert({
        id: userId,
        niche: Array.isArray(roleData.niche) ? roleData.niche : [],
        content_type: Array.isArray(roleData.content_type) ? roleData.content_type : [],
        starting_price: roleData.starting_price ?? null,
        wallet_balance: 0,
        instagram_verified: false,
        is_discoverable: false,
      })

      if (creatorError) {
        return NextResponse.json({ error: creatorError.message }, { status: 400 })
      }
    }

    if (role === 'brand') {
      const { error: brandError } = await supabase.from('brand_profiles').upsert({
        id: userId,
        brand_name: roleData.brand_name,
        brand_category: roleData.brand_category,
        website: roleData.website ?? null,
        gst_number: roleData.gst_number ?? null,
        description: roleData.description ?? null,
        credit_balance: 0,
      })

      if (brandError) {
        return NextResponse.json({ error: brandError.message }, { status: 400 })
      }
    }

    if (role === 'agency') {
      const { error: agencyError } = await supabase.from('agency_profiles').upsert({
        id: userId,
        agency_name: roleData.agency_name,
        contact_name: roleData.contact_name,
        website: roleData.website ?? null,
        phone: phone ?? null,
        credit_balance: 0,
      })

      if (agencyError) {
        return NextResponse.json({ error: agencyError.message }, { status: 400 })
      }
    }

    return NextResponse.json({ success: true }, { status: 201 })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Signup failed'
    return NextResponse.json({ error: message }, { status: 500 })
  }
}
