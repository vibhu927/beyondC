-- BeyondC Storage: Avatars bucket + policies
-- Ensures mobile avatar uploads work for creator/brand profiles.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  TRUE,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Public read avatars" ON storage.objects;
CREATE POLICY "Public read avatars"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Authenticated upload own avatars" ON storage.objects;
CREATE POLICY "Authenticated upload own avatars"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'avatars'
    AND (
      name LIKE ('brands/' || auth.uid()::text || '-%')
      OR name LIKE ('creators/' || auth.uid()::text || '-%')
      OR name LIKE ('brands/' || auth.uid()::text || '.%')
      OR name LIKE ('creators/' || auth.uid()::text || '.%')
    )
  );

DROP POLICY IF EXISTS "Authenticated update own avatars" ON storage.objects;
CREATE POLICY "Authenticated update own avatars"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (
      name LIKE ('brands/' || auth.uid()::text || '-%')
      OR name LIKE ('creators/' || auth.uid()::text || '-%')
      OR name LIKE ('brands/' || auth.uid()::text || '.%')
      OR name LIKE ('creators/' || auth.uid()::text || '.%')
    )
  )
  WITH CHECK (
    bucket_id = 'avatars'
    AND (
      name LIKE ('brands/' || auth.uid()::text || '-%')
      OR name LIKE ('creators/' || auth.uid()::text || '-%')
      OR name LIKE ('brands/' || auth.uid()::text || '.%')
      OR name LIKE ('creators/' || auth.uid()::text || '.%')
    )
  );

DROP POLICY IF EXISTS "Authenticated delete own avatars" ON storage.objects;
CREATE POLICY "Authenticated delete own avatars"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'avatars'
    AND (
      name LIKE ('brands/' || auth.uid()::text || '-%')
      OR name LIKE ('creators/' || auth.uid()::text || '-%')
      OR name LIKE ('brands/' || auth.uid()::text || '.%')
      OR name LIKE ('creators/' || auth.uid()::text || '.%')
    )
  );
