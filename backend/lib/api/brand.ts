import { apiClient } from './client'

export interface BrandProfile {
  id: string
  brand_name: string
  brand_category: string
  description: string | null
  website: string | null
  gst_number: string | null
  logo_url: string | null
  credit_balance: number
  is_brand_verified: boolean
  total_collabs: number
  avg_rating: number | null
  size: 'micro' | 'mid' | 'big' | null
  portfolio_links: string[]
  avatar_url: string | null
  state: string | null
  city: string | null
  full_name: string | null
  email: string | null
  instagram_verified: boolean
  instagram_username: string | null
  followers_count: number | null
  following_count: number | null
  posts_count: number | null
  engagement_rate: number | null
  highest_video_views: number | null
  avg_video_views: number | null
  avg_likes: number | null
  avg_comments: number | null
  stats_fetched_at: string | null
}

export interface BrandCampaign {
  id: string
  title: string
  description: string
  niche: string[]
  collab_type: string
  budget_min: number | null
  budget_max: number | null
  deliverables: string[]
  slots: number
  slots_filled: number
  status: string
  deadline: string
  bid_count: number
  created_at: string
}

export interface CampaignBid {
  id: string
  creator_id: string
  creator_first_name: string
  creator_handle: string | null
  tier: string | null
  followers_count: number | null
  engagement_rate: number | null
  bid_amount: number
  message: string | null
  status: string
  is_unlocked: boolean
}

export interface CreatorPreview {
  id: string
  first_name: string
  full_name: string
  tier: string | null
  starting_price: number | null
  engagement_rate: number | null
  followers_count: number | null
  niches: string[]
  content_types: string[]
  state: string | null
  city: string | null
  instagram_verified: boolean
}

export interface BrandCollab {
  id: string
  creator_id: string
  campaign_id: string | null
  agreed_amount: number | null
  collab_type: string
  status: string
  milestone_status: string
  rating: number | null
  created_at: string
  creator_name: string
  creator_avatar: string | null
  creator_tier: string | null
  campaign_title: string | null
}

export interface CreditData {
  balance: number
  transactions: {
    id: string
    amount: number
    type: string
    reason: string
    balance_after: number
    created_at: string
  }[]
}

export interface BrandAnalytics {
  campaignStats: {
    total: number
    active: number
    completed: number
    totalSpent: number
    avgRating: number
  }
  collabStats: {
    total: number
    active: number
    completed: number
  }
  submissionStats: {
    pending: number
    approved: number
    rejected: number
  }
}

export interface BrandEvent {
  id: string
  title: string
  description: string
  event_date: string
  location: string
  total_slots: number
  accepted_count: number
  invite_count: number
  status: string
  target_niche: string[]
  target_tier: string[]
}

export interface SavedCreator {
  id: string
  creator_id: string
  creator_first_name: string
  creator_full_name: string
  creator_tier: string | null
  creator_followers: number | null
  creator_niches: string[]
  creator_avatar_url: string | null
  creator_starting_price: number | null
  creator_engagement_rate: number | null
  creator_state: string | null
  creator_city: string | null
  created_at: string
}

export interface BidWithCampaign {
  id: string
  creator_id: string
  campaign_id: string
  campaign_title: string
  bid_amount: number
  message: string | null
  status: string
  created_at: string
  creator_first_name: string
  creator_avatar_url: string | null
  creator_tier: string | null
}

export interface CreatorDetail {
  id: string
  first_name: string
  full_name: string
  avatar_url: string | null
  bio: string | null
  tier: string | null
  starting_price: number | null
  niches: string[]
  content_types: string[]
  state: string | null
  city: string | null
  instagram_verified: boolean
  followers_count: number | null
  engagement_rate: number | null
  avg_rating: number | null
  total_collabs: number
  portfolio_links: string[]
  posts_count: number | null
  avg_video_views: number | null
  instagram_username: string | null
}

