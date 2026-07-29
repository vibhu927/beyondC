import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Creator Requests API', () => {
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    creatorUser = await createTestUser('creator')
    cleanupIds.push(creatorUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/creator/requests', () => {
    it('returns incoming requests for creator', async () => {
      const res = await apiFetch('/api/creator/requests', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.requests)).toBe(true)
    })

    it('returns requests with brand info', async () => {
      const res = await apiFetch('/api/creator/requests', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      for (const req of data.requests) {
        expect(req.brand).toBeDefined()
      }
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/requests')
      expect(res.status).toBe(401)
    })
  })
})
