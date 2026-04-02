ALTER TABLE collabs ADD COLUMN IF NOT EXISTS last_message TEXT;
ALTER TABLE collabs ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMPTZ;
ALTER TABLE collabs ADD COLUMN IF NOT EXISTS last_message_by UUID REFERENCES profiles(id);
ALTER TABLE collabs ADD COLUMN IF NOT EXISTS unread_count_creator INTEGER DEFAULT 0;
ALTER TABLE collabs ADD COLUMN IF NOT EXISTS unread_count_brand INTEGER DEFAULT 0;
ALTER TABLE collabs ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ;
ALTER TABLE collabs ADD COLUMN IF NOT EXISTS is_archived BOOLEAN DEFAULT FALSE;

CREATE OR REPLACE FUNCTION auto_archive_inactive_chats()
RETURNS void AS $$
BEGIN
  UPDATE collabs
  SET is_archived = TRUE,
      archived_at = NOW()
  WHERE status = 'active'
    AND COALESCE(is_archived, FALSE) = FALSE
    AND (
      last_message_at < NOW() - INTERVAL '14 days'
      OR (last_message_at IS NULL AND created_at < NOW() - INTERVAL '14 days')
    );
END;
$$ LANGUAGE plpgsql;

-- Example schedule via pg_cron:
-- SELECT cron.schedule('archive-inactive-chats', '0 0 * * *', 'SELECT auto_archive_inactive_chats()');

CREATE OR REPLACE FUNCTION update_collab_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE collabs
  SET
    last_message = NEW.content,
    last_message_at = NEW.created_at,
    last_message_by = NEW.sender_id,
    is_archived = FALSE,
    archived_at = NULL,
    unread_count_creator = CASE
      WHEN NEW.sender_role = 'brand' THEN COALESCE(unread_count_creator, 0) + 1
      ELSE COALESCE(unread_count_creator, 0)
    END,
    unread_count_brand = CASE
      WHEN NEW.sender_role = 'creator' THEN COALESCE(unread_count_brand, 0) + 1
      ELSE COALESCE(unread_count_brand, 0)
    END
  WHERE id = NEW.collab_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_message_inserted ON messages;
CREATE TRIGGER on_message_inserted
  AFTER INSERT ON messages
  FOR EACH ROW EXECUTE FUNCTION update_collab_last_message();
