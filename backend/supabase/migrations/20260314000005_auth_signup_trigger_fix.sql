-- BeyondC Auth Signup Trigger Fix
-- Migration: Ensure auth signup can create profile rows under RLS

-- Recreate trigger function with safer defaults and idempotent inserts.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_role TEXT;
  brand_name_value TEXT;
BEGIN
  user_role := LOWER(COALESCE(NEW.raw_user_meta_data->>'role', ''));
  IF user_role NOT IN ('creator', 'brand') THEN
    user_role := 'creator';
  END IF;

  brand_name_value := NULLIF(TRIM(COALESCE(NEW.raw_user_meta_data->>'brand_name', '')), '');

  INSERT INTO public.profiles (id, email, role, first_name, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    user_role,
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'full_name'
  )
  ON CONFLICT (id) DO UPDATE
  SET
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    first_name = COALESCE(EXCLUDED.first_name, public.profiles.first_name),
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
    updated_at = NOW();

  IF user_role = 'creator' THEN
    INSERT INTO public.creator_profiles (id)
    VALUES (NEW.id)
    ON CONFLICT (id) DO NOTHING;
  ELSE
    INSERT INTO public.brand_profiles (id, brand_name)
    VALUES (NEW.id, COALESCE(brand_name_value, 'New Brand'))
    ON CONFLICT (id) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Ensure trigger points to updated function.
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Allow auth and service roles to insert profile rows when trigger runs under RLS.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'Auth admin can insert profiles'
  ) THEN
    CREATE POLICY "Auth admin can insert profiles"
      ON public.profiles
      FOR INSERT
      TO supabase_auth_admin
      WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'creator_profiles'
      AND policyname = 'Auth admin can insert creator profiles'
  ) THEN
    CREATE POLICY "Auth admin can insert creator profiles"
      ON public.creator_profiles
      FOR INSERT
      TO supabase_auth_admin
      WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'brand_profiles'
      AND policyname = 'Auth admin can insert brand profiles'
  ) THEN
    CREATE POLICY "Auth admin can insert brand profiles"
      ON public.brand_profiles
      FOR INSERT
      TO supabase_auth_admin
      WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'profiles'
      AND policyname = 'Service role full access profiles'
  ) THEN
    CREATE POLICY "Service role full access profiles"
      ON public.profiles
      FOR ALL
      TO service_role
      USING (true)
      WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'creator_profiles'
      AND policyname = 'Service role full access creator profiles'
  ) THEN
    CREATE POLICY "Service role full access creator profiles"
      ON public.creator_profiles
      FOR ALL
      TO service_role
      USING (true)
      WITH CHECK (true);
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'brand_profiles'
      AND policyname = 'Service role full access brand profiles'
  ) THEN
    CREATE POLICY "Service role full access brand profiles"
      ON public.brand_profiles
      FOR ALL
      TO service_role
      USING (true)
      WITH CHECK (true);
  END IF;
END
$$;
