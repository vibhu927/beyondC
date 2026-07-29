import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

type FetchStatsBody = {
  userId?: string
  username?: string
  role?: string
}

export async function POST(request: NextRequest) {
  try {
    const supabase = createClient()

    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const body = (await request.json()) as FetchStatsBody
    const userId = body.userId?.trim()
    const username = body.username?.trim()

    if (!userId || !username) {
      return NextResponse.json({ error: 'Missing userId or username' }, { status: 400 })
    }

    if (user.id !== userId) {
      return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
    }

    const internalSecret = process.env.INTERNAL_API_SECRET
    if (!internalSecret) {
      return NextResponse.json({ error: 'INTERNAL_API_SECRET is not configured' }, { status: 500 })
    }

    const appUrl = process.env.NEXT_PUBLIC_APP_URL || request.nextUrl.origin
    const scrapeUrl = new URL('/api/instagram/scrape', appUrl)

    const scrapeResponse = await fetch(scrapeUrl.toString(), {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-internal-secret': internalSecret,
      },
      body: JSON.stringify({ userId, username, role: body.role || 'creator' }),
    })

    const result = await scrapeResponse.json()
    return NextResponse.json(result, { status: scrapeResponse.status })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Stats fetch failed'
    return NextResponse.json({ success: false, error: message }, { status: 500 })
  }
}
