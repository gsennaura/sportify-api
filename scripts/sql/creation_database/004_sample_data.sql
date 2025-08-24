-- ===========================================================
-- Sample Data for SportifyAPI
-- ===========================================================

-- Insert sample countries
INSERT INTO countries (name, iso_code) VALUES
('Brazil', 'BR'),
('Argentina', 'AR'),
('United States', 'US'),
('Germany', 'DE'),
('Spain', 'ES'),
('France', 'FR'),
('Italy', 'IT'),
('United Kingdom', 'GB')
ON CONFLICT (iso_code) DO NOTHING;

-- Insert sample states (focusing on Brazil and Argentina)
INSERT INTO states (name, abbreviation, country_id) VALUES
('São Paulo', 'SP', (SELECT id FROM countries WHERE iso_code = 'BR')),
('Rio de Janeiro', 'RJ', (SELECT id FROM countries WHERE iso_code = 'BR')),
('Minas Gerais', 'MG', (SELECT id FROM countries WHERE iso_code = 'BR')),
('Rio Grande do Sul', 'RS', (SELECT id FROM countries WHERE iso_code = 'BR')),
('Buenos Aires', 'BA', (SELECT id FROM countries WHERE iso_code = 'AR')),
('Córdoba', 'CB', (SELECT id FROM countries WHERE iso_code = 'AR')),
('Santa Fe', 'SF', (SELECT id FROM countries WHERE iso_code = 'AR'))
ON CONFLICT DO NOTHING;

-- Insert sample cities
INSERT INTO cities (name, state_id) VALUES
('São Paulo', (SELECT id FROM states WHERE abbreviation = 'SP')),
('Santos', (SELECT id FROM states WHERE abbreviation = 'SP')),
('Campinas', (SELECT id FROM states WHERE abbreviation = 'SP')),
('Rio de Janeiro', (SELECT id FROM states WHERE abbreviation = 'RJ')),
('Niterói', (SELECT id FROM states WHERE abbreviation = 'RJ')),
('Belo Horizonte', (SELECT id FROM states WHERE abbreviation = 'MG')),
('Porto Alegre', (SELECT id FROM states WHERE abbreviation = 'RS')),
('Buenos Aires', (SELECT id FROM states WHERE abbreviation = 'BA')),
('La Plata', (SELECT id FROM states WHERE abbreviation = 'BA')),
('Córdoba', (SELECT id FROM states WHERE abbreviation = 'CB'))
ON CONFLICT DO NOTHING;

-- Insert sample sports
INSERT INTO sports (name, description, team_based) VALUES
('Football', 'Association football (soccer)', true),
('Basketball', 'Basketball sport', true),
('Volleyball', 'Volleyball sport', true),
('Tennis', 'Tennis sport', false),
('Swimming', 'Swimming sport', false),
('Athletics', 'Track and field athletics', false)
ON CONFLICT (name) DO NOTHING;

-- Insert sample federations
INSERT INTO federations (name, acronym, sport_id, geographic_scope, city_id, foundation_date, website) VALUES
('Fédération Internationale de Football Association', 'FIFA', 
 (SELECT id FROM sports WHERE name = 'Football'), 'global', 
 NULL, '1904-05-21', 'https://www.fifa.com'),
 
('Confederação Brasileira de Futebol', 'CBF', 
 (SELECT id FROM sports WHERE name = 'Football'), 'national', 
 (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), '1914-08-08', 'https://www.cbf.com.br'),
 
('Asociación del Fútbol Argentino', 'AFA', 
 (SELECT id FROM sports WHERE name = 'Football'), 'national', 
 (SELECT id FROM cities WHERE name = 'Buenos Aires'), '1893-02-21', 'https://www.afa.com.ar'),
 
('Federação Paulista de Futebol', 'FPF', 
 (SELECT id FROM sports WHERE name = 'Football'), 'state', 
 (SELECT id FROM cities WHERE name = 'São Paulo'), '1941-04-22', 'https://www.fpf.org.br'),
 
