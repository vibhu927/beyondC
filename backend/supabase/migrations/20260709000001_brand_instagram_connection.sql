-- Add Instagram connection columns to brand_profiles
-- Mirrors the creator_profiles Instagram columns from migration 20260330000007

ALTER TABLE brand_profiles
  ADD COLUMN IF NOT EXISTS instagram_username TEXT,
  ADD COLUMN IF NOT EXISTS instagram_verified BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS instagram_oauth_token TEXT,
  ADD COLUMN IF NOT EXISTS instagram_user_id TEXT,
  ADD COLUMN IF NOT EXISTS instagram_connected_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS followers_count INTEGER,
  ADD COLUMN IF NOT EXISTS following_count INTEGER,
  ADD COLUMN IF NOT EXISTS posts_count INTEGER,
  ADD COLUMN IF NOT EXISTS highest_video_views INTEGER,
  ADD COLUMN IF NOT EXISTS avg_video_views INTEGER,
  ADD COLUMN IF NOT EXISTS avg_likes INTEGER,
  ADD COLUMN IF NOT EXISTS avg_comments INTEGER,
  ADD COLUMN IF NOT EXISTS engagement_rate DECIMAL(5,2),
  ADD COLUMN IF NOT EXISTS stats_fetched_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS instagram_verification_code TEXT;
