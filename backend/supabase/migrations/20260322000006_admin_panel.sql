-- BeyondC Admin Panel Schema

-- Add admin flags to profiles.
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_super_admin BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS is_suspended BOOLEAN DEFAULT FALSE;

-- Roles for admin staff.
CREATE TABLE IF NOT EXISTS admin_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  designation TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Staff assignments for admin users.
CREATE TABLE IF NOT EXISTS admin_staff (
  id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  role_id UUID REFERENCES admin_roles(id),
  designation TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  added_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Page-level permissions per role.
CREATE TABLE IF NOT EXISTS admin_permissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_id UUID NOT NULL REFERENCES admin_roles(id) ON DELETE CASCADE,
  page TEXT NOT NULL,
  can_view BOOLEAN DEFAULT FALSE,
  can_edit BOOLEAN DEFAULT FALSE,
  can_delete BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(role_id, page)
);

-- Admin action logs.
CREATE TABLE IF NOT EXISTS admin_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID REFERENCES profiles(id),
  action TEXT NOT NULL,
  target_type TEXT,
  target_id UUID,
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Platform-level settings editable by admins.
CREATE TABLE IF NOT EXISTS platform_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  label TEXT,
  updated_by UUID REFERENCES profiles(id),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_is_admin ON profiles(is_admin);
CREATE INDEX IF NOT EXISTS idx_profiles_is_super_admin ON profiles(is_super_admin);
CREATE INDEX IF NOT EXISTS idx_admin_permissions_role_id ON admin_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_admin_id ON admin_logs(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_logs_created_at ON admin_logs(created_at DESC);

ALTER TABLE admin_staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE platform_settings ENABLE ROW LEVEL SECURITY;

-- Super admins can manage staff records.
DROP POLICY IF EXISTS "Super admin manages staff" ON admin_staff;
CREATE POLICY "Super admin manages staff"
  ON admin_staff
  FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid() AND is_super_admin = TRUE
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid() AND is_super_admin = TRUE
    )
  );

-- Super admins can manage role permissions.
DROP POLICY IF EXISTS "Super admin manages permissions" ON admin_permissions;
CREATE POLICY "Super admin manages permissions"
  ON admin_permissions
  FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid() AND is_super_admin = TRUE
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid() AND is_super_admin = TRUE
    )
  );

-- Admins can read logs.
DROP POLICY IF EXISTS "Admins can read logs" ON admin_logs;
CREATE POLICY "Admins can read logs"
  ON admin_logs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid() AND is_admin = TRUE
    )
  );

-- Admins can read settings.
DROP POLICY IF EXISTS "Admins read settings" ON platform_settings;
CREATE POLICY "Admins read settings"
  ON platform_settings
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid() AND is_admin = TRUE
    )
  );

-- Super admins can write settings.
DROP POLICY IF EXISTS "Super admin writes settings" ON platform_settings;
CREATE POLICY "Super admin writes settings"
  ON platform_settings
  FOR ALL
  USING (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid() AND is_super_admin = TRUE
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1
      FROM profiles
      WHERE id = auth.uid() AND is_super_admin = TRUE
    )
  );