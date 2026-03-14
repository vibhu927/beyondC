-- BeyondC Row Level Security Policies
-- Migration: RLS Setup

-- =====================================================
-- ENABLE RLS ON ALL TABLES
-- =====================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE creator_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE brand_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE bids ENABLE ROW LEVEL SECURITY;
ALTER TABLE collab_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE collabs ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- PROFILES POLICIES
-- =====================================================
CREATE POLICY "Users can view own profile" 
  ON profiles FOR SELECT 
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
  ON profiles FOR UPDATE 
  USING (auth.uid() = id);

-- =====================================================
-- CREATOR_PROFILES POLICIES
-- =====================================================
CREATE POLICY "Creators manage own profile" 
  ON creator_profiles FOR ALL 
  USING (auth.uid() = id);

CREATE POLICY "Brands can read creator profiles" 
  ON creator_profiles FOR SELECT 
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'brand')
  );

-- =====================================================
-- BRAND_PROFILES POLICIES
-- =====================================================
CREATE POLICY "Brands manage own profile" 
  ON brand_profiles FOR ALL 
  USING (auth.uid() = id);

CREATE POLICY "Creators can read brand profiles" 
  ON brand_profiles FOR SELECT 
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'creator')
  );

-- =====================================================
-- CAMPAIGNS POLICIES
-- =====================================================
CREATE POLICY "Brands manage own campaigns" 
  ON campaigns FOR ALL 
  USING (auth.uid() = brand_id);

CREATE POLICY "Creators can view active campaigns" 
  ON campaigns FOR SELECT 
  USING (
    status = 'active' AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'creator')
  );

-- =====================================================
-- BIDS POLICIES
-- =====================================================
CREATE POLICY "Creators manage own bids" 
  ON bids FOR ALL 
  USING (auth.uid() = creator_id);

CREATE POLICY "Brands see bids on their campaigns" 
  ON bids FOR SELECT 
  USING (
    EXISTS (SELECT 1 FROM campaigns WHERE id = campaign_id AND brand_id = auth.uid())
  );

CREATE POLICY "Brands can update bid status" 
  ON bids FOR UPDATE 
  USING (
    EXISTS (SELECT 1 FROM campaigns WHERE id = campaign_id AND brand_id = auth.uid())
  );

-- =====================================================
-- COLLAB_REQUESTS POLICIES
-- =====================================================
CREATE POLICY "Brands manage own requests" 
  ON collab_requests FOR ALL 
  USING (auth.uid() = brand_id);

CREATE POLICY "Creators view and respond to requests" 
  ON collab_requests FOR SELECT 
  USING (auth.uid() = creator_id);

CREATE POLICY "Creators update request status" 
  ON collab_requests FOR UPDATE 
  USING (auth.uid() = creator_id);

-- =====================================================
-- COLLABS POLICIES
-- =====================================================
CREATE POLICY "Collab parties can view" 
  ON collabs FOR SELECT 
  USING (
    auth.uid() = brand_id OR auth.uid() = creator_id
  );

CREATE POLICY "Collab parties can update" 
  ON collabs FOR UPDATE 
  USING (
    auth.uid() = brand_id OR auth.uid() = creator_id
  );

-- =====================================================
-- EVENTS POLICIES
-- =====================================================
CREATE POLICY "Brands manage own events" 
  ON events FOR ALL 
  USING (auth.uid() = brand_id);

CREATE POLICY "Creators view events" 
  ON events FOR SELECT 
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'creator')
  );

-- =====================================================
-- EVENT_INVITES POLICIES
-- =====================================================
CREATE POLICY "Brands manage own invites" 
  ON event_invites FOR ALL 
  USING (auth.uid() = brand_id);

CREATE POLICY "Creators view invites" 
  ON event_invites FOR SELECT 
  USING (auth.uid() = creator_id);

CREATE POLICY "Creators update invite status" 
  ON event_invites FOR UPDATE 
  USING (auth.uid() = creator_id);

-- =====================================================
-- CREDIT_TRANSACTIONS POLICIES
-- =====================================================
CREATE POLICY "Brands see own credit transactions" 
  ON credit_transactions FOR SELECT 
  USING (auth.uid() = brand_id);

-- =====================================================
-- WALLET_TRANSACTIONS POLICIES
-- =====================================================
CREATE POLICY "Creators see own wallet transactions" 
  ON wallet_transactions FOR SELECT 
  USING (auth.uid() = creator_id);

-- =====================================================
-- MESSAGES POLICIES
-- =====================================================
CREATE POLICY "Collab participants can message" 
  ON messages FOR ALL 
  USING (
    EXISTS (SELECT 1 FROM collabs WHERE id = collab_id AND (brand_id = auth.uid() OR creator_id = auth.uid()))
  );

-- =====================================================
-- RATINGS POLICIES
-- =====================================================
CREATE POLICY "Collab participants can rate" 
  ON ratings FOR INSERT 
  WITH CHECK (auth.uid() = rated_by);

CREATE POLICY "Anyone can read ratings" 
  ON ratings FOR SELECT 
  USING (true);

-- =====================================================
-- NOTIFICATIONS POLICIES
-- =====================================================
CREATE POLICY "Users see own notifications" 
  ON notifications FOR ALL 
  USING (auth.uid() = user_id);
