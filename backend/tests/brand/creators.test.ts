import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Brand Creators Discovery API', () => {
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    brandUser = await createTestUser('brand')
    cleanupIds.push(brandUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/brand/creators', () => {
    it('returns creators list with pagination', async () => {
      const res = await apiFetch('/api/brand/creators', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.creators)).toBe(true)
      expect(data.pagination).toBeDefined()
      expect(typeof data.pagination.total).toBe('number')
    })

    it('filters by niche', async () => {
      const res = await apiFetch('/api/brand/creators?niche=fashion', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      for (const creator of data.creators) {
        if (creator.niche) {
          expect(creator.niche).toContain('fashion')
        }
      }
    })

    it('filters by tier', async () => {
      const res = await apiFetch('/api/brand/creators?tier=micro', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      for (const creator of data.creators) {
        if (creator.tier) {
          expect(creator.tier).toBe('micro')
        }
      }
    })

    it('enforces max limit of 50', async () => {
      const res = await apiFetch('/api/brand/creators?limit=100', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.pagination.limit).toBeLessThanOrEqual(50)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/creators')
      expect(res.status).toBe(401)
    })
  })
})
