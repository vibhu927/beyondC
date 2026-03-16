import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase/server'
import { signupSchema } from '@/lib/validators'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    
    // Validate request body
    const validatedData = signupSchema.parse(body)
    const { email, password, role, display_name } = validatedData

    const supabase = createAdminClient()

    // Create user in Supabase Auth using service role to avoid email rate-limit
    // in local/dev onboarding flows.
    const { data, error } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: {
        role,
        display_name,
      },
    })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    // The trigger will automatically create the profile and role-specific profile

    return NextResponse.json(
      {
        user: data.user,
        session: null,
        message: 'Signup successful. Please log in.',
      },
      { status: 201 }
    )
  } catch (error: any) {
    console.error('Signup error:', error)
    return NextResponse.json(
      { error: error.message || 'Signup failed' },
      { status: 400 }
    )
  }
}
