import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Creator Collabs API', () => {
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    creatorUser = await createTestUser('creator')
    cleanupIds.push(creatorUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/creator/collabs', () => {
    it('returns collabs for authenticated creator', async () => {
      const res = await apiFetch('/api/creator/collabs', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.collabs)).toBe(true)
    })

    it('returns active collabs by default', async () => {
      const res = await apiFetch('/api/creator/collabs', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      for (const c of data.collabs) {
        expect(['active', 'in_progress']).toContain(c.status)
      }
    })

    it('enriches collabs with brand_name and campaign_title', async () => {
      const res = await apiFetch('/api/creator/collabs', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      for (const c of data.collabs) {
        expect(c.brand_name).toBeDefined()
        expect(c.campaign_title).toBeDefined()
      }
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/collabs')
      expect(res.status).toBe(401)
    })
  })
})
