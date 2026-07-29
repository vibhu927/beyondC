import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'
import { createCampaign } from '../helpers'

describe('Creator Campaigns API', () => {
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    creatorUser = await createTestUser('creator')
    await new Promise(r => setTimeout(r, 2000))
    brandUser = await createTestUser('brand')
    cleanupIds.push(creatorUser.id, brandUser.id)
    await createCampaign(brandUser!)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/creator/campaigns', () => {
    it('returns active campaigns with brand info', async () => {
      const res = await apiFetch('/api/creator/campaigns', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.campaigns)).toBe(true)
      expect(data.pagination).toBeDefined()
      expect(typeof data.pagination.total).toBe('number')
    })

    it('filters by niche', async () => {
      const res = await apiFetch('/api/creator/campaigns?niche=tech', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
    })

    it('supports pagination', async () => {
      const res = await apiFetch('/api/creator/campaigns?page=1&limit=5', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.pagination.page).toBe(1)
      expect(data.pagination.limit).toBe(5)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/campaigns')
      expect(res.status).toBe(401)
    })
  })
})
