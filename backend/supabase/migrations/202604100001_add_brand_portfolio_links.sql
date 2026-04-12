-- Add media portfolio links for brand profile posts tab
ALTER TABLE brand_profiles
ADD COLUMN IF NOT EXISTS portfolio_links TEXT[] DEFAULT '{}'::TEXT[];