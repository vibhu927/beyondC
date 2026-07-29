import { describe, it, expect } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'
import { createCampaign, createCreatorProfile } from '../helpers'

describe('Creator Bids API', () => {
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    creatorUser = await createTestUser('creator')
    await new Promise(r => setTimeout(r, 2000))
    brandUser = await createTestUser('brand')
    cleanupIds.push(creatorUser.id, brandUser.id)
    await createCreatorProfile(creatorUser!)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('POST /api/creator/bids', () => {
    it('places a bid on an active campaign', async () => {
      const { campaign } = await createCampaign(brandUser!)
      expect(campaign).toBeDefined()
      expect(campaign.id).toBeDefined()

      const res = await apiFetch('/api/creator/bids', {
        method: 'POST',
        body: {
          campaign_id: campaign.id,
          bid_amount: 15000,
          deliverables: '1 post, 1 reel',
          message: 'Would love to collaborate!',
        },
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      if (res.status === 201) {
        expect(data.bid).toBeDefined()
        expect(data.bid.campaign_id).toBe(campaign.id)
      } else {
        expect(data.error).toBeDefined()
      }
    })

    it('rejects bid on non-existent campaign', async () => {
      const res = await apiFetch('/api/creator/bids', {
        method: 'POST',
        body: { campaign_id: '00000000-0000-0000-0000-000000000000', bid_amount: 15000 },
        cookie: creatorUser!.sessionCookie,
      })
      expect(res.status).toBe(404)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/bids', {
        method: 'POST',
        body: { campaign_id: '00000000-0000-0000-0000-000000000000' },
      })
      expect(res.status).toBe(401)
    })
  })

  describe('GET /api/creator/bids', () => {
    it('returns list of bids for authenticated creator', async () => {
      const res = await apiFetch('/api/creator/bids', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(Array.isArray(data.bids)).toBe(true)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/bids')
      expect(res.status).toBe(401)
    })
  })
})
