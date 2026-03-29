import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

import { emailService } from '@/lib/email/email-service'

const waitlistSchema = z.object({
  email: z.string().email(),
})

function deriveFirstNameFromEmail(email: string) {
  const localPart = email.split('@')[0] || 'there'
  const cleaned = localPart
    .replace(/[._-]+/g, ' ')
    .replace(/\d+/g, ' ')
    .trim()

  if (!cleaned) {
    return 'there'
  }

  const firstToken = cleaned.split(/\s+/)[0] || 'there'
  return firstToken.charAt(0).toUpperCase() + firstToken.slice(1).toLowerCase()
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const parsed = waitlistSchema.safeParse(body)

    if (!parsed.success) {
      return NextResponse.json({ error: 'Please enter a valid email.' }, { status: 400 })
    }

    const webhookUrl = process.env.WAITLIST_GOOGLE_SCRIPT_URL
    if (!webhookUrl) {
      return NextResponse.json(
        { error: 'Waitlist integration is not configured on the server.' },
        { status: 500 },
      )
    }

    const webhookSecret = process.env.WAITLIST_WEBHOOK_SECRET

    const payload = {
      email: parsed.data.email,
      source: 'landing_waitlist',
      timestamp: new Date().toISOString(),
      ...(webhookSecret ? { secret: webhookSecret } : {}),
    }

    const response = await fetch(webhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
        ...(webhookSecret ? { 'x-waitlist-secret': webhookSecret } : {}),
      },
      body: new URLSearchParams(payload).toString(),
      cache: 'no-store',
    })

    const upstreamBody = await response.text()

    if (!response.ok) {
      return NextResponse.json(
        {
          error: 'Could not save your email right now. Please try again.',
          details: upstreamBody.slice(0, 240),
        },
        { status: 502 },
      )
    }

    try {
      const parsedUpstream = JSON.parse(upstreamBody)
      if (parsedUpstream?.success !== true) {
        return NextResponse.json(
          {
            error: 'Waitlist script did not confirm submission.',
            details: upstreamBody.slice(0, 240),
          },
          { status: 502 },
        )
      }

      if (
        parsedUpstream?.written !== true &&
        !Number.isFinite(parsedUpstream?.rowNumber)
      ) {
        console.warn('[waitlist] upstream success without write metadata')
      }
    } catch {
      return NextResponse.json(
        {
          error: 'Waitlist script returned invalid response.',
          details: upstreamBody.slice(0, 240),
        },
        { status: 502 },
      )
    }

    let emailSent = false
    let emailErrorMessage: string | null = null
    let emailMessageId: string | null = null

    try {
      const sendResult = await emailService.sendWaitlistWelcome({
        to: parsed.data.email,
        firstName: deriveFirstNameFromEmail(parsed.data.email),
      })
      emailSent = true
      emailMessageId = sendResult.data?.id || null
    } catch (emailError) {
      console.error('[waitlist] welcome email send failed', emailError)
      emailErrorMessage = emailError instanceof Error ? emailError.message : 'Unknown email error'
    }

    return NextResponse.json({
      success: true,
      emailSent,
      ...(emailMessageId ? { emailMessageId } : {}),
      ...(!emailSent && emailErrorMessage ? { emailErrorMessage } : {}),
      message: emailSent
        ? 'You have been added to the waitlist and a confirmation email was sent.'
        : 'You have been added to the waitlist. Confirmation email could not be sent right now.',
    })
  } catch (error: any) {
    return NextResponse.json(
      { error: error?.message || 'Unexpected error' },
      { status: 500 },
    )
  }
}
