-- Add agency tables, extend role check, add bidder_type/agency_id, and update discovery view

BEGIN;

-- Create agency_profiles table
CREATE TABLE IF NOT EXISTS agency_profiles (
  id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  agency_name TEXT NOT NULL,
  contact_name TEXT,
  website TEXT,
  phone TEXT,
  credit_balance INTEGER DEFAULT 0,
  total_partnered_creators INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create agency_creators mapping
CREATE TABLE IF NOT EXISTS agency_creators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id UUID NOT NULL REFERENCES agency_profiles(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES creator_profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected')),
  invited_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  UNIQUE (agency_id, creator_id)
);

-- Create agency_pitches table
CREATE TABLE IF NOT EXISTS agency_pitches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id UUID NOT NULL REFERENCES agency_profiles(id) ON DELETE CASCADE,
  brand_id UUID REFERENCES brand_profiles(id),
  title TEXT NOT NULL,
  description TEXT,
  budget_min INTEGER,
  budget_max INTEGER,
  deliverables TEXT[],
  status TEXT DEFAULT 'open' CHECK (status IN ('open','closed','accepted','rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add bidder_type and agency_id to bids
ALTER TABLE bids
  ADD COLUMN IF NOT EXISTS bidder_type TEXT DEFAULT 'creator' CHECK (bidder_type IN ('creator','agency')),
  ADD COLUMN IF NOT EXISTS agency_id UUID REFERENCES agency_profiles(id);

-- Add agency_id to collabs
ALTER TABLE collabs
  ADD COLUMN IF NOT EXISTS agency_id UUID REFERENCES agency_profiles(id);

-- Attempt to drop existing role check constraint and add new one including 'agency'
-- Try the common constraint name first
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE profiles ADD CONSTRAINT profiles_role_check CHECK (role IN ('creator','brand','agency'));

-- Recreate creator_discovery_view with has_agency flag
DROP VIEW IF EXISTS creator_discovery_view;

CREATE VIEW creator_discovery_view AS
SELECT
  cp.id,
  p.first_name,
  p.avatar_url,
  p.state,
  p.city,
  cp.niche,
  cp.content_type,
  cp.platforms,
  cp.tier,
  cp.starting_price,
  cp.avg_rating,
  cp.total_collabs,
  cp.engagement_rate,
  cp.followers_count,
  cp.highest_video_views,
  cp.instagram_verified,
  cp.posts_count,
  CASE
    WHEN cp.followers_count < 5000 THEN '1K–5K'
    WHEN cp.followers_count < 10000 THEN '5K–10K'
    WHEN cp.followers_count < 50000 THEN '10K–50K'
    WHEN cp.followers_count < 100000 THEN '50K–100K'
    WHEN cp.followers_count < 500000 THEN '100K–500K'
    ELSE '500K+'
  END AS follower_range,
  EXISTS(
    SELECT 1 FROM agency_creators ac WHERE ac.creator_id = cp.id AND ac.status = 'accepted'
  ) AS has_agency
FROM creator_profiles cp
JOIN profiles p ON p.id = cp.id
WHERE cp.is_discoverable = TRUE;

GRANT SELECT ON creator_discovery_view TO authenticated;

COMMIT;
