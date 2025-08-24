-- ===========================================================
-- Validation queries for SportifyAPI database
-- ===========================================================
-- Use these queries to verify the database structure and sample data

-- Check if all tables were created
SELECT 
    schemaname as schema, 
    tablename as table_name, 
    tableowner as owner
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- Check table row counts
SELECT 
    'countries' as table_name, COUNT(*) as row_count FROM countries
UNION ALL
SELECT 'states', COUNT(*) FROM states
UNION ALL
SELECT 'cities', COUNT(*) FROM cities
UNION ALL
SELECT 'sports', COUNT(*) FROM sports
UNION ALL
SELECT 'federations', COUNT(*) FROM federations
UNION ALL
SELECT 'people', COUNT(*) FROM people
UNION ALL
SELECT 'athletes', COUNT(*) FROM athletes
UNION ALL
SELECT 'staff', COUNT(*) FROM staff
UNION ALL
SELECT 'referees', COUNT(*) FROM referees
UNION ALL
SELECT 'clubs', COUNT(*) FROM clubs
UNION ALL
SELECT 'staff_roles', COUNT(*) FROM staff_roles
UNION ALL
SELECT 'athlete_positions', COUNT(*) FROM athlete_positions
UNION ALL
SELECT 'referee_roles', COUNT(*) FROM referee_roles
ORDER BY table_name;

-- Verify federation hierarchy
SELECT 
    f.name as federation,
    f.acronym,
    s.name as sport,
    f.geographic_scope,
    pf.acronym as parent_federation,
    c.name as city
FROM federations f
JOIN sports s ON f.sport_id = s.id
LEFT JOIN federations pf ON f.parent_federation_id = pf.id
LEFT JOIN cities c ON f.city_id = c.id
ORDER BY f.geographic_scope, f.name;

-- Verify clubs and their federations
SELECT 
    c.name as club,
    c.acronym as club_acronym,
    f.acronym as federation,
    ci.name as city,
    c.foundation_date
FROM clubs c
JOIN federations f ON c.federation_id = f.id
LEFT JOIN cities ci ON c.city_id = ci.id
ORDER BY f.acronym, c.name;

-- Verify active athlete assignments
SELECT 
    p.first_name || ' ' || p.last_name as athlete_name,
    c.name as club,
    pos.name as position,
    caa.shirt_number,
    caa.status,
    caa.start_date
FROM people p
JOIN athletes a ON p.id = a.person_id
JOIN club_athlete_assignments caa ON a.person_id = caa.athlete_id
JOIN clubs c ON caa.club_id = c.id
LEFT JOIN athlete_positions pos ON caa.position_id = pos.id
WHERE caa.end_date IS NULL
ORDER BY c.name, caa.shirt_number;

-- Verify staff assignments
SELECT 
    p.first_name || ' ' || p.last_name as staff_name,
    c.name as club,
    sr.name as role,
    csa.status,
    csa.start_date
FROM people p
JOIN staff s ON p.id = s.person_id
JOIN club_staff_assignments csa ON s.person_id = csa.staff_id
JOIN clubs c ON csa.club_id = c.id
LEFT JOIN staff_roles sr ON csa.role_id = sr.id
WHERE csa.end_date IS NULL
ORDER BY c.name, sr.name;

-- Check for any constraint violations or orphaned records
SELECT 'Orphaned athletes (no person)' as check_type, COUNT(*) as count
FROM athletes a LEFT JOIN people p ON a.person_id = p.id WHERE p.id IS NULL
UNION ALL
SELECT 'Orphaned staff (no person)', COUNT(*)
FROM staff s LEFT JOIN people p ON s.person_id = p.id WHERE p.id IS NULL
UNION ALL
SELECT 'Orphaned referees (no person)', COUNT(*)
FROM referees r LEFT JOIN people p ON r.person_id = p.id WHERE p.id IS NULL
UNION ALL
SELECT 'Orphaned clubs (no federation)', COUNT(*)
FROM clubs c LEFT JOIN federations f ON c.federation_id = f.id WHERE f.id IS NULL
UNION ALL
SELECT 'Orphaned federations (no sport)', COUNT(*)
FROM federations f LEFT JOIN sports s ON f.sport_id = s.id WHERE s.id IS NULL;
