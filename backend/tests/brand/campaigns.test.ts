import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

describe('Brand Campaigns API', () => {
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

  describe('POST /api/brand/campaigns', () => {
    it('creates a campaign with all fields', async () => {
      const res = await apiFetch('/api/brand/campaigns', {
        method: 'POST',
        body: {
          title: 'Test Campaign',
          description: 'A test campaign',
          niche: ['fashion', 'lifestyle'],
          collab_type: 'paid',
          budget_min: 10000,
          budget_max: 50000,
          deliverables: ['1 post', '1 story'],
          slots: 3,
          deadline: new Date(Date.now() + 86400000 * 7).toISOString(),
        },
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.campaign).toBeDefined()
      expect(data.campaign.title).toBe('Test Campaign')
      expect(data.campaign.brand_id).toBe(brandUser!.id)
    })

    it('handles niche as single string', async () => {
      const res = await apiFetch('/api/brand/campaigns', {
        method: 'POST',
        body: {
          title: 'Single Niche Campaign',
          niche: 'tech',
          collab_type: 'paid',
          deliverables: ['1 post'],
        },
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.campaign.niche)).toBe(true)
      expect(data.campaign.niche).toContain('tech')
    })

    it('handles budget field (auto-fills budget_min/budget_max)', async () => {
      const res = await apiFetch('/api/brand/campaigns', {
        method: 'POST',
        body: {
          title: 'Budget Campaign',
          niche: 'tech',
          collab_type: 'paid',
          budget: 25000,
          deliverables: ['1 post'],
        },
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.campaign.budget_min).toBe(25000)
      expect(data.campaign.budget_max).toBe(25000)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/campaigns', {
        method: 'POST',
        body: { title: 'test', niche: 'tech', collab_type: 'paid', deliverables: [] },
      })
      expect(res.status).toBe(401)
    })
  })

  describe('GET /api/brand/campaigns', () => {
    it('returns campaigns for the brand', async () => {
      const res = await apiFetch('/api/brand/campaigns', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.campaigns)).toBe(true)
      expect(data.campaigns.length).toBeGreaterThanOrEqual(1)
    })

    it('includes bid count', async () => {
      const res = await apiFetch('/api/brand/campaigns', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      for (const c of data.campaigns) {
        expect(c.bids).toBeDefined()
      }
    })
  })

  describe('PUT /api/brand/campaigns/[id]', () => {
    it('updates a campaign', async () => {
      const createRes = await apiFetch('/api/brand/campaigns', {
        method: 'POST',
        body: { title: 'Update Me', niche: 'tech', collab_type: 'paid', deliverables: ['1 post'] },
        cookie: brandUser!.sessionCookie,
      })
      const { campaign } = await createRes.json()

      const updateRes = await apiFetch(`/api/brand/campaigns/${campaign.id}`, {
        method: 'PUT',
        body: { title: 'Updated Title' },
        cookie: brandUser!.sessionCookie,
      })
      const updateData = await updateRes.json()
      expect(updateRes.status).toBe(200)
      expect(updateData.campaign.title).toBe('Updated Title')
    })
  })
})
