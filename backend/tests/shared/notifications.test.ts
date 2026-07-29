import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Notifications API', () => {
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    creatorUser = await createTestUser('creator')
    cleanupIds.push(creatorUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/notifications', () => {
    it('returns notifications for the user', async () => {
      const res = await apiFetch('/api/notifications', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.notifications)).toBe(true)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/notifications')
      expect(res.status).toBe(401)
    })
  })
})
