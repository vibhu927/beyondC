-- Fix brand visibility for agency discover panel
-- Ensure all onboarded brand profiles are properly set up

-- Set verified flag for onboarded brands
UPDATE brand_profiles
SET is_brand_verified = true
WHERE is_brand_verified = false
AND id IN (
  SELECT bp.id FROM brand_profiles bp
  JOIN profiles p ON p.id = bp.id
  WHERE p.is_onboarded = true
);

COMMIT;