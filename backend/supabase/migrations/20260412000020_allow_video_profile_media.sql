-- Allow profile media uploads to include videos in avatars bucket.
-- Also raise file size limit for short video posts.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  TRUE,
  52428800,
  ARRAY[
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
    'video/mp4',
    'video/quicktime',
    'video/webm',
    'video/x-msvideo',
    'video/x-matroska'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;