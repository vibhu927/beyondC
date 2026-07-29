import { apiClient } from './client'

export interface Message {
  id: string
  collab_id: string
  sender_id: string
  content: string
  created_at: string
  sender_name: string
  sender_role: string
}

export interface CollabDetail {
  id: string
  brand_id: string
  creator_id: string
  campaign_id: string | null
  agreed_amount: number | null
  collab_type: string
  status: string
  milestone_status: string
  contract_terms: {
    deliverables?: string
    timeline?: string
    payment_terms?: string
    milestones?: string[]
    special_conditions?: string
  } | null
  payment_structure: string
  creator_contract_accepted: boolean
  brand_contract_accepted: boolean
  rating: number | null
  created_at: string
  brand_name: string
  brand_logo: string | null
  creator_name: string
  creator_avatar: string | null
  campaign_title: string | null
  brand: {
    id: string
    brand_name: string
    brand_category: string
    logo_url: string | null
  }
  creator: {
    id: string
    first_name: string
    full_name: string
    tier: string | null
    followers_count: number | null
    engagement_rate: number | null
  }
}

export interface ContentSubmission {
  id: string
  collab_id: string
  content_url: string
  content_type: string
  caption: string | null
  notes: string | null
  status: string
  brand_feedback: string | null
  created_at: string
}

export interface PaymentMilestone {
  id: string
  collab_id: string
  title: string
  amount: number
  status: string
  due_date: string | null
  released_at: string | null
}

export const collabApi = {
  getCollab: (id: string) =>
    apiClient<{ collab: CollabDetail }>(`/api/collabs/${id}`),

  getMessages: (collabId: string) =>
    apiClient<{ messages: Message[] }>(`/api/collabs/${collabId}/messages`),

  sendMessage: (collabId: string, content: string) =>
    apiClient<{ message: Message }>(`/api/collabs/${collabId}/messages`, {
      method: 'POST',
      body: { content },
    }),

  getSubmissions: (collabId: string) =>
    apiClient<{ submissions: ContentSubmission[] }>(`/api/collabs/${collabId}/submissions`),

  submitContent: (collabId: string, data: {
    content_url: string
    content_type: string
    caption?: string
    notes?: string
  }) =>
    apiClient<{ submission: ContentSubmission }>(`/api/collabs/${collabId}/submissions`, {
      method: 'POST',
      body: data,
    }),

  reviewContent: (collabId: string, submissionId: string, status: 'approved' | 'rejected' | 'revision_requested', brandFeedback?: string) =>
    apiClient<{ submission: ContentSubmission }>(
      `/api/collabs/${collabId}/submissions/${submissionId}`,
      { method: 'PUT', body: { status, brand_feedback: brandFeedback } }
    ),

  createContract: (collabId: string, data: {
    deliverables: string
    timeline: string
    payment_terms: string
    milestones?: string[]
    special_conditions?: string
  }) =>
    apiClient<{ collab: CollabDetail }>(`/api/collabs/${collabId}/contract`, {
      method: 'POST',
      body: data,
    }),

  acceptContract: (collabId: string) =>
    apiClient<{ collab: CollabDetail }>(`/api/collabs/${collabId}/contract/accept`, {
      method: 'PUT',
    }),

  setPaymentMilestones: (collabId: string, paymentStructure: string, milestones?: { title: string; amount: number; due_date?: string }[]) =>
    apiClient<{ collab: CollabDetail }>(`/api/collabs/${collabId}/payment-milestones`, {
      method: 'POST',
      body: { payment_structure: paymentStructure, milestones },
    }),

  getPaymentMilestones: (collabId: string) =>
    apiClient<{ milestones: PaymentMilestone[] }>(`/api/collabs/${collabId}/payment-milestones`),

  releasePaymentMilestone: (collabId: string, milestoneId: string) =>
    apiClient<{ milestone: PaymentMilestone }>(
      `/api/collabs/${collabId}/payment-milestones/${milestoneId}/release`,
      { method: 'POST' }
    ),

  submitRating: (collabId: string, rating: number, review?: string) =>
    apiClient<{ rating: unknown }>('/api/ratings', {
      method: 'POST',
      body: { collab_id: collabId, rating, review },
    }),
}
