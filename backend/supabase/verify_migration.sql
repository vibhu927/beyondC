-- Verify agency tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema='public' AND table_name IN ('agency_profiles', 'agency_creators', 'agency_pitches');

-- Verify bids columns
SELECT column_name FROM information_schema.columns 
WHERE table_name='bids' AND column_name IN ('bidder_type','agency_id');

-- Verify collabs has agency_id
SELECT column_name FROM information_schema.columns 
WHERE table_name='collabs' AND column_name='agency_id';

-- Check row counts
SELECT count(*) as agency_profiles_count FROM agency_profiles;
SELECT count(*) as agency_creators_count FROM agency_creators;
SELECT count(*) as agency_pitches_count FROM agency_pitches;
