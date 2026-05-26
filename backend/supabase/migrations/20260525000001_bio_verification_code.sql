ALTER TABLE creator_profiles
  ADD COLUMN IF NOT EXISTS instagram_verification_code TEXT DEFAULT NULL;
