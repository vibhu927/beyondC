-- Saved Creators: brands can bookmark creators for later outreach

CREATE TABLE IF NOT EXISTS saved_creators (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  brand_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  creator_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(brand_id, creator_id)
);

ALTER TABLE saved_creators ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Brands can view their saved creators"
  ON saved_creators FOR SELECT
  USING (brand_id = auth.uid());

CREATE POLICY "Brands can save creators"
  ON saved_creators FOR INSERT
  WITH CHECK (brand_id = auth.uid());

CREATE POLICY "Brands can unsave creators"
  ON saved_creators FOR DELETE
  USING (brand_id = auth.uid());

CREATE INDEX idx_saved_creators_brand ON saved_creators(brand_id);
CREATE INDEX idx_saved_creators_creator ON saved_creators(creator_id);
