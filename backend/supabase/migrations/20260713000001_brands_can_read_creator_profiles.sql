-- Allow brands to read profile names/avatars of creator users.
-- Without this, every brand-facing route that joins profiles for
-- creator name/avatar fails because the RLS policy on profiles
-- restricts SELECT to auth.uid() = id.

CREATE POLICY "Brands can read creator profile names"
  ON profiles FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM profiles p2 WHERE p2.id = auth.uid() AND p2.role = 'brand')
    AND EXISTS (SELECT 1 FROM creator_profiles WHERE id = profiles.id)
  );
