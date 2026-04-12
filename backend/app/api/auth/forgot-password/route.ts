import { NextRequest, NextResponse } from 'next/server'

import { emailService } from '@/lib/email/email-service'
import { createServiceClient } from '@/lib/supabase/service'

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const email = String(body.email || '').trim().toLowerCase()

    if (!email) {
      return NextResponse.json({ error: 'Email required' }, { status: 400 })
    }

    const service = createServiceClient()

    const { data: profile } = await service
      .from('profiles')
      .select('first_name,email')
      .eq('email', email)
      .maybeSingle()

    const { data: linkData, error } = await service.auth.admin.generateLink({
      type: 'recovery',
      email,
      options: {
        redirectTo: `${process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000'}/reset-password?flow=recovery`,
      },
    })

    if (error || !linkData?.properties?.action_link) {
      const reason = (error?.message || '').toLowerCase()
      // Keep non-enumeration behavior for unknown emails.
      if (
        reason.includes('user not found') ||
        reason.includes('invalid email') ||
        reason.includes('no user')
      ) {
        return NextResponse.json({ success: true })
      }

      return NextResponse.json({ error: 'Could not generate reset link' }, { status: 500 })
    }

    await emailService.sendForgotPassword({
      to: email,
      firstName: profile?.first_name || 'there',
      resetLink: linkData.properties.action_link,
    })

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('[auth/forgot-password] delivery failed', error)
    return NextResponse.json(
      { error: 'Could not send reset email. Please try again shortly.' },
      { status: 500 },
    )
  }
}
