import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

const waitlistSchema = z.object({
  email: z.string().email(),
})

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

    return NextResponse.json({ success: true })
  } catch (error: any) {
    return NextResponse.json(
      { error: error?.message || 'Unexpected error' },
      { status: 500 },
    )
  }
}