('Federação de Futebol do Estado do Rio de Janeiro', 'FFERJ', 
 (SELECT id FROM sports WHERE name = 'Football'), 'state', 
 (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), '1978-12-02', 'https://www.fferj.com.br')
ON CONFLICT DO NOTHING;

-- Update parent federation relationships
UPDATE federations SET parent_federation_id = (SELECT id FROM federations WHERE acronym = 'CBF')
WHERE acronym IN ('FPF', 'FFERJ');

UPDATE federations SET parent_federation_id = (SELECT id FROM federations WHERE acronym = 'FIFA')
WHERE acronym IN ('CBF', 'AFA');

-- Insert sample staff roles
INSERT INTO staff_roles (name, description, category) VALUES
('Head Coach', 'Principal coach responsible for team strategy and training', 'technical'),
('Assistant Coach', 'Coach that assists the head coach', 'technical'),
('Physical Trainer', 'Responsible for physical conditioning', 'technical'),
('Goalkeeper Coach', 'Specialized coach for goalkeepers', 'technical'),
('Team Doctor', 'Medical doctor responsible for team health', 'medical'),
('Physiotherapist', 'Physical therapy specialist', 'medical'),
('Team Manager', 'Administrative manager of the team', 'management'),
('Technical Director', 'Technical director of the federation/club', 'management'),
('President', 'President of the federation/club', 'administrative'),
('Secretary', 'Administrative secretary', 'administrative')
ON CONFLICT (name) DO NOTHING;

-- Insert sample referee roles
INSERT INTO referee_roles (name, description) VALUES
('Main Referee', 'Principal referee of the match'),
('Assistant Referee', 'Linesman or assistant referee'),
('Fourth Official', 'Fourth official managing technical area'),
('VAR Referee', 'Video Assistant Referee')
ON CONFLICT (name) DO NOTHING;

-- Insert sample athlete positions (football)
INSERT INTO athlete_positions (name, description) VALUES
('Goalkeeper', 'Player who guards the goal'),
('Right Back', 'Defender on the right side'),
('Left Back', 'Defender on the left side'),
('Centre Back', 'Central defender'),
('Defensive Midfielder', 'Midfielder with defensive focus'),
('Central Midfielder', 'Central midfield player'),
('Attacking Midfielder', 'Midfielder with attacking focus'),
('Right Winger', 'Attacker on the right wing'),
('Left Winger', 'Attacker on the left wing'),
('Centre Forward', 'Central attacking player'),
('Striker', 'Main goal scorer')
ON CONFLICT (name) DO NOTHING;

