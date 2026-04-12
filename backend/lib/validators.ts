import { z } from 'zod'

// Auth schemas
export const signupSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  role: z.enum(['creator', 'brand']),
  display_name: z.string().min(1),
  state: z.string().min(1).optional(),
  city: z.string().min(1).optional(),
})

export const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
})

// Creator profile schemas
export const updateCreatorProfileSchema = z.object({
  display_name: z.string().optional(),
  avatar_url: z.string().url().optional().nullable(),
  bio: z.string().optional(),
  niches: z.array(z.string()).optional(),
  platforms: z.array(z.string()).optional(),
  starting_price: z.number().int().min(0).optional(),
  youtube_handle: z.string().optional(),
  twitter_handle: z.string().optional(),
  followers_count: z.number().int().min(0).optional(),
  engagement_rate: z.number().min(0).max(100).optional(),
  portfolio_links: z.array(z.string().url()).optional(),
  state: z.string().optional(),
  city: z.string().optional(),
  onboarded: z.boolean().optional(),
})

// Brand profile schemas
export const updateBrandProfileSchema = z.object({
  display_name: z.string().optional(),
  avatar_url: z.string().url().optional().nullable(),
  brand_name: z.string().optional(),
  brand_category: z.string().optional(),
  description: z.string().optional(),
  logo_url: z.string().url().optional().nullable(),
  portfolio_links: z.array(z.string().url()).optional(),
  website: z.string().url().optional(),
  contact_email: z.string().email().optional(),
  size: z.enum(['micro', 'mid', 'big']).optional(),
  state: z.string().optional(),
  city: z.string().optional(),
  onboarded: z.boolean().optional(),
})

// Campaign schemas
export const createCampaignSchema = z.object({
  title: z.string().min(1),
  description: z.string().optional(),
  niche: z.union([z.string(), z.array(z.string())]),
  collab_type: z.enum(['paid', 'barter', 'hybrid']),
  budget: z.number().int().min(0).optional(), // in paise
  budget_min: z.number().int().min(0).optional(),
  budget_max: z.number().int().min(0).optional(),
  deliverables: z.array(z.string()),
  requirements: z.string().optional(),
  deadline: z.string().optional(), // ISO date string
  slots: z.number().int().min(1).optional(),
  target_state: z.string().optional().nullable(),
  target_city: z.string().optional().nullable(),
  status: z.enum(['draft', 'active', 'closed']).optional(),
})

export const updateCampaignSchema = z.object({
  title: z.string().optional(),
  description: z.string().optional(),
  niche: z.union([z.string(), z.array(z.string())]).optional(),
  collab_type: z.enum(['paid', 'barter', 'hybrid']).optional(),
  budget: z.number().int().min(0).optional(),
  budget_min: z.number().int().min(0).optional(),
  budget_max: z.number().int().min(0).optional(),
  deliverables: z.array(z.string()).optional(),
  requirements: z.string().optional(),
  deadline: z.string().optional(),
  slots: z.number().int().min(1).optional(),
  target_state: z.string().optional().nullable(),
  target_city: z.string().optional().nullable(),
  status: z.enum(['draft', 'active', 'closed']).optional(),
})

// Bid schemas
export const createBidSchema = z.object({
  campaign_id: z.string().uuid(),
  bid_amount: z.number().int().min(0).optional(),
  deliverables: z.string().optional(),
  include_barter: z.boolean().optional(),
  message: z.string().optional(),
})

// Direct request schemas
export const createCollabRequestSchema = z.object({
  creator_id: z.string().uuid(),
  message: z.string().optional(),
  budget: z.number().int().min(0).optional(),
  collab_type: z.enum(['paid', 'barter', 'hybrid']),
  deliverables: z.array(z.string()),
})

// Event schemas
export const createEventSchema = z.object({
  title: z.string().min(1),
  description: z.string().optional(),
  event_date: z.string(), // ISO date string
  location: z.string().optional(),
  city: z.string().optional(),
  state: z.string().optional(),
  image_url: z.string().url().optional(),
})

// Wallet schemas
export const createTopupSchema = z.object({
  amount: z.number().int().min(10000), // minimum ₹100 (in paise)
})

// Credit schemas
export const createCreditPurchaseSchema = z.object({
  pack: z.enum(['starter', 'growth', 'pro', 'enterprise']),
})

export const verifyPaymentSchema = z.object({
  razorpay_order_id: z.string(),
  razorpay_payment_id: z.string(),
  razorpay_signature: z.string(),
})

// Message schema
export const createMessageSchema = z.object({
  content: z.string().min(1).max(5000),
})

// Rating schema
export const createRatingSchema = z.object({
  collab_id: z.string().uuid(),
  rating: z.number().int().min(1).max(5),
  review: z.string().optional(),
})

// Generic action schema
export const actionSchema = z.object({
  action: z.enum(['accept', 'reject']),
})

// Client-side form validators for onboarding/auth pages.
export const validators = {
  required: (value: string, field: string) =>
    !value.trim() ? `${field} is required` : null,

  email: (value: string) =>
    !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) ? 'Enter a valid email' : null,

  phone: (value: string) =>
    !/^[6-9]\d{9}$/.test(value.replace(/\s/g, ''))
      ? 'Enter a valid 10-digit Indian mobile number'
      : null,

  password: (value: string) =>
    value.length < 8
      ? 'Password must be at least 8 characters'
      : !/\d/.test(value)
        ? 'Password must contain at least one number'
        : null,

  confirmPassword: (value: string, original: string) =>
    value !== original ? 'Passwords do not match' : null,

  minLength: (value: string, min: number, field: string) =>
    value.trim().length < min ? `${field} must be at least ${min} characters` : null,
}
