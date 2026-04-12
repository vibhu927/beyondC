-- Add location fields for profiles, campaigns, and events.

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS state TEXT,
  ADD COLUMN IF NOT EXISTS city TEXT;

ALTER TABLE campaigns
  ADD COLUMN IF NOT EXISTS target_state TEXT,
  ADD COLUMN IF NOT EXISTS target_city TEXT;

ALTER TABLE events
  ADD COLUMN IF NOT EXISTS state TEXT;

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
  END AS follower_range
FROM creator_profiles cp
JOIN profiles p ON p.id = cp.id
WHERE cp.is_discoverable = TRUE;

GRANT SELECT ON creator_discovery_view TO authenticated;
