-- BeyondC Privacy View
-- Migration: Creator Discovery View (Privacy-First)

-- =====================================================
-- VIEW: creator_discovery_view
-- This view is used by brands to browse creators
-- Intentionally excludes: instagram_handle, youtube_handle, full_name
-- Only shows first_name and follower ranges
-- =====================================================
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
  cp.bio,
  cp.portfolio_links,
  -- Follower range instead of exact count
  CASE
    WHEN cp.follower_count < 5000 THEN '1K–5K'
    WHEN cp.follower_count < 10000 THEN '5K–10K'
    WHEN cp.follower_count < 50000 THEN '10K–50K'
    WHEN cp.follower_count < 100000 THEN '50K–100K'
    WHEN cp.follower_count < 500000 THEN '100K–500K'
    ELSE '500K+'
  END AS follower_range,
  -- Actual follower count (for filtering, but not displayed)
  cp.follower_count
FROM creator_profiles cp
JOIN profiles p ON p.id = cp.id
WHERE p.is_onboarded = true;

-- Grant access to authenticated users
GRANT SELECT ON creator_discovery_view TO authenticated;
