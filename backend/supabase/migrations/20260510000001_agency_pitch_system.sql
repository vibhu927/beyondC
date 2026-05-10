-- Agency pitch system tables

BEGIN;

-- 1) Agency pitches to Creator (agency wanting to represent creator)
CREATE TABLE IF NOT EXISTS agency_creator_pitches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id UUID NOT NULL REFERENCES agency_profiles(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES creator_profiles(id) ON DELETE CASCADE,
  pitch_type TEXT NOT NULL CHECK (pitch_type IN ('monthly_fee', 'profit_ratio')),
  monthly_fee INTEGER,
  profit_ratio INTEGER CHECK (profit_ratio >= 0 AND profit_ratio <= 100),
  pitch_title TEXT,
  pitch_message TEXT,
  deliverables TEXT[] DEFAULT ARRAY[]::TEXT[],
  collab_type TEXT CHECK (collab_type IN ('paid', 'barter', 'hybrid')) DEFAULT 'paid',
  proposed_amount INTEGER,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired', 'cancelled')),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '14 days',
  responded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (agency_id, creator_id)
);

-- 2) Creator pitches to Agency (creator seeking representation)
CREATE TABLE IF NOT EXISTS creator_agency_pitches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id UUID NOT NULL REFERENCES creator_profiles(id) ON DELETE CASCADE,
  agency_id UUID NOT NULL REFERENCES agency_profiles(id) ON DELETE CASCADE,
  pitch_title TEXT,
  pitch_message TEXT,
  expected_monthly_fee INTEGER,
  expected_profit_ratio INTEGER CHECK (expected_profit_ratio >= 0 AND expected_profit_ratio <= 100),
  portfolio_links TEXT[] DEFAULT ARRAY[]::TEXT[],
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired', 'withdrawn')),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '14 days',
  responded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (creator_id, agency_id)
);

-- 3) Agency pitches Brand on behalf of their creator (agency representing creator to brand)
CREATE TABLE IF NOT EXISTS agency_brand_pitches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agency_id UUID NOT NULL REFERENCES agency_profiles(id) ON DELETE CASCADE,
  brand_id UUID NOT NULL REFERENCES brand_profiles(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES creator_profiles(id) ON DELETE CASCADE,
  pitch_title TEXT,
  pitch_description TEXT,
  proposed_amount INTEGER,
  deliverables TEXT[] DEFAULT ARRAY[]::TEXT[],
  collab_type TEXT CHECK (collab_type IN ('paid', 'barter', 'hybrid')) DEFAULT 'paid',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired', 'cancelled')),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '14 days',
  responded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4) Brand pitches to Agency (brand looking for creators)
CREATE TABLE IF NOT EXISTS brand_agency_pitches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES brand_profiles(id) ON DELETE CASCADE,
  agency_id UUID NOT NULL REFERENCES agency_profiles(id) ON DELETE CASCADE,
  pitch_title TEXT,
  pitch_message TEXT,
  budget_min INTEGER,
  budget_max INTEGER,
  required_niches TEXT[],
  required_follower_min INTEGER,
  required_follower_max INTEGER,
  required_platforms TEXT[],
  deliverables TEXT[] DEFAULT ARRAY[]::TEXT[],
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired', 'withdrawn')),
  expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '14 days',
  responded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (brand_id, agency_id)
);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_agency_creator_pitches_agency ON agency_creator_pitches(agency_id);
CREATE INDEX IF NOT EXISTS idx_agency_creator_pitches_creator ON agency_creator_pitches(creator_id);
CREATE INDEX IF NOT EXISTS idx_agency_creator_pitches_status ON agency_creator_pitches(status);

CREATE INDEX IF NOT EXISTS idx_creator_agency_pitches_creator ON creator_agency_pitches(creator_id);
CREATE INDEX IF NOT EXISTS idx_creator_agency_pitches_agency ON creator_agency_pitches(agency_id);
CREATE INDEX IF NOT EXISTS idx_creator_agency_pitches_status ON creator_agency_pitches(status);

CREATE INDEX IF NOT EXISTS idx_agency_brand_pitches_agency ON agency_brand_pitches(agency_id);
CREATE INDEX IF NOT EXISTS idx_agency_brand_pitches_brand ON agency_brand_pitches(brand_id);
CREATE INDEX IF NOT EXISTS idx_agency_brand_pitches_creator ON agency_brand_pitches(creator_id);
CREATE INDEX IF NOT EXISTS idx_agency_brand_pitches_status ON agency_brand_pitches(status);

CREATE INDEX IF NOT EXISTS idx_brand_agency_pitches_brand ON brand_agency_pitches(brand_id);
CREATE INDEX IF NOT EXISTS idx_brand_agency_pitches_agency ON brand_agency_pitches(agency_id);
CREATE INDEX IF NOT EXISTS idx_brand_agency_pitches_status ON brand_agency_pitches(status);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON agency_creator_pitches TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON creator_agency_pitches TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON agency_brand_pitches TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON brand_agency_pitches TO authenticated;

COMMIT;