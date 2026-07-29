import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Creator Profile API', () => {
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    creatorUser = await createTestUser('creator')
    cleanupIds.push(creatorUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/creator/profile', () => {
    it('returns creator profile when authenticated', async () => {
      const res = await apiFetch('/api/creator/profile', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.profile).toBeDefined()
      expect(data.profile.id).toBe(creatorUser!.id)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/profile')
      expect(res.status).toBe(401)
    })
  })

  describe('PUT /api/creator/profile', () => {
    it('updates creator profile fields', async () => {
      const res = await apiFetch('/api/creator/profile', {
        method: 'PUT',
        body: {
          display_name: 'Updated Creator',
          bio: 'Updated bio',
          niches: ['tech', 'gaming'],
          platforms: ['instagram', 'youtube'],
          starting_price: 10000,
          state: 'Maharashtra',
          city: 'Mumbai',
        },
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.message).toContain('updated')
    })

    it('accepts partial update', async () => {
      const res = await apiFetch('/api/creator/profile', {
        method: 'PUT',
        body: { bio: 'Just bio update' },
        cookie: creatorUser!.sessionCookie,
      })
      expect(res.status).toBe(200)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/profile', {
        method: 'PUT',
        body: { bio: 'test' },
      })
      expect(res.status).toBe(401)
    })
  })
})
