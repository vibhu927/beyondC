-- Make all onboarded creators discoverable by default
-- This ensures creators appear in discovery views for agencies and brands

UPDATE creator_profiles 
SET is_discoverable = true 
WHERE is_discoverable = false
AND id IN (
  SELECT cp.id FROM creator_profiles cp
  JOIN profiles p ON p.id = cp.id
  WHERE p.is_onboarded = true
);

-- Also set is_discoverable = true for any creator with a complete profile
UPDATE creator_profiles
SET is_discoverable = true
WHERE is_discoverable = false
AND follower_count IS NOT NULL
AND follower_count > 0;

-- Ensure all onboarded brand profiles have required fields populated
UPDATE brand_profiles
SET is_brand_verified = true
WHERE is_brand_verified = false
AND id IN (
  SELECT bp.id FROM brand_profiles bp
  JOIN profiles p ON p.id = bp.id
  WHERE p.is_onboarded = true
);

COMMIT;