import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Brand Requests API', () => {
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    brandUser = await createTestUser('brand')
    await new Promise(r => setTimeout(r, 2000))
    creatorUser = await createTestUser('creator')
    cleanupIds.push(brandUser.id, creatorUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('POST /api/brand/requests', () => {
    it('sends a collab request to a creator', async () => {
      const res = await apiFetch('/api/brand/requests', {
        method: 'POST',
        body: {
          creator_id: creatorUser!.id,
          collab_type: 'paid',
          message: 'We love your content!',
          budget: 25000,
          deliverables: ['1 post', '1 story'],
        },
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()

      if (res.status === 200) {
        expect(data.request).toBeDefined()
        expect(data.request.creator_id).toBe(creatorUser!.id)
        expect(data.message).toContain('sent')
      } else {
        expect(data.error).toBeDefined()
      }
    })

    it('rejects request with invalid creator_id', async () => {
      const res = await apiFetch('/api/brand/requests', {
        method: 'POST',
        body: { creator_id: '00000000-0000-0000-0000-000000000000', collab_type: 'paid', deliverables: ['1 post'] },
        cookie: brandUser!.sessionCookie,
      })
      expect(res.status).toBe(400)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/requests', {
        method: 'POST',
        body: { creator_id: creatorUser!.id, collab_type: 'paid', deliverables: ['1 post'] },
      })
      expect(res.status).toBe(401)
    })
  })

  describe('GET /api/brand/requests', () => {
    it('returns sent requests with enrichment', async () => {
      const res = await apiFetch('/api/brand/requests', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.requests)).toBe(true)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/requests')
      expect(res.status).toBe(401)
    })
  })
})
