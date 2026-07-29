import { describe, it, expect, vi } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

vi.mock('@/lib/razorpay', () => ({
  getRazorpay: () => ({
    orders: {
      create: vi.fn().mockResolvedValue({
        id: 'order_test_123456',
        amount: 100000,
        currency: 'INR',
        receipt: 'test_receipt',
      }),
    },
  }),
}))

describe('Creator Wallet API', () => {
  let creatorUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    creatorUser = await createTestUser('creator')
    cleanupIds.push(creatorUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/creator/wallet', () => {
    it('returns wallet balance and transactions', async () => {
      const res = await apiFetch('/api/creator/wallet', {
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(typeof data.balance).toBe('number')
      expect(Array.isArray(data.transactions)).toBe(true)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/creator/wallet')
      expect(res.status).toBe(401)
    })
  })

  describe('POST /api/creator/wallet', () => {
    it('creates a Razorpay order for topup', async () => {
      const res = await apiFetch('/api/creator/wallet', {
        method: 'POST',
        body: { amount: 100000 },
        cookie: creatorUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(data.order_id).toBeDefined()
      expect(data.amount).toBe(100000)
      expect(data.key_id).toBeDefined()
    })

    it('rejects topup below minimum amount', async () => {
      const res = await apiFetch('/api/creator/wallet', {
        method: 'POST',
        body: { amount: 100 },
        cookie: creatorUser!.sessionCookie,
      })
      expect(res.status).toBe(400)
    })
  })
})
