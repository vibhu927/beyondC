import { NextRequest, NextResponse } from 'next/server'
import { scrapeAndUpdateProfile } from '@/lib/instagram/scrape-profile'

export const runtime = 'nodejs'

const INTERNAL_SECRET = process.env.INTERNAL_API_SECRET

type ScrapeBody = {
  userId?: string
  username?: string
  role?: string
}

export async function POST(request: NextRequest) {
  const authHeader = request.headers.get('x-internal-secret')

  if (!INTERNAL_SECRET || authHeader !== INTERNAL_SECRET) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }

  const body = (await request.json()) as ScrapeBody
  const userId = body.userId?.trim()
  const username = body.username?.trim().replace(/^@+/, '')

  if (!userId || !username) {
    return NextResponse.json({ error: 'userId and username required' }, { status: 400 })
  }

  const result = await scrapeAndUpdateProfile(userId, username, body.role || 'creator')

  return NextResponse.json(
    result.success
      ? { success: true, stats: result.stats }
      : { success: false, error: result.error, error_code: result.error_code },
    { status: result.statusCode ?? (result.success ? 200 : 400) }
  )
}
