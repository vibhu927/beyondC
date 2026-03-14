-- BeyondC Database Triggers and Functions
-- Migration: Triggers Setup

-- =====================================================
-- FUNCTION: Auto-create profile on signup
-- =====================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, role, first_name, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    NEW.raw_user_meta_data->>'role',
    NEW.raw_user_meta_data->>'first_name',
    NEW.raw_user_meta_data->>'full_name'
  );
  
  -- Auto-create role-specific profile
  IF NEW.raw_user_meta_data->>'role' = 'creator' THEN
    INSERT INTO creator_profiles (id) VALUES (NEW.id);
  ELSIF NEW.raw_user_meta_data->>'role' = 'brand' THEN
    INSERT INTO brand_profiles (id, brand_name) 
    VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'brand_name', 'New Brand'));
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =====================================================
-- FUNCTION: Auto-update updated_at timestamp
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN 
  NEW.updated_at = NOW(); 
  RETURN NEW; 
END;
$$ LANGUAGE plpgsql;

-- Apply to all relevant tables
CREATE TRIGGER update_profiles_updated_at 
  BEFORE UPDATE ON profiles 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_creator_profiles_updated_at 
  BEFORE UPDATE ON creator_profiles 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_brand_profiles_updated_at 
  BEFORE UPDATE ON brand_profiles 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_campaigns_updated_at 
  BEFORE UPDATE ON campaigns 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_bids_updated_at 
  BEFORE UPDATE ON bids 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_collab_requests_updated_at 
  BEFORE UPDATE ON collab_requests 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_collabs_updated_at 
  BEFORE UPDATE ON collabs 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_events_updated_at 
  BEFORE UPDATE ON events 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_event_invites_updated_at 
  BEFORE UPDATE ON event_invites 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- =====================================================
-- FUNCTION: Auto-update avg_rating after new rating
-- =====================================================
CREATE OR REPLACE FUNCTION update_avg_rating()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.rated_role = 'creator' THEN
    UPDATE creator_profiles 
    SET avg_rating = (
      SELECT ROUND(AVG(score)::numeric, 2) 
      FROM ratings 
      WHERE rated_user = NEW.rated_user
    ) 
    WHERE id = NEW.rated_user;
  ELSE
    UPDATE brand_profiles 
    SET avg_rating = (
      SELECT ROUND(AVG(score)::numeric, 2) 
      FROM ratings 
      WHERE rated_user = NEW.rated_user
    ) 
    WHERE id = NEW.rated_user;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_rating_created
  AFTER INSERT ON ratings
  FOR EACH ROW EXECUTE FUNCTION update_avg_rating();

-- =====================================================
-- FUNCTION: Increment total_collabs on collab creation
-- =====================================================
CREATE OR REPLACE FUNCTION increment_collab_count()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE creator_profiles 
  SET total_collabs = total_collabs + 1 
  WHERE id = NEW.creator_id;
  
  UPDATE brand_profiles 
  SET total_collabs = total_collabs + 1 
  WHERE id = NEW.brand_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_collab_created
  AFTER INSERT ON collabs
  FOR EACH ROW EXECUTE FUNCTION increment_collab_count();
