import { beforeAll, afterAll } from 'vitest'
import { createClient, SupabaseClient } from '@supabase/supabase-js'

const BASE_URL = 'http://localhost:3000'

let _adminClient: SupabaseClient | null = null

function getAdminClient(): SupabaseClient {
  if (!_adminClient) {
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
    const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY
    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error(
        'Missing environment variables: NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set'
      )
    }
    _adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })
  }
  return _adminClient
}

export const API_BASE = BASE_URL

export function adminClient(): SupabaseClient {
  return getAdminClient()
}

export interface TestUser {
  id: string
  email: string
  password: string
  role: 'creator' | 'brand' | 'agency'
  sessionCookie: string
}

const TEST_EMAIL_DOMAIN = 'beyondc.test'
let createdUserIds: string[] = []

function makeTestEmail(prefix: string): string {
  const ts = Date.now()
  const rand = Math.random().toString(36).slice(2, 6)
  return `${prefix}-${ts}-${rand}@${TEST_EMAIL_DOMAIN}`
}

export async function createTestUser(
  role: 'creator' | 'brand' | 'agency',
  overrides: { display_name?: string; state?: string; city?: string } = {}
): Promise<TestUser> {
  const adminClient = getAdminClient()
  const email = makeTestEmail(role)
  const password = 'TestPass123!'
  const display_name = overrides.display_name ?? `Test ${role} ${Date.now()}`

  const { data, error } = await adminClient.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: { role, display_name, state: overrides.state ?? null, city: overrides.city ?? null },
  })

  if (error || !data.user) {
    throw new Error(`Failed to create test user: ${error?.message}`)
  }

  createdUserIds.push(data.user.id)

  if (overrides.state || overrides.city) {
    await adminClient
      .from('profiles')
      .update({ state: overrides.state ?? null, city: overrides.city ?? null })
      .eq('id', data.user.id)
  }

  // Sign in to get session cookie
  const signInRes = await fetch(`${BASE_URL}/api/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  })

  if (!signInRes.ok) {
    const body = await signInRes.text()
    throw new Error(`Sign in failed: ${signInRes.status} ${body}`)
  }

  const setCookie = signInRes.headers.get('set-cookie') || ''
  const body = await signInRes.json()

  const sessionCookie =
    setCookie ||
    (body.session?.access_token
      ? `sb-access-token=${body.session.access_token}`
      : '')

  return {
    id: data.user.id,
    email,
    password,
    role,
    sessionCookie,
  }
}

export async function deleteTestUsers(ids?: string[]) {
  try {
    const adminClient = getAdminClient()
    const toDelete = ids ?? createdUserIds
    for (const id of toDelete) {
      try {
        await adminClient.auth.admin.deleteUser(id)
      } catch {
        // ignore cleanup errors
      }
    }
  } catch {
    // ignore if env vars not set
  }
  if (!ids) createdUserIds = []
}

export async function apiFetch(
  path: string,
  options: {
    method?: string
    body?: any
    cookie?: string
  } = {}
): Promise<Response> {
  const { method = 'GET', body, cookie } = options

  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  }

  if (cookie) {
    headers['Cookie'] = cookie
  }

  return fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
    redirect: 'manual',
  })
}

export async function checkServerRunning(): Promise<boolean> {
  try {
    const res = await fetch(`${BASE_URL}/api/auth/me`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    })
    return true
  } catch {
    return false
  }
}

beforeAll(async () => {
  const running = await checkServerRunning()
  if (!running) {
    throw new Error(
      `Next.js dev server is not running at ${BASE_URL}. ` +
      'Please start it with: npm run dev'
    )
  }
})

afterAll(async () => {
  await deleteTestUsers()
})
