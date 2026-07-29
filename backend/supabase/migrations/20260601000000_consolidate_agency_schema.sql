-- Consolidate agency schema: fix duplicate migration issues
-- 1. Add columns from 021000 that were lost because 000031 ran first
-- 2. Drop orphaned agency_pitches (superseded by agency_brand_pitches from 20260510000001)
-- 3. Drop dead columns on agency_creators (replaced by pitch system tables)

BEGIN;

ALTER TABLE agency_profiles
  ADD COLUMN IF NOT EXISTS contact_name TEXT,
  ADD COLUMN IF NOT EXISTS phone TEXT;

DROP TABLE IF EXISTS agency_pitches CASCADE;

ALTER TABLE agency_creators
  DROP COLUMN IF EXISTS message,
  DROP COLUMN IF EXISTS what_agency_offers,
  DROP COLUMN IF EXISTS monthly_charge;

COMMIT;
