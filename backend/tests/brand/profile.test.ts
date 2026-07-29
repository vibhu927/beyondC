import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Brand Profile API', () => {
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    brandUser = await createTestUser('brand')
    cleanupIds.push(brandUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/brand/profile', () => {
    it('returns brand profile with auto-created brand_profiles', async () => {
      const res = await apiFetch('/api/brand/profile', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.profile).toBeDefined()
      expect(data.profile.brand).toBeDefined()
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/profile')
      expect(res.status).toBe(401)
    })
  })

  describe('PUT /api/brand/profile', () => {
    it('updates brand profile fields', async () => {
      const res = await apiFetch('/api/brand/profile', {
        method: 'PUT',
        body: {
          brand_name: 'Updated Brand Inc',
          brand_category: 'tech',
          description: 'We are a tech company',
          state: 'Karnataka',
          city: 'Bangalore',
        },
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.profile).toBeDefined()
    })

    it('accepts partial update', async () => {
      const res = await apiFetch('/api/brand/profile', {
        method: 'PUT',
        body: { description: 'Just description update' },
        cookie: brandUser!.sessionCookie,
      })
      expect(res.status).toBe(200)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/profile', {
        method: 'PUT',
        body: { brand_name: 'test' },
      })
      expect(res.status).toBe(401)
    })
  })
})