-- Insert sample people
INSERT INTO people (first_name, last_name, document, birth_date, gender, nationality_id, birth_city_id) VALUES
('Carlos', 'Silva', '12345678901', '1985-03-15', 'male', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'São Paulo')),
('Maria', 'Santos', '23456789012', '1990-07-22', 'female', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Rio de Janeiro')),
('José', 'Oliveira', '34567890123', '1988-11-10', 'male', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Belo Horizonte')),
('Ana', 'Costa', '45678901234', '1992-02-28', 'female', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Porto Alegre')),
('Diego', 'Rodriguez', '56789012345', '1987-09-05', 'male', (SELECT id FROM countries WHERE iso_code = 'AR'), (SELECT id FROM cities WHERE name = 'Buenos Aires')),
('Luisa', 'García', '67890123456', '1991-12-18', 'female', (SELECT id FROM countries WHERE iso_code = 'AR'), (SELECT id FROM cities WHERE name = 'Córdoba')),
('Roberto', 'Fernandez', '78901234567', '1983-06-12', 'male', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Santos')),
('Patricia', 'Lima', '89012345678', '1989-04-30', 'female', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Campinas')),
('Miguel', 'Pereira', '90123456789', '1986-08-25', 'male', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Niterói')),
('Sofia', 'Martins', '01234567890', '1993-01-14', 'female', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'São Paulo'))
ON CONFLICT (document) DO NOTHING;

-- Insert sample athletes
INSERT INTO athletes (person_id, athlete_number, primary_sport_id, status) VALUES
((SELECT id FROM people WHERE document = '12345678901'), 'ATH001', (SELECT id FROM sports WHERE name = 'Football'), 'active'),
((SELECT id FROM people WHERE document = '23456789012'), 'ATH002', (SELECT id FROM sports WHERE name = 'Football'), 'active'),
((SELECT id FROM people WHERE document = '34567890123'), 'ATH003', (SELECT id FROM sports WHERE name = 'Football'), 'active'),
((SELECT id FROM people WHERE document = '45678901234'), 'ATH004', (SELECT id FROM sports WHERE name = 'Basketball'), 'active'),
((SELECT id FROM people WHERE document = '56789012345'), 'ATH005', (SELECT id FROM sports WHERE name = 'Football'), 'active')
ON CONFLICT (person_id) DO NOTHING;

-- Insert sample staff
INSERT INTO staff (person_id, staff_registry_number, status) VALUES
((SELECT id FROM people WHERE document = '67890123456'), 'STF001', 'active'),
((SELECT id FROM people WHERE document = '78901234567'), 'STF002', 'active'),
((SELECT id FROM people WHERE document = '89012345678'), 'STF003', 'active')
ON CONFLICT (person_id) DO NOTHING;

-- Insert sample referees
INSERT INTO referees (person_id, referee_registry_number, grade, status) VALUES
((SELECT id FROM people WHERE document = '90123456789'), 'REF001', 'FIFA', 'active'),
((SELECT id FROM people WHERE document = '01234567890'), 'REF002', 'National', 'active')
ON CONFLICT (person_id) DO NOTHING;

-- Insert sample clubs
INSERT INTO clubs (name, short_name, acronym, federation_id, city_id, foundation_date, website) VALUES
('São Paulo Futebol Clube', 'São Paulo', 'SPFC', 
 (SELECT id FROM federations WHERE acronym = 'FPF'), 
 (SELECT id FROM cities WHERE name = 'São Paulo'), 
 '1930-01-25', 'https://www.saopaulofc.net'),
 
('Santos Futebol Clube', 'Santos', 'SFC', 
 (SELECT id FROM federations WHERE acronym = 'FPF'), 
 (SELECT id FROM cities WHERE name = 'Santos'), 
 '1912-04-14', 'https://www.santosfc.com.br'),
 
('Clube de Regatas do Flamengo', 'Flamengo', 'FLA', 
 (SELECT id FROM federations WHERE acronym = 'FFERJ'), 
 (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), 
 '1895-11-17', 'https://www.flamengo.com.br'),
 
('Clube Atlético Mineiro', 'Atlético-MG', 'CAM', 
 (SELECT id FROM federations WHERE acronym = 'CBF'), 
 (SELECT id FROM cities WHERE name = 'Belo Horizonte'), 
 '1908-03-25', 'https://www.atletico.com.br')
ON CONFLICT DO NOTHING;

-- Insert some athlete position tags
INSERT INTO athlete_position_tags (athlete_id, position_id) VALUES
((SELECT person_id FROM athletes WHERE athlete_number = 'ATH001'), (SELECT id FROM athlete_positions WHERE name = 'Centre Forward')),
((SELECT person_id FROM athletes WHERE athlete_number = 'ATH002'), (SELECT id FROM athlete_positions WHERE name = 'Central Midfielder')),
((SELECT person_id FROM athletes WHERE athlete_number = 'ATH003'), (SELECT id FROM athlete_positions WHERE name = 'Centre Back')),
((SELECT person_id FROM athletes WHERE athlete_number = 'ATH005'), (SELECT id FROM athlete_positions WHERE name = 'Left Winger'))
ON CONFLICT DO NOTHING;

-- Insert some staff role tags
INSERT INTO staff_role_tags (staff_id, role_id) VALUES
((SELECT person_id FROM staff WHERE staff_registry_number = 'STF001'), (SELECT id FROM staff_roles WHERE name = 'Head Coach')),
((SELECT person_id FROM staff WHERE staff_registry_number = 'STF002'), (SELECT id FROM staff_roles WHERE name = 'Team Manager')),
((SELECT person_id FROM staff WHERE staff_registry_number = 'STF003'), (SELECT id FROM staff_roles WHERE name = 'Physical Trainer'))
ON CONFLICT DO NOTHING;

-- Insert some referee role tags
INSERT INTO referee_role_tags (referee_id, role_id) VALUES
((SELECT person_id FROM referees WHERE referee_registry_number = 'REF001'), (SELECT id FROM referee_roles WHERE name = 'Main Referee')),
((SELECT person_id FROM referees WHERE referee_registry_number = 'REF002'), (SELECT id FROM referee_roles WHERE name = 'Assistant Referee'))
ON CONFLICT DO NOTHING;

-- Insert sample club athlete assignments
INSERT INTO club_athlete_assignments (club_id, athlete_id, position_id, shirt_number, status, start_date) VALUES
((SELECT id FROM clubs WHERE acronym = 'SPFC'), (SELECT person_id FROM athletes WHERE athlete_number = 'ATH001'), (SELECT id FROM athlete_positions WHERE name = 'Centre Forward'), 9, 'active', '2024-01-15'),
((SELECT id FROM clubs WHERE acronym = 'SFC'), (SELECT person_id FROM athletes WHERE athlete_number = 'ATH002'), (SELECT id FROM athlete_positions WHERE name = 'Central Midfielder'), 8, 'active', '2024-02-01'),
((SELECT id FROM clubs WHERE acronym = 'FLA'), (SELECT person_id FROM athletes WHERE athlete_number = 'ATH003'), (SELECT id FROM athlete_positions WHERE name = 'Centre Back'), 4, 'active', '2024-01-10'),
((SELECT id FROM clubs WHERE acronym = 'CAM'), (SELECT person_id FROM athletes WHERE athlete_number = 'ATH005'), (SELECT id FROM athlete_positions WHERE name = 'Left Winger'), 11, 'active', '2024-03-01')
ON CONFLICT DO NOTHING;

-- Insert sample club staff assignments
INSERT INTO club_staff_assignments (club_id, staff_id, role_id, status, start_date) VALUES
((SELECT id FROM clubs WHERE acronym = 'SPFC'), (SELECT person_id FROM staff WHERE staff_registry_number = 'STF001'), (SELECT id FROM staff_roles WHERE name = 'Head Coach'), 'active', '2024-01-01'),
((SELECT id FROM clubs WHERE acronym = 'SFC'), (SELECT person_id FROM staff WHERE staff_registry_number = 'STF002'), (SELECT id FROM staff_roles WHERE name = 'Team Manager'), 'active', '2024-01-15'),
((SELECT id FROM clubs WHERE acronym = 'FLA'), (SELECT person_id FROM staff WHERE staff_registry_number = 'STF003'), (SELECT id FROM staff_roles WHERE name = 'Physical Trainer'), 'active', '2024-02-01')
ON CONFLICT DO NOTHING;

-- Insert sample federation staff assignments
INSERT INTO federation_staff_assignments (federation_id, staff_id, role_id, status, start_date) VALUES
((SELECT id FROM federations WHERE acronym = 'CBF'), (SELECT person_id FROM staff WHERE staff_registry_number = 'STF001'), (SELECT id FROM staff_roles WHERE name = 'Technical Director'), 'active', '2023-01-01'),
((SELECT id FROM federations WHERE acronym = 'FPF'), (SELECT person_id FROM staff WHERE staff_registry_number = 'STF002'), (SELECT id FROM staff_roles WHERE name = 'Secretary'), 'active', '2023-06-15')
ON CONFLICT DO NOTHING;