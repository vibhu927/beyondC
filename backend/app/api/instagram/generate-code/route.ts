import crypto from 'crypto'
import { NextRequest, NextResponse } from 'next/server'
import { createClient, createAdminClient } from '@/lib/supabase/server'

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()
    const admin = createAdminClient()

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const { data: userRecord } = await admin
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .in('role', ['creator', 'brand'])
      .maybeSingle()

    if (!userRecord) {
      return NextResponse.json({ error: 'Profile not found' }, { status: 404 })
    }

    const targetTable = userRecord.role === 'brand' ? 'brand_profiles' : 'creator_profiles'

    const {
      data: profile,
      error: profileError,
    } = await admin
      .from(targetTable)
      .select('instagram_verified')
      .eq('id', user.id)
      .maybeSingle()

    if (profileError) {
      console.error('[generate-code] Supabase query error:', profileError)
      return NextResponse.json({ error: 'Database error. Please try again.' }, { status: 500 })
    }

    if (!profile) {
      return NextResponse.json(
        { error: 'Profile not found. Please complete your setup first.' },
        { status: 404 }
      )
    }

    if (profile.instagram_verified) {
      return NextResponse.json({ error: 'Instagram already verified' }, { status: 400 })
    }

    const code = `BC-${crypto.randomBytes(4).toString('hex').toUpperCase()}`

    const { error: updateError } = await admin
      .from(targetTable)
      .update({ instagram_verification_code: code })
      .eq('id', user.id)

    if (updateError) {
      console.error('[generate-code] Failed to save code:', updateError)
      const isMissingColumn = updateError.message?.includes('instagram_verification_code')
      return NextResponse.json(
        {
          error: isMissingColumn
            ? 'Database setup incomplete: the verification code column is missing. Please apply the latest Supabase migration or contact support.'
            : 'Failed to save verification code. Try again.',
        },
        { status: 500 }
      )
    }

    return NextResponse.json({ code })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Could not generate code'
    console.error('[generate-code] Unexpected error:', error)
    return NextResponse.json({ error: message }, { status: 500 })
  }
}
