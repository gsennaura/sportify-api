/*
Sample data for testing the SportifyAPI database
This script provides minimal data to test core functionality
*/

-- Countries
INSERT INTO countries (name, iso_code) VALUES
    ('Brasil', 'BR'),
    ('Argentina', 'AR'),
    ('Espanha', 'ES'),
    ('Inglaterra', 'GB'),
    ('Estados Unidos', 'US')
ON CONFLICT (iso_code) DO NOTHING;

-- States
INSERT INTO states (name, abbreviation, country_id) VALUES
    ('São Paulo', 'SP', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Rio de Janeiro', 'RJ', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Buenos Aires', 'BA', (SELECT id FROM countries WHERE iso_code = 'AR'))
ON CONFLICT DO NOTHING;

-- Cities
INSERT INTO cities (name, state_id) VALUES
    ('São Paulo', (SELECT id FROM states WHERE abbreviation = 'SP')),
    ('Rio de Janeiro', (SELECT id FROM states WHERE abbreviation = 'RJ')),
    ('Buenos Aires', (SELECT id FROM states WHERE abbreviation = 'BA'))
ON CONFLICT DO NOTHING;

-- Venues
INSERT INTO venues (name, capacity, city_id) VALUES
    ('Maracanã', 78000, (SELECT id FROM cities WHERE name = 'Rio de Janeiro')),
    ('Morumbi', 66000, (SELECT id FROM cities WHERE name = 'São Paulo')),
    ('La Bombonera', 54000, (SELECT id FROM cities WHERE name = 'Buenos Aires'))
ON CONFLICT DO NOTHING;

