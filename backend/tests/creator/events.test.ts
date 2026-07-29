import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Creator Events API', () => {
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    creatorUser = await createTestUser('creator')
    cleanupIds.push(creatorUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/creator/events', () => {
    it('returns invites for the creator', async () => {
      const res = await apiFetch('/api/creator/events', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.invites)).toBe(true)
    })

    it('enriches invites with brand info', async () => {
      const res = await apiFetch('/api/creator/events', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      for (const invite of data.invites) {
        expect(invite.event).toBeDefined()
      }
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/events')
      expect(res.status).toBe(401)
    })
  })
})
