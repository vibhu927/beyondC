import { describe, it, expect, vi } from 'vitest'
import { apiFetch, createTestUser, deleteTestUsers } from '../setup'

vi.mock('@/lib/razorpay', () => ({
  getRazorpay: () => ({
    orders: {
      create: vi.fn().mockResolvedValue({
        id: 'order_credit_test_123',
        amount: 14900,
        currency: 'INR',
        receipt: 'test_credit_receipt',
      }),
    },
  }),
}))

describe('Brand Credits API', () => {
  let brandUser: Awaited<ReturnType<typeof createTestUser>> | null = null
  let cleanupIds: string[] = []

  beforeAll(async () => {
    brandUser = await createTestUser('brand')
    cleanupIds.push(brandUser.id)
  })

  afterAll(async () => {
    await deleteTestUsers(cleanupIds)
  })

  describe('GET /api/brand/credits', () => {
    it('returns balance and transactions with auto-create fallback', async () => {
      const res = await apiFetch('/api/brand/credits', {
        cookie: brandUser!.sessionCookie,
      })
      const data = await res.json()
      expect(res.status).toBe(200)
      expect(typeof data.balance).toBe('number')
      expect(Array.isArray(data.transactions)).toBe(true)
    })

    it('returns 401 when not authenticated', async () => {
      const res = await apiFetch('/api/brand/credits')
      expect(res.status).toBe(401)
    })
  })
})
