-- BeyondC Instagram OAuth Verification
-- Migration: Add verified Instagram fields and tighten discovery view

ALTER TABLE creator_profiles
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
  ADD COLUMN IF NOT EXISTS stats_fetched_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS is_discoverable BOOLEAN DEFAULT FALSE;

-- Keep current data usable during transition from legacy schema.
UPDATE creator_profiles
SET followers_count = COALESCE(followers_count, follower_count)
WHERE followers_count IS NULL;

ALTER TABLE creator_profiles DROP COLUMN IF EXISTS instagram_handle;

DROP VIEW IF EXISTS creator_discovery_view;

CREATE VIEW creator_discovery_view AS
SELECT
  cp.id,
  p.first_name,
  p.avatar_url,
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
  END AS follower_range
FROM creator_profiles cp
JOIN profiles p ON p.id = cp.id
WHERE cp.is_discoverable = TRUE;

GRANT SELECT ON creator_discovery_view TO authenticated;
