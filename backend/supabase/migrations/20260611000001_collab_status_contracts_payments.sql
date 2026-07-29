-- Add collab status tracking columns
ALTER TABLE collabs
  ADD COLUMN IF NOT EXISTS collab_status TEXT DEFAULT 'started'
    CHECK (collab_status IN ('started', 'working_on_draft', 'draft_ready', 'content_posted', 'completed')),
  ADD COLUMN IF NOT EXISTS status_updated_at TIMESTAMPTZ DEFAULT now(),
  ADD COLUMN IF NOT EXISTS status_update_message TEXT;

-- Add contract columns
ALTER TABLE collabs
  ADD COLUMN IF NOT EXISTS contract_terms JSONB,
  ADD COLUMN IF NOT EXISTS creator_contract_accepted BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS brand_contract_accepted BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS creator_contract_accepted_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS brand_contract_accepted_at TIMESTAMPTZ;

-- Add payment structure columns
ALTER TABLE collabs
  ADD COLUMN IF NOT EXISTS payment_structure TEXT DEFAULT 'full_upfront'
    CHECK (payment_structure IN ('full_upfront', 'milestone_based'));

-- Create payment milestones table
CREATE TABLE IF NOT EXISTS payment_milestones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collab_id UUID NOT NULL REFERENCES collabs(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  percentage NUMERIC(5,2) NOT NULL CHECK (percentage > 0 AND percentage <= 100),
  amount_paise INTEGER NOT NULL CHECK (amount_paise >= 0),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'released')),
  released_at TIMESTAMPTZ,
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Create content submissions table
CREATE TABLE IF NOT EXISTS content_submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collab_id UUID NOT NULL REFERENCES collabs(id) ON DELETE CASCADE,
  submitted_by UUID NOT NULL REFERENCES auth.users(id),
  content_url TEXT NOT NULL,
  content_type TEXT NOT NULL CHECK (content_type IN ('image', 'video', 'link')),
  caption TEXT,
  notes TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'revision_requested')),
  brand_feedback TEXT,
  submitted_at TIMESTAMPTZ DEFAULT now(),
  reviewed_at TIMESTAMPTZ
);

-- RLS policies for payment_milestones
ALTER TABLE payment_milestones ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Creators and brands can view payment milestones"
  ON payment_milestones FOR SELECT
  USING (
    collab_id IN (
      SELECT id FROM collabs
      WHERE brand_id = auth.uid() OR creator_id = auth.uid()
    )
  );

CREATE POLICY "Brands can manage payment milestones"
  ON payment_milestones FOR ALL
  USING (
    collab_id IN (
      SELECT id FROM collabs WHERE brand_id = auth.uid()
    )
  );

-- RLS policies for content_submissions
ALTER TABLE content_submissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Creators and brands can view content submissions"
  ON content_submissions FOR SELECT
  USING (
    collab_id IN (
      SELECT id FROM collabs
      WHERE brand_id = auth.uid() OR creator_id = auth.uid()
    )
  );

CREATE POLICY "Creators can insert content submissions"
  ON content_submissions FOR INSERT
  WITH CHECK (
    collab_id IN (
      SELECT id FROM collabs WHERE creator_id = auth.uid()
    )
  );

CREATE POLICY "Brands can update content submissions"
  ON content_submissions FOR UPDATE
  USING (
    collab_id IN (
      SELECT id FROM collabs WHERE brand_id = auth.uid()
    )
  );

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_payment_milestones_collab ON payment_milestones(collab_id);
CREATE INDEX IF NOT EXISTS idx_content_submissions_collab ON content_submissions(collab_id);
