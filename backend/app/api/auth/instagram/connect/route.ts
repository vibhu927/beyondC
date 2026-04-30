import crypto from 'crypto'
import { NextRequest, NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

type ConnectPlatform = 'web' | 'mobile'

type OAuthState = {
  userId: string
  platform: ConnectPlatform
  issuedAt: number
}

function toBase64Url(value: string) {
  return Buffer.from(value, 'utf8').toString('base64url')
}

function signState(encodedPayload: string) {
  const stateSecret = process.env.INSTAGRAM_STATE_SECRET || process.env.INSTAGRAM_CLIENT_SECRET
  if (!stateSecret) {
    throw new Error('Missing INSTAGRAM_STATE_SECRET or INSTAGRAM_CLIENT_SECRET')
  }

  return crypto.createHmac('sha256', stateSecret).update(encodedPayload).digest('base64url')
}

export async function GET(request: NextRequest) {
  try {
    const clientId = process.env.INSTAGRAM_CLIENT_ID
    const redirectUri = process.env.INSTAGRAM_REDIRECT_URI
    const authorizeUrl = process.env.INSTAGRAM_OAUTH_AUTHORIZE_URL?.trim() || 'https://www.instagram.com/oauth/authorize'
    const scope =
      process.env.INSTAGRAM_OAUTH_SCOPE?.trim() ||
      'instagram_business_basic,instagram_business_manage_comments,instagram_business_manage_messages,instagram_business_content_publish'

    if (!clientId || !redirectUri) {
      return NextResponse.json({ error: 'Instagram OAuth env is not configured' }, { status: 500 })
    }

    const supabase = createClient()
    const {
      data: { user },
      error: authError,
    } = await supabase.auth.getUser()

    if (authError || !user) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', user.id)
      .maybeSingle()

    if (!profile || profile.role !== 'creator') {
      return NextResponse.json({ error: 'Only creators can connect Instagram' }, { status: 403 })
    }

    const requestedPlatform = request.nextUrl.searchParams.get('platform')
    const platform: ConnectPlatform = requestedPlatform === 'mobile' ? 'mobile' : 'web'

    const encodedPayload = toBase64Url(
      JSON.stringify({
        userId: user.id,
        platform,
        issuedAt: Date.now(),
      } satisfies OAuthState)
    )

    const signature = signState(encodedPayload)

    const params = new URLSearchParams({
      client_id: clientId,
      redirect_uri: redirectUri,
      scope,
      response_type: 'code',
      state: `${encodedPayload}.${signature}`,
    })

    return NextResponse.json({
      url: `${authorizeUrl}?${params.toString()}`,
    })
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Could not start Instagram OAuth flow'
    return NextResponse.json({ error: message }, { status: 500 })
  }
}
