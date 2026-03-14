import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'
import { createAdminClient } from '@/lib/supabase/server'

const webSignupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  role: z.enum(['creator', 'brand']),
  first_name: z.string().min(1),
  full_name: z.string().min(1),
  phone: z.string().min(10),

  // Creator fields
  instagram_handle: z.string().nullable().optional(),
  primary_niche: z.string().optional(),
  content_type: z.array(z.string()).optional(),
  starting_price: z.number().int().positive().optional(),

  // Brand fields
  brand_name: z.string().optional(),
  brand_category: z.string().optional(),
  website: z.string().url().nullable().optional(),
  gst_number: z.string().nullable().optional(),
  description: z.string().optional(),
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const parsed = webSignupSchema.parse(body)

    if (parsed.role === 'creator') {
      if (!parsed.primary_niche) {
        return NextResponse.json({ error: 'Primary niche is required for creators.' }, { status: 400 })
      }
      if (!parsed.content_type || parsed.content_type.length === 0) {
        return NextResponse.json({ error: 'Select at least one content type.' }, { status: 400 })
      }
      if (!parsed.starting_price) {
        return NextResponse.json({ error: 'Starting price is required for creators.' }, { status: 400 })
      }
    }

    if (parsed.role === 'brand') {
      if (!parsed.brand_name?.trim()) {
        return NextResponse.json({ error: 'Brand name is required for brands.' }, { status: 400 })
      }
      if (!parsed.brand_category?.trim()) {
        return NextResponse.json({ error: 'Brand category is required for brands.' }, { status: 400 })
      }
      if (!parsed.description?.trim()) {
        return NextResponse.json({ error: 'Brand description is required for brands.' }, { status: 400 })
      }
    }

    const supabase = createAdminClient()

    const { data: createUserData, error: createUserError } = await supabase.auth.admin.createUser({
      email: parsed.email,
      password: parsed.password,
      email_confirm: true,
      user_metadata: {
        role: parsed.role,
        first_name: parsed.first_name,
        full_name: parsed.full_name,
        brand_name: parsed.brand_name,
      },
    })

    if (createUserError || !createUserData.user) {
      return NextResponse.json(
        { error: createUserError?.message || 'Could not create user.' },
        { status: 400 }
      )
    }

    const userId = createUserData.user.id

    const { error: profileError } = await supabase
      .from('profiles')
      .update({
        role: parsed.role,
        first_name: parsed.first_name,
        full_name: parsed.full_name,
        email: parsed.email,
        phone: parsed.phone,
        is_onboarded: true,
      })
      .eq('id', userId)

    if (profileError) {
      return NextResponse.json({ error: profileError.message }, { status: 400 })
    }

    if (parsed.role === 'creator') {
      const { error: creatorError } = await supabase
        .from('creator_profiles')
        .update({
          niche: [parsed.primary_niche],
          content_type: parsed.content_type,
          instagram_handle: parsed.instagram_handle || null,
          starting_price: parsed.starting_price,
        })
        .eq('id', userId)

      if (creatorError) {
        return NextResponse.json({ error: creatorError.message }, { status: 400 })
      }
    }

    if (parsed.role === 'brand') {
      const { error: brandError } = await supabase
        .from('brand_profiles')
        .update({
          brand_name: parsed.brand_name,
          brand_category: parsed.brand_category,
          website: parsed.website || null,
          gst_number: parsed.gst_number || null,
          description: parsed.description,
        })
        .eq('id', userId)

      if (brandError) {
        return NextResponse.json({ error: brandError.message }, { status: 400 })
      }
    }

    return NextResponse.json({ success: true })
  } catch (error: unknown) {
    if (error instanceof z.ZodError) {
      const message = error.issues[0]?.message || 'Invalid request payload.'
      return NextResponse.json({ error: message }, { status: 400 })
    }

    const message = error instanceof Error ? error.message : 'Signup failed'
    return NextResponse.json({ error: message }, { status: 500 })
  }
}