-- People (for players, coaches, officials)
INSERT INTO people (first_name, last_name, birth_date, gender, nationality_id) VALUES
    ('João', 'Silva', '1990-05-15', 'male', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Carlos', 'Oliveira', '1985-03-22', 'male', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Maria', 'Santos', '1992-07-10', 'female', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Lionel', 'Messi', '1987-06-24', 'male', (SELECT id FROM countries WHERE iso_code = 'AR')),
    ('Roberto', 'Martinez', '1973-07-13', 'male', (SELECT id FROM countries WHERE iso_code = 'ES'))
ON CONFLICT DO NOTHING;

-- Players
INSERT INTO players (person_id, height, weight, dominant_foot, position_id) VALUES
    ((SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva'), 178, 75, 'right', (SELECT id FROM player_positions WHERE name = 'Atacante')),
    ((SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi'), 170, 72, 'left', (SELECT id FROM player_positions WHERE name = 'Atacante'))
ON CONFLICT DO NOTHING;

-- Entities
INSERT INTO entities (name, short_name, type, country_id, city_id) VALUES
    ('Clube de Regatas do Flamengo', 'Flamengo', 'club', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Rio de Janeiro')),
    ('Santos Futebol Clube', 'Santos', 'club', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'São Paulo')),
    ('Confederação Brasileira de Futebol', 'CBF', 'federation', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Rio de Janeiro'))
ON CONFLICT DO NOTHING;

-- Sports (already inserted in 03_organizations.sql)

-- Federations (now independent from entities)
INSERT INTO federations (name, acronym, sport_id, geographic_scope, country_id, city_id) VALUES
    ('Confederação Brasileira de Futebol', 'CBF', (SELECT id FROM sports WHERE name = 'Futebol'), 'national', 
     (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Rio de Janeiro'))
ON CONFLICT DO NOTHING;

-- Teams (now with direct category_id and federation_id references)
INSERT INTO teams (name, short_name, entity_id, sport_id, category_id, federation_id, city_id, main_venue_id) VALUES
    ('Flamengo', 'FLA', (SELECT id FROM entities WHERE short_name = 'Flamengo'), (SELECT id FROM sports WHERE name = 'Futebol'), 
     (SELECT id FROM categories WHERE short_name = 'PRO'), (SELECT id FROM federations WHERE acronym = 'CBF'), (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), (SELECT id FROM venues WHERE name = 'Maracanã')),
    ('Santos', 'SAN', (SELECT id FROM entities WHERE short_name = 'Santos'), (SELECT id FROM sports WHERE name = 'Futebol'), 
     (SELECT id FROM categories WHERE short_name = 'PRO'), (SELECT id FROM federations WHERE acronym = 'CBF'), (SELECT id FROM cities WHERE name = 'São Paulo'), (SELECT id FROM venues WHERE name = 'Morumbi')),
    ('Flamengo Sub-20', 'FLA-U20', (SELECT id FROM entities WHERE short_name = 'Flamengo'), (SELECT id FROM sports WHERE name = 'Futebol'), 
     (SELECT id FROM categories WHERE short_name = 'U20'), (SELECT id FROM federations WHERE acronym = 'CBF'), (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), (SELECT id FROM venues WHERE name = 'Maracanã'))
ON CONFLICT DO NOTHING;

-- Staff and their roles
-- Add an extra coach for sample data
INSERT INTO people (first_name, last_name, birth_date, gender, nationality_id) VALUES
    ('Paulo', 'Ferreira', '1980-01-20', 'male', (SELECT id FROM countries WHERE iso_code = 'BR'))
ON CONFLICT DO NOTHING;

-- Create staff entries
INSERT INTO staff (person_id, main_role_id) VALUES
    ((SELECT id FROM people WHERE first_name = 'Roberto' AND last_name = 'Martinez'), 
     (SELECT id FROM role_types WHERE name = 'Técnico Principal')),
    ((SELECT id FROM people WHERE first_name = 'Paulo' AND last_name = 'Ferreira'), 
     (SELECT id FROM role_types WHERE name = 'Técnico Principal')),
    ((SELECT id FROM people WHERE first_name = 'Carlos' AND last_name = 'Oliveira'), 
     (SELECT id FROM role_types WHERE name = 'Presidente'))
ON CONFLICT DO NOTHING;

-- Team staff affiliations - staff working for teams
INSERT INTO team_staff_affiliations (staff_id, team_id, role_id) VALUES
    -- Roberto Martinez - Head Coach for Flamengo Professional team
    ((SELECT s.id FROM staff s JOIN people p ON s.person_id = p.id WHERE p.first_name = 'Roberto' AND p.last_name = 'Martinez'),
     (SELECT id FROM teams WHERE short_name = 'FLA' AND name = 'Flamengo'),
     (SELECT id FROM role_types WHERE name = 'Técnico Principal')),
    
    -- Paulo Ferreira - Head Coach for Flamengo U20 team
    ((SELECT s.id FROM staff s JOIN people p ON s.person_id = p.id WHERE p.first_name = 'Paulo' AND p.last_name = 'Ferreira'),
     (SELECT id FROM teams WHERE short_name = 'FLA-U20'),
     (SELECT id FROM role_types WHERE name = 'Técnico Principal')),
    
    -- Carlos Oliveira - Club President (for main team)
    ((SELECT s.id FROM staff s JOIN people p ON s.person_id = p.id WHERE p.first_name = 'Carlos' AND p.last_name = 'Oliveira'),
     (SELECT id FROM teams WHERE short_name = 'FLA' AND name = 'Flamengo'),
     (SELECT id FROM role_types WHERE name = 'Presidente'))
ON CONFLICT DO NOTHING;

-- Player affiliations - with career history
-- First, create more teams to demonstrate career progression
INSERT INTO entities (name, short_name, type, country_id, city_id) VALUES
    ('Palmeiras Futebol Clube', 'Palmeiras', 'club', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'São Paulo'))
ON CONFLICT DO NOTHING;

INSERT INTO teams (name, short_name, entity_id, sport_id, category_id, city_id) VALUES
    ('Palmeiras', 'PAL', 
     (SELECT id FROM entities WHERE short_name = 'Palmeiras'), 
     (SELECT id FROM sports WHERE name = 'Futebol'),
     (SELECT id FROM categories WHERE short_name = 'PRO'),
     (SELECT id FROM cities WHERE name = 'São Paulo'))
ON CONFLICT DO NOTHING;

-- Team transfers for João Silva's career history
INSERT INTO team_transfers (player_id, previous_team_id, team_id, start_date, end_date, status, transfer_type_id, transfer_value) VALUES
    -- João Silva: Santos to Palmeiras
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM teams WHERE short_name = 'SAN'),
     (SELECT id FROM teams WHERE short_name = 'PAL'),
     '2021-07-01', '2022-12-31', 'deactive',
     (SELECT id FROM transfer_types WHERE name = 'Venda'), 1500000.00),
     
    -- João Silva: Palmeiras to Flamengo (current)
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM teams WHERE short_name = 'PAL'),
     (SELECT id FROM teams WHERE short_name = 'FLA'),
     '2023-01-15', NULL, 'active',
     (SELECT id FROM transfer_types WHERE name = 'Venda'), 3000000.00)
ON CONFLICT DO NOTHING;

-- Player team affiliations based on transfers
INSERT INTO player_team_affiliations (player_id, team_id, team_transfer_id, jersey_number) VALUES
    -- João Silva at Flamengo (current)
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM teams WHERE short_name = 'FLA'),
     (SELECT id FROM team_transfers WHERE player_id = (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')) 
      AND team_id = (SELECT id FROM teams WHERE short_name = 'FLA') AND status = 'active'),
     10),
     
    -- Lionel Messi at Santos
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi')),
     (SELECT id FROM teams WHERE short_name = 'SAN'),
     NULL, 10)
ON CONFLICT DO NOTHING;
-- Leagues
INSERT INTO leagues (name, season_year, federation_id, sport_id, category_id, format, gender, start_date, end_date, status) VALUES
    ('Série A do Campeonato Brasileiro', 2023, 
     (SELECT id FROM federations WHERE acronym = 'CBF'),
     (SELECT id FROM sports WHERE name = 'Futebol'),
     (SELECT id FROM categories WHERE short_name = 'PRO'),
     'round-robin', 'male', '2023-04-01', '2023-12-10', 'ongoing'),
    ('Campeonato Brasileiro Sub-20', 2023, 
     (SELECT id FROM federations WHERE acronym = 'CBF'),
     (SELECT id FROM sports WHERE name = 'Futebol'),
     (SELECT id FROM categories WHERE short_name = 'U20'),
     'group+knockout', 'male', '2023-03-15', '2023-10-30', 'ongoing')
ON CONFLICT DO NOTHING;

-- League teams (teams now reference directly, no team_categories table)
INSERT INTO league_teams (league_id, team_id) VALUES
    ((SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023),
     (SELECT id FROM teams WHERE short_name = 'FLA' AND name = 'Flamengo')),
    ((SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023),
     (SELECT id FROM teams WHERE short_name = 'SAN')),
    ((SELECT id FROM leagues WHERE name = 'Campeonato Brasileiro Sub-20' AND season_year = 2023),
     (SELECT id FROM teams WHERE short_name = 'FLA-U20'))
ON CONFLICT DO NOTHING;

-- Eligibility rules
INSERT INTO eligibility_rules (federation_id, allow_cross_team_within_federation, allow_cross_federation) VALUES
    ((SELECT id FROM federations WHERE acronym = 'CBF'), false, true)
ON CONFLICT DO NOTHING;

-- Sample match
INSERT INTO matches (
    league_id, home_team_id, away_team_id, match_number, scheduled_datetime, venue_id, status
) VALUES (
    (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023),
    (SELECT id FROM teams WHERE short_name = 'FLA' AND name = 'Flamengo'),
    (SELECT id FROM teams WHERE short_name = 'SAN'),
    1, '2023-04-15 16:00:00',
    (SELECT id FROM venues WHERE name = 'Maracanã'),
    'scheduled'
)
ON CONFLICT DO NOTHING;

-- Sample match squads (players selected for the match)
INSERT INTO match_squads (
    match_id, team_id, player_id, jersey_number, is_starter, position
) VALUES (
    -- Flamengo squad
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'FLA' AND name = 'Flamengo'),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
    10, true, 'Atacante'),
    
    -- Santos squad
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'SAN'),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi')),
    10, true, 'Atacante')
ON CONFLICT DO NOTHING;

-- Sample match events
INSERT INTO match_events (
    match_id, team_id, player_id, event_type, minute, details
) VALUES (
    -- Goal scored by João Silva
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'FLA' AND name = 'Flamengo'),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
    'goal', 35, '{"description": "Cabeçada incrível de um escanteio"}'),
    
    -- Yellow card for Messi
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'SAN'),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi')),
    'yellow_card', 42, '{"reason": "Falta tática"}')
ON CONFLICT DO NOTHING;

-- Sample match statistics
INSERT INTO match_statistics (
    match_id, team_id, statistic_type, value
) VALUES (
    -- Team statistics
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'FLA' AND name = 'Flamengo'),
    'possession', 55),
    
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'SAN'),
    'possession', 45)
ON CONFLICT DO NOTHING;

INSERT INTO match_statistics (
    match_id, player_id, statistic_type, value
) VALUES (
    -- Player statistics
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
    'shots_on_target', 3),
    
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Série A do Campeonato Brasileiro' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi')),
    'passes_completed', 47)
ON CONFLICT DO NOTHING;
