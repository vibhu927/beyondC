import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from './setup'

describe('Auth API', () => {
  let cleanupIds: string[] = []

  afterEach(async () => {
    await deleteTestUsers(cleanupIds)
    cleanupIds = []
  })

  describe('POST /api/auth/signup', () => {
    it('creates a creator account', async () => {
      const email = `signup-creator-${Date.now()}@beyondc.test`
      const res = await apiFetch('/api/auth/signup', {
        method: 'POST',
        body: { email, password: 'TestPass123!', role: 'creator', display_name: 'Test Creator' },
      })
      const data = await res.json()
      expect(res.status).toBe(201)
      expect(data.user).toBeDefined()
      expect(data.user.email).toBe(email)
      if (data.user?.id) cleanupIds.push(data.user.id)
    })

    it('creates a brand account', async () => {
      const email = `signup-brand-${Date.now()}@beyondc.test`
      const res = await apiFetch('/api/auth/signup', {
        method: 'POST',
        body: { email, password: 'TestPass123!', role: 'brand', display_name: 'Test Brand' },
      })
      const data = await res.json()
      expect(res.status).toBe(201)
      expect(data.user).toBeDefined()
      if (data.user?.id) cleanupIds.push(data.user.id)
    })

    it('creates an agency account', async () => {
      const email = `signup-agency-${Date.now()}@beyondc.test`
      const res = await apiFetch('/api/auth/signup', {
        method: 'POST',
        body: { email, password: 'TestPass123!', role: 'agency', display_name: 'Test Agency' },
      })
      const data = await res.json()
      expect(res.status).toBe(201)
      expect(data.user).toBeDefined()
      if (data.user?.id) cleanupIds.push(data.user.id)
    })

    it('rejects duplicate email', async () => {
      const email = `dup-${Date.now()}@beyondc.test`
      const res1 = await apiFetch('/api/auth/signup', {
        method: 'POST',
        body: { email, password: 'TestPass123!', role: 'creator', display_name: 'First' },
      })
      const data1 = await res1.json()
      if (data1.user?.id) cleanupIds.push(data1.user.id)

      const res2 = await apiFetch('/api/auth/signup', {
        method: 'POST',
        body: { email, password: 'TestPass123!', role: 'brand', display_name: 'Second' },
      })
      expect(res2.status).toBe(400)
    })

    it('rejects weak password (< 8 chars)', async () => {
      const res = await apiFetch('/api/auth/signup', {
        method: 'POST',
        body: { email: `weak-${Date.now()}@beyondc.test`, password: '123', role: 'creator', display_name: 'Weak' },
      })
      expect(res.status).toBe(400)
    })

    it('rejects missing required fields', async () => {
      const res = await apiFetch('/api/auth/signup', {
        method: 'POST',
        body: { email: `missing-${Date.now()}@beyondc.test` },
      })
      expect(res.status).toBe(400)
    })
  })

  describe('POST /api/auth/login', () => {
    let creatorId: string | null = null

    it('logs in with valid credentials', async () => {
      const user = await createTestUser('creator')
      creatorId = user.id

      const res = await apiFetch('/api/auth/login', {
        method: 'POST',
        body: { email: user.email, password: user.password },
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.user).toBeDefined()
      expect(data.session).toBeDefined()
      expect(data.role).toBe('creator')
    })

    it('rejects wrong password', async () => {
      const email = `wrongpw-${Date.now()}@beyondc.test`
      const signupRes = await apiFetch('/api/auth/signup', {
        method: 'POST',
        body: { email, password: 'TestPass123!', role: 'creator', display_name: 'WrongPW' },
      })
      const signupData = await signupRes.json()
      if (signupData.user?.id) cleanupIds.push(signupData.user.id)

      const res = await apiFetch('/api/auth/login', {
        method: 'POST',
        body: { email, password: 'WrongPass999!' },
      })
      expect(res.status).toBe(401)
    })

    it('rejects non-existent email', async () => {
      const res = await apiFetch('/api/auth/login', {
        method: 'POST',
        body: { email: 'nonexistent@beyondc.test', password: 'TestPass123!' },
      })
      expect(res.status).toBe(401)
    })

    afterAll(async () => {
      if (creatorId) await deleteTestUsers([creatorId])
    })
  })

  describe('GET /api/auth/me', () => {
    it('returns current user when authenticated', async () => {
      const user = await createTestUser('brand')
      cleanupIds.push(user.id)

      const res = await apiFetch('/api/auth/me', {
        cookie: user.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.user).toBeDefined()
      expect(data.profile).toBeDefined()
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/auth/me')
      expect(res.status).toBe(401)
    })
  })
})
