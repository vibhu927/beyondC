-- Migration: Add agency tables, update profiles role, and create discovery view

-- 1) Update profiles.role check to include 'agency'
ALTER TABLE profiles
  DROP CONSTRAINT IF EXISTS profiles_role_check;

ALTER TABLE profiles
  ADD CONSTRAINT profiles_role_check CHECK (role IN ('creator', 'brand', 'agency'));


-- 2) Create agency_profiles table
CREATE TABLE IF NOT EXISTS agency_profiles (
  id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  agency_name TEXT NOT NULL,
  tagline TEXT,
  description TEXT,
  logo_url TEXT,
  website TEXT,
  gst_number TEXT,
  is_agency_verified BOOLEAN DEFAULT FALSE,
  total_partnered_creators INTEGER DEFAULT 0,
  total_collabs INTEGER DEFAULT 0,
  avg_rating DECIMAL(3,2) DEFAULT 0,
  reach INTEGER DEFAULT 0,
  niche TEXT[] DEFAULT ARRAY[]::TEXT[],
  instagram_handle TEXT,
  youtube_channel TEXT,
  state TEXT,
  city TEXT,
  credit_balance INTEGER DEFAULT 0,
  size TEXT CHECK (size IN ('small', 'mid', 'large')) DEFAULT 'small',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);


-- 3) Create agency_creators table to manage partnerships
CREATE TABLE IF NOT EXISTS agency_creators (
  agency_id UUID NOT NULL REFERENCES agency_profiles(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES creator_profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected','removed')),
  invited_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  message TEXT,
  what_agency_offers TEXT,
  monthly_charge INTEGER,
  PRIMARY KEY (agency_id, creator_id)
);


-- 4) Create agency_pitches table for agency -> brand pitches
CREATE TABLE IF NOT EXISTS agency_pitches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id UUID NOT NULL REFERENCES agency_profiles(id) ON DELETE CASCADE,
  brand_id UUID NOT NULL REFERENCES brand_profiles(id) ON DELETE CASCADE,
  assigned_creator_id UUID REFERENCES creator_profiles(id),
  pitch_title TEXT,
  pitch_description TEXT,
  proposed_amount INTEGER,
  collab_type TEXT CHECK (collab_type IN ('paid','barter','hybrid')) DEFAULT 'paid',
  deliverables TEXT[] DEFAULT ARRAY[]::TEXT[],
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','accepted','rejected','expired')),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '7 days',
  credit_deducted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);


-- 5) Grant select on agency_profiles to authenticated (discovery-safe)
GRANT SELECT ON agency_profiles TO authenticated;


-- 6) Create agency_discovery_view for safe discovery by brands and creators
DROP VIEW IF EXISTS agency_discovery_view;

CREATE VIEW agency_discovery_view AS
SELECT
  ap.id,
  ap.agency_name,
  ap.logo_url,
  ap.niche,
  ap.total_partnered_creators,
  ap.total_collabs,
  ap.avg_rating,
  ap.state,
  ap.city,
  ap.is_agency_verified,
  ap.size
FROM agency_profiles ap
WHERE COALESCE(ap.agency_name, '') <> '';

GRANT SELECT ON agency_discovery_view TO authenticated;
