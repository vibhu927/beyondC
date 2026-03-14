-- BeyondC Database Schema
-- Migration: Initial Schema Setup

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE 1: profiles
-- =====================================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('creator', 'brand')),
  full_name TEXT,
  first_name TEXT,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  is_onboarded BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 2: creator_profiles
-- =====================================================
CREATE TABLE creator_profiles (
  id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  niche TEXT[],
  content_type TEXT[],
  platforms TEXT[],
  follower_count INTEGER,
  engagement_rate DECIMAL(5,2),
  instagram_handle TEXT,
  youtube_handle TEXT,
  bio TEXT,
  starting_price INTEGER,
  tier TEXT GENERATED ALWAYS AS (
    CASE
      WHEN follower_count < 5000 THEN 'nano'
      WHEN follower_count < 50000 THEN 'micro'
      WHEN follower_count < 500000 THEN 'mid'
      ELSE 'macro'
    END
  ) STORED,
  wallet_balance INTEGER DEFAULT 0,
  avg_rating DECIMAL(3,2) DEFAULT 0,
  total_collabs INTEGER DEFAULT 0,
  portfolio_links TEXT[],
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 3: brand_profiles
-- =====================================================
CREATE TABLE brand_profiles (
  id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  brand_name TEXT NOT NULL,
  brand_category TEXT,
  website TEXT,
  gst_number TEXT,
  is_brand_verified BOOLEAN DEFAULT FALSE,
  description TEXT,
  logo_url TEXT,
  credit_balance INTEGER DEFAULT 0,
  size TEXT CHECK (size IN ('micro', 'mid', 'big')) DEFAULT 'micro',
  avg_rating DECIMAL(3,2) DEFAULT 0,
  total_collabs INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 4: campaigns
-- =====================================================
CREATE TABLE campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brand_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  niche TEXT[],
  collab_type TEXT NOT NULL CHECK (collab_type IN ('paid', 'barter', 'hybrid')),
  budget_min INTEGER,
  budget_max INTEGER,
  product_details TEXT,
  product_value INTEGER,
  deliverables TEXT[],
  target_tier TEXT[] DEFAULT ARRAY['nano','micro','mid','macro'],
  min_followers INTEGER DEFAULT 0,
  deadline TIMESTAMPTZ,
  slots INTEGER DEFAULT 1,
  slots_filled INTEGER DEFAULT 0,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 5: bids
-- =====================================================
CREATE TABLE bids (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id UUID NOT NULL REFERENCES campaigns(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES creator_profiles(id) ON DELETE CASCADE,
  bid_amount INTEGER,
  deliverables TEXT,
  include_barter BOOLEAN DEFAULT FALSE,
  message TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'withdrawn')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(campaign_id, creator_id)
);

-- =====================================================
-- TABLE 6: collab_requests
-- =====================================================
CREATE TABLE collab_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brand_profiles(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES creator_profiles(id) ON DELETE CASCADE,
  message TEXT,
  budget INTEGER,
  collab_type TEXT CHECK (collab_type IN ('paid', 'barter', 'hybrid')),
  deliverables TEXT[],
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '7 days',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 7: collabs
-- =====================================================
CREATE TABLE collabs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brand_profiles(id),
  creator_id UUID NOT NULL REFERENCES creator_profiles(id),
  source TEXT NOT NULL CHECK (source IN ('bid', 'direct_request')),
  source_id UUID,
  campaign_id UUID REFERENCES campaigns(id),
  agreed_amount INTEGER,
  collab_type TEXT,
  deliverables TEXT[],
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'in_progress', 'completed', 'disputed', 'cancelled')),
  brief_shared BOOLEAN DEFAULT FALSE,
  draft_submitted BOOLEAN DEFAULT FALSE,
  draft_approved BOOLEAN DEFAULT FALSE,
  content_posted BOOLEAN DEFAULT FALSE,
  brand_can_see_creator BOOLEAN DEFAULT TRUE,
  creator_can_see_brand BOOLEAN DEFAULT TRUE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 8: events
-- =====================================================
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brand_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  event_type TEXT CHECK (event_type IN ('product_launch', 'brand_party', 'press_meet', 'collab_meetup', 'virtual', 'other')),
  event_date TIMESTAMPTZ NOT NULL,
  venue_name TEXT,
  venue_address TEXT,
  city TEXT,
  is_virtual BOOLEAN DEFAULT FALSE,
  virtual_link TEXT,
  total_slots INTEGER DEFAULT 10,
  slots_filled INTEGER DEFAULT 0,
  what_creators_get TEXT,
  target_niche TEXT[],
  target_tier TEXT[],
  status TEXT DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 9: event_invites
-- =====================================================
CREATE TABLE event_invites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  brand_id UUID NOT NULL REFERENCES brand_profiles(id),
  creator_id UUID NOT NULL REFERENCES creator_profiles(id),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'attended')),
  ticket_code TEXT UNIQUE,
  ticket_generated_at TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, creator_id)
);

-- =====================================================
-- TABLE 10: credit_transactions
-- =====================================================
CREATE TABLE credit_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brand_profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('topup', 'deduct')),
  amount INTEGER NOT NULL,
  reason TEXT NOT NULL CHECK (reason IN (
    'credit_pack_purchase',
    'direct_request_sent',
    'bid_accepted',
    'event_invite_sent',
    'event_invite_accepted',
    'refund'
  )),
  reference_id UUID,
  razorpay_order_id TEXT,
  razorpay_payment_id TEXT,
  balance_after INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 11: wallet_transactions
-- =====================================================
CREATE TABLE wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES creator_profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('topup', 'deduct')),
  amount INTEGER NOT NULL,
  reason TEXT NOT NULL CHECK (reason IN (
    'wallet_topup',
    'collab_fee_deducted',
    'refund'
  )),
  reference_id UUID,
  razorpay_order_id TEXT,
  razorpay_payment_id TEXT,
  balance_after INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 12: messages
-- =====================================================
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collab_id UUID NOT NULL REFERENCES collabs(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES profiles(id),
  sender_role TEXT NOT NULL CHECK (sender_role IN ('creator', 'brand')),
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- TABLE 13: ratings
-- =====================================================
CREATE TABLE ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collab_id UUID NOT NULL REFERENCES collabs(id),
  rated_by UUID NOT NULL REFERENCES profiles(id),
  rated_user UUID NOT NULL REFERENCES profiles(id),
  rated_role TEXT NOT NULL CHECK (rated_role IN ('creator', 'brand')),
  score INTEGER NOT NULL CHECK (score BETWEEN 1 AND 5),
  review TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(collab_id, rated_by)
);

-- =====================================================
-- TABLE 14: notifications
-- =====================================================
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  reference_id UUID,
  reference_type TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES for performance
-- =====================================================
CREATE INDEX idx_campaigns_brand_id ON campaigns(brand_id);
CREATE INDEX idx_campaigns_status ON campaigns(status);
CREATE INDEX idx_bids_campaign_id ON bids(campaign_id);
CREATE INDEX idx_bids_creator_id ON bids(creator_id);
CREATE INDEX idx_collabs_brand_id ON collabs(brand_id);
CREATE INDEX idx_collabs_creator_id ON collabs(creator_id);
CREATE INDEX idx_messages_collab_id ON messages(collab_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_event_invites_creator_id ON event_invites(creator_id);
CREATE INDEX idx_event_invites_event_id ON event_invites(event_id);
