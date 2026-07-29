import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Ratings API', () => {
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    brandUser = await createTestUser('brand')
    cleanupIds.push(brandUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('POST /api/ratings', () => {
    it('requires authentication', async () => {
      const res = await apiFetch('/api/ratings', {
        method: 'POST',
        body: { collab_id: '00000000-0000-0000-0000-000000000000', rating: 5 },
      })
      expect(res.status).toBe(401)
    })

    it('validates rating range (1-5)', async () => {
      const res = await apiFetch('/api/ratings', {
        method: 'POST',
        body: { collab_id: '00000000-0000-0000-0000-000000000000', rating: 6 },
        cookie: brandUser!.sessionCookie,
      })
      expect(res.status).toBe(400)
    })
  })
})
