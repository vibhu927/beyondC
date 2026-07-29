import { apiClient } from './client'

export interface CreatorProfile {
  id: string
  first_name: string
  full_name: string
  email: string
  phone: string | null
  state: string | null
  city: string | null
  niche: string[]
  content_type: string[]
  starting_price: number | null
  wallet_balance: number
  instagram_verified: boolean
  instagram_username: string | null
  is_discoverable: boolean
  followers_count: number | null
  engagement_rate: number | null
  avg_collab_paise: number | null
  tier: string | null
  following_count: number | null
  posts_count: number | null
  highest_video_views: number | null
  avg_video_views: number | null
  avg_likes: number | null
  avg_comments: number | null
  stats_fetched_at: string | null
  portfolio_links: string[]
}

export interface Campaign {
  id: string
  title: string
  description: string
  brand_category: string
  collab_type: string
  budget_min: number | null
  budget_max: number | null
  deliverables: string[]
  niche: string[]
  deadline: string
  status: string
  slots_total: number
  slots_filled: number
  bid_count: number
  brand_id: string
  brand_name: string
  brand_logo: string | null
  target_location: string | null
  requirements: string | null
  min_followers: number | null
  created_at: string
}

export interface Bid {
  id: string
  campaign_id: string
  creator_id: string
  bid_amount: number
  message: string | null
  status: string
  created_at: string
  campaign?: Campaign
}

export interface CollabRequest {
  id: string
  brand_id: string
  brand_name: string
  brand_logo: string | null
  budget: number | null
  collab_type: string
  deliverables: string[]
  message: string | null
  status: string
  created_at: string
}

export interface Collab {
  id: string
  brand_id: string
  creator_id: string
  campaign_id: string | null
  agreed_amount: number | null
  collab_type: string
  status: string
  milestone_status: string
  contract_terms: unknown | null
  payment_structure: string
  rating: number | null
  created_at: string
  brand_name: string
  brand_logo: string | null
  campaign_title: string | null
  creator_name: string
  creator_avatar: string | null
}

export interface WalletData {
  balance: number
  transactions: {
    id: string
    amount: number
    type: string
    reason: string
    created_at: string
  }[]
}

export interface EarningsData {
  totalEarned: number
  collabsCompleted: number
  avgRating: number
  totalRatings: number
  recentCollabs: Collab[]
}

export interface EventInvite {
  id: string
  event_id: string
  brand_name: string
  event_title: string
  event_date: string
  location: string
  status: string
}

export interface AgencyInfo {
  id: string
  agency_name: string
  agency_logo: string | null
  status: string
}

export interface EventTicket {
  id: string
  event_id: string
  event_title: string
  event_date: string
  location: string
  brand_name: string
  qr_code_data: string
}

export const creatorApi = {
  getProfile: () =>
    apiClient<{ profile: CreatorProfile }>('/api/creator/profile'),

  updateProfile: (data: Partial<CreatorProfile>) =>
    apiClient<{ profile: CreatorProfile }>('/api/creator/profile', {
      method: 'PUT',
      body: data,
    }),

  getBids: () =>
    apiClient<{ bids: Bid[] }>('/api/creator/bids'),

  getAgency: () =>
    apiClient<{ agency: AgencyInfo | null }>('/api/creator/agency'),

  getCampaigns: (params?: {
    niche?: string
    collab_type?: string
    budget_min?: string
    budget_max?: string
    state?: string
    city?: string
    include_pan_india?: string
    page?: string
    limit?: string
  }) =>
    apiClient<{ campaigns: Campaign[]; total: number; page: number; limit: number; totalPages: number }>(
      '/api/creator/campaigns',
      { params: params as Record<string, string> }
    ),

  placeBid: (campaignId: string, bidAmount: number, message?: string) =>
    apiClient<{ bid: Bid }>('/api/creator/bids', {
      method: 'POST',
      body: { campaign_id: campaignId, bid_amount: bidAmount, message },
    }),

  withdrawBid: (bidId: string) =>
    apiClient<{ message: string }>(`/api/creator/bids/${bidId}`, {
      method: 'DELETE',
    }),

  getCollabs: (status?: string) =>
    apiClient<{ collabs: Collab[] }>('/api/creator/collabs', {
      params: { status },
    }),

  getCollab: (id: string) =>
    apiClient<{ collab: Collab }>(`/api/creator/collabs/${id}`),

  updateCollabMilestone: (id: string, milestone: string) =>
    apiClient<{ collab: Collab }>(`/api/creator/collabs/${id}/milestone`, {
      method: 'PUT',
      body: { milestone },
    }),

  getRequests: () =>
    apiClient<{ requests: CollabRequest[] }>('/api/creator/requests'),

  respondToRequest: (id: string, action: 'accept' | 'decline') =>
    apiClient<unknown>(`/api/creator/requests/${id}`, {
      method: 'PUT',
      body: { action },
    }),

  getEarnings: () =>
    apiClient<EarningsData>('/api/creator/earnings'),

  getWallet: () =>
    apiClient<WalletData>('/api/creator/wallet'),

  createTopup: (amountPaise: number) =>
    apiClient<{ order_id: string; amount: number; currency: string; key_id: string }>(
      '/api/creator/wallet',
      { method: 'POST', body: { amount: amountPaise } }
    ),

  verifyTopup: (razorpayOrderId: string, razorpayPaymentId: string, razorpaySignature: string) =>
    apiClient<{ success: boolean; balance: number }>('/api/creator/wallet/verify', {
      method: 'POST',
      body: {
        razorpay_order_id: razorpayOrderId,
        razorpay_payment_id: razorpayPaymentId,
        razorpay_signature: razorpaySignature,
      },
    }),

  getEvents: (status?: string) =>
    apiClient<{ invites: EventInvite[] }>('/api/creator/events', {
      params: { status },
    }),

  respondToEvent: (id: string, action: 'accept' | 'decline') =>
    apiClient<{ invite: EventInvite }>(`/api/creator/events/${id}`, {
      method: 'PUT',
      body: { action },
    }),

  getTickets: () =>
    apiClient<{ tickets: EventTicket[] }>('/api/creator/events/tickets'),
}
