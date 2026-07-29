import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Brand Collabs API', () => {
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    brandUser = await createTestUser('brand')
    cleanupIds.push(brandUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/brand/collabs', () => {
    it('returns collabs for the brand', async () => {
      const res = await apiFetch('/api/brand/collabs', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.collabs)).toBe(true)
    })

    it('returns active collabs by default', async () => {
      const res = await apiFetch('/api/brand/collabs', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      for (const c of data.collabs) {
        expect(['active', 'in_progress']).toContain(c.status)
      }
    })

    it('enriches collabs with creator_name and campaign_title', async () => {
      const res = await apiFetch('/api/brand/collabs', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      for (const c of data.collabs) {
        expect(c.creator_name).toBeDefined()
        expect(c.campaign_title).toBeDefined()
      }
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/collabs')
      expect(res.status).toBe(401)
    })
  })
})
