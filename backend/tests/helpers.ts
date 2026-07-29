import { apiFetch } from './setup'
import type { TestUser } from './setup'

export function randomId(): string {
  return Math.random().toString(36).slice(2, 10)
}

export function makeCampaignPayload(overrides: Record<string, any> = {}) {
  return {
    title: `Test Campaign ${randomId()}`,
    description: 'Test campaign description',
    niche: ['fashion', 'lifestyle'],
    collab_type: 'paid' as const,
    budget_min: 10000,
    budget_max: 50000,
    deliverables: ['1 post', '1 story'],
    slots: 3,
    deadline: new Date(Date.now() + 86400000 * 7).toISOString(),
    status: 'active' as const,
    ...overrides,
  }
}

export async function createCampaign(
  brandUser: TestUser,
  overrides: Record<string, any> = {}
) {
  const payload = makeCampaignPayload(overrides)
  const res = await apiFetch('/api/brand/campaigns', {
    method: 'POST',
    body: payload,
    cookie: brandUser.sessionCookie,
  })
  const data = await res.json()
  return { response: res, campaign: data.campaign }
}

export async function createCreatorProfile(
  creatorUser: TestUser,
  overrides: Record<string, any> = {}
) {
  const res = await apiFetch('/api/creator/profile', {
    method: 'PUT',
    body: {
      display_name: `Creator ${randomId()}`,
      bio: 'Test creator',
      niches: ['fashion', 'lifestyle'],
      platforms: ['instagram'],
      starting_price: 5000,
      state: 'Maharashtra',
      city: 'Mumbai',
      ...overrides,
    },
    cookie: creatorUser.sessionCookie,
  })
  return { response: res }
}

export async function createBrandProfile(
  brandUser: TestUser,
  overrides: Record<string, any> = {}
) {
  const res = await apiFetch('/api/brand/profile', {
    method: 'PUT',
    body: {
      display_name: `Brand ${randomId()}`,
      brand_name: `Test Brand ${randomId()}`,
      brand_category: 'fashion',
      description: 'A test brand',
      state: 'Maharashtra',
      city: 'Mumbai',
      ...overrides,
    },
    cookie: brandUser.sessionCookie,
  })
  return { response: res }
}

export async function fetchJson(
  path: string,
  options: { method?: string; body?: any; cookie?: string } = {}
) {
  const res = await apiFetch(path, options)
  const data = await res.json()
  return { response: res, data }
}