export const brandApi = {
  getProfile: () =>
    apiClient<{ profile: BrandProfile }>('/api/brand/profile'),

  updateProfile: (data: Partial<BrandProfile>) =>
    apiClient<{ profile: BrandProfile }>('/api/brand/profile', {
      method: 'PUT',
      body: data,
    }),

  getCampaigns: (status?: string) =>
    apiClient<{ campaigns: BrandCampaign[] }>('/api/brand/campaigns', {
      params: { status },
    }),

  createCampaign: (data: {
    title: string
    description: string
    niche: string[]
    collab_type: string
    budget_min?: number
    budget_max?: number
    deliverables: string[]
    slots: number
    deadline: string
    target_location?: string
    requirements?: string
    min_followers?: number
  }) =>
    apiClient<{ campaign: BrandCampaign }>('/api/brand/campaigns', {
      method: 'POST',
      body: data,
    }),

  updateCampaign: (id: string, data: Partial<BrandCampaign>) =>
    apiClient<{ campaign: BrandCampaign }>(`/api/brand/campaigns/${id}`, {
      method: 'PUT',
      body: data,
    }),

  getCampaignBids: (campaignId: string) =>
    apiClient<{ bids: CampaignBid[] }>(`/api/brand/campaigns/${campaignId}/bids`),

  respondToBid: (campaignId: string, bidId: string, action: 'accept' | 'reject') =>
    apiClient<unknown>(`/api/brand/campaigns/${campaignId}/bids/${bidId}`, {
      method: 'PUT',
      body: { action },
    }),

  getCollabs: (status?: string) =>
    apiClient<{ collabs: BrandCollab[] }>('/api/brand/collabs', {
      params: { status },
    }),

  getCollab: (id: string) =>
    apiClient<{ collab: BrandCollab }>(`/api/brand/collabs/${id}`),

  updateCollabMilestone: (id: string, milestone: string) =>
    apiClient<{ collab: BrandCollab }>(`/api/brand/collabs/${id}/milestone`, {
      method: 'PUT',
      body: { milestone },
    }),

  discoverCreators: (params?: {
    niche?: string
    platform?: string
    min_followers?: string
    max_followers?: string
    tier?: string
    state?: string
    city?: string
    page?: string
    limit?: string
    search?: string
  }) =>
    apiClient<{ creators: CreatorPreview[]; total: number; page: number; limit: number; totalPages: number }>(
      '/api/brand/creators',
      { params: params as Record<string, string> }
    ),

  getRequests: () =>
    apiClient<{ requests: unknown[] }>('/api/brand/requests'),

  sendRequest: (data: {
    creator_id: string
    collab_type: 'paid' | 'barter' | 'hybrid'
    deliverables: string[]
    budget?: number
    message?: string
  }) =>
    apiClient<{ request: unknown; message: string }>('/api/brand/requests', {
      method: 'POST',
      body: data,
    }),

  withdrawRequest: (id: string) =>
    apiClient<{ message: string }>(`/api/brand/requests/${id}`, {
      method: 'PATCH',
    }),

  getAllBids: () =>
    apiClient<{ bids: BidWithCampaign[] }>('/api/brand/bids/all'),

  getCredits: () =>
    apiClient<CreditData>('/api/brand/credits'),

  buyCredits: (pack: string) =>
    apiClient<{ order_id: string; amount: number; currency: string; credits: number; key_id: string }>(
      '/api/brand/credits',
      { method: 'POST', body: { pack } }
    ),

  verifyCredits: (razorpayOrderId: string, razorpayPaymentId: string, razorpaySignature: string) =>
    apiClient<{ success: boolean; balance: number }>('/api/brand/credits/verify', {
      method: 'POST',
      body: {
        razorpay_order_id: razorpayOrderId,
        razorpay_payment_id: razorpayPaymentId,
        razorpay_signature: razorpaySignature,
      },
    }),

  getAnalytics: () =>
    apiClient<BrandAnalytics>('/api/brand/analytics'),

  getSavedCreators: () =>
    apiClient<{ saved_creators: SavedCreator[] }>('/api/brand/saved-creators'),

  saveCreator: (creatorId: string) =>
    apiClient<{ saved_creator: SavedCreator }>('/api/brand/saved-creators', {
      method: 'POST',
      body: { creator_id: creatorId },
    }),

  unsaveCreator: (creatorId: string) =>
    apiClient<{ message: string }>(`/api/brand/saved-creators/${creatorId}`, {
      method: 'DELETE',
    }),

  getEvents: () =>
    apiClient<{ events: BrandEvent[] }>('/api/brand/events'),

  createEvent: (data: {
    title: string
    description?: string
    event_date: string
    location: string
    total_slots?: number
    target_niche?: string[]
    target_tier?: string[]
  }) =>
    apiClient<{ event: BrandEvent }>('/api/brand/events', {
      method: 'POST',
      body: data,
    }),

  inviteCreators: (eventId: string, creatorIds: string[]) =>
    apiClient<{ invites: { sent: number; skipped: number } }>(
      `/api/brand/events/${eventId}/invites`,
      { method: 'POST', body: { creator_ids: creatorIds } }
    ),

  getCreatorDetail: (id: string) =>
    apiClient<{ creator: CreatorDetail }>(`/api/brand/creators/${id}`),
}
