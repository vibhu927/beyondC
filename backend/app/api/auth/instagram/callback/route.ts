import crypto from 'crypto'
import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase/server'

type OAuthState = {
  userId: string
  platform: 'web' | 'mobile'
  issuedAt: number
}

function resolveAppUrl(request: NextRequest) {
  return process.env.NEXT_PUBLIC_APP_URL || request.nextUrl.origin
}

function mobileRedirectUrl(params: Record<string, string>) {
  const url = new URL('beyondc://instagram-callback')
  Object.entries(params).forEach(([key, value]) => url.searchParams.set(key, value))
  return url.toString()
}

function webRedirectUrl(baseUrl: string, params: Record<string, string>) {
  const url = new URL('/instagram-connect', baseUrl)
  Object.entries(params).forEach(([key, value]) => url.searchParams.set(key, value))
  return url.toString()
}

function parseState(rawState: string | null): OAuthState | null {
  if (!rawState) return null

  const [encodedPayload, signature] = rawState.split('.')
  if (!encodedPayload || !signature) return null

  const stateSecret = process.env.INSTAGRAM_STATE_SECRET || process.env.INSTAGRAM_CLIENT_SECRET
  if (!stateSecret) return null

  const expectedSignature = crypto.createHmac('sha256', stateSecret).update(encodedPayload).digest('base64url')
  if (signature !== expectedSignature) return null

  const decoded = Buffer.from(encodedPayload, 'base64url').toString('utf8')
  const payload = JSON.parse(decoded) as OAuthState

  if (!payload.userId || !payload.platform || typeof payload.issuedAt !== 'number') {
    return null
  }

  const ageMs = Date.now() - payload.issuedAt
  if (ageMs < 0 || ageMs > 15 * 60 * 1000) {
    return null
  }

  return payload
}

export async function GET(request: NextRequest) {
  // Log incoming callback request for debugging
  console.log('Instagram callback request', {
    url: request.url,
    searchParams: Object.fromEntries(request.nextUrl.searchParams.entries()),
    headers: Object.fromEntries(request.headers.entries()),
  });
  const appUrl = resolveAppUrl(request)
  const code = request.nextUrl.searchParams.get('code')
  const error = request.nextUrl.searchParams.get('error')
  const state = parseState(request.nextUrl.searchParams.get('state'))

  if (error || !code || !state) {
    const fallbackUrl = webRedirectUrl(appUrl, { status: 'error' })
    return NextResponse.redirect(fallbackUrl)
  }

  const redirectTarget =
    state.platform === 'mobile'
      ? mobileRedirectUrl({ status: 'error' })
      : webRedirectUrl(appUrl, { status: 'error' })

  try {
    const clientId = process.env.INSTAGRAM_CLIENT_ID
    const clientSecret = process.env.INSTAGRAM_CLIENT_SECRET
    const redirectUri = process.env.INSTAGRAM_REDIRECT_URI

    if (!clientId || !clientSecret || !redirectUri) {
      return NextResponse.redirect(redirectTarget)
    }

    const tokenResponse = await fetch('https://api.instagram.com/oauth/access_token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        client_id: clientId,
        client_secret: clientSecret,
        grant_type: 'authorization_code',
        redirect_uri: redirectUri,
        code,
      }),
    })

    const rawTokenData = await tokenResponse.json()
    // Business Login wraps in data[0]; Basic Display returns at root
    const tokenData = rawTokenData.data?.[0] ?? rawTokenData
    const accessToken: string | undefined = tokenData.access_token

    if (!tokenResponse.ok || !accessToken) {
      return NextResponse.redirect(redirectTarget)
    }

    const profileResponse = await fetch(
      `https://graph.instagram.com/me?fields=id,username&access_token=${encodeURIComponent(accessToken)}`
    )
    const profileData = (await profileResponse.json()) as {
      id?: string | number
      username?: string
    }

    const username = profileData.username?.trim()
    const instagramUserId = String(profileData.id || tokenData.user_id || '')

    if (!profileResponse.ok || !username || !instagramUserId) {
      return NextResponse.redirect(redirectTarget)
    }

    const admin = createAdminClient()

    const { data: creatorRecord } = await admin
      .from('profiles')
      .select('id,role')
      .eq('id', state.userId)
      .eq('role', 'creator')
      .maybeSingle()

    if (!creatorRecord) {
      return NextResponse.redirect(redirectTarget)
    }

    await admin
      .from('creator_profiles')
      .update({
        instagram_username: username,
        instagram_oauth_token: accessToken,
        instagram_user_id: instagramUserId,
        instagram_verified: true,
        instagram_connected_at: new Date().toISOString(),
      })
      .eq('id', state.userId)

    const internalSecret = process.env.INTERNAL_API_SECRET
    if (internalSecret) {
      const scrapeUrl = new URL('/api/instagram/scrape', appUrl)
      void fetch(scrapeUrl.toString(), {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-internal-secret': internalSecret,
        },
        body: JSON.stringify({
          userId: state.userId,
          username,
        }),
      }).catch(() => {
        // Deliberately non-blocking. Verified status should still complete.
      })
    }

    const successUrl =
      state.platform === 'mobile'
        ? mobileRedirectUrl({ status: 'success', username })
        : webRedirectUrl(appUrl, { status: 'success', username })

    return NextResponse.redirect(successUrl)
  } catch {
    return NextResponse.redirect(redirectTarget)
  }
}
