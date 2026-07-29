import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Brand Events API', () => {
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    brandUser = await createTestUser('brand')
    cleanupIds.push(brandUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
    cleanupIds = []
    brandUser = null
  })

  describe('POST /api/brand/events', () => {
    it('creates an event', async () => {
      const res = await apiFetch('/api/brand/events', {
        method: 'POST',
        body: {
          title: 'Test Event',
          description: 'A test event description',
          event_date: new Date(Date.now() + 86400000 * 30).toISOString(),
          city: 'Mumbai',
        },
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.event).toBeDefined()
      expect(data.event.title).toBe('Test Event')
      expect(data.event.brand_id).toBe(brandUser!.id)
    })

    it('creates an event with minimal fields', async () => {
      const res = await apiFetch('/api/brand/events', {
        method: 'POST',
        body: {
          title: 'Minimal Event',
          event_date: new Date(Date.now() + 86400000 * 30).toISOString(),
        },
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.event).toBeDefined()
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/events', {
        method: 'POST',
        body: { title: 'test', event_date: new Date().toISOString() },
      })
      expect(res.status).toBe(401)
    })
  })

  describe('GET /api/brand/events', () => {
    it('returns events for the brand', async () => {
      const res = await apiFetch('/api/brand/events', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.events)).toBe(true)
    })

    it('returns events with invite counts', async () => {
      const res = await apiFetch('/api/brand/events', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      for (const event of data.events) {
        expect(event.invites).toBeDefined()
      }
    })
  })
})
