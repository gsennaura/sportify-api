/*
Sample data for testing the SportifyAPI database
This script provides minimal data to test core functionality
*/

-- Countries
INSERT INTO countries (name, iso_code) VALUES
    ('Brazil', 'BR'),
    ('Argentina', 'AR'),
    ('Spain', 'ES'),
    ('England', 'GB'),
    ('United States', 'US');

-- States
INSERT INTO states (name, abbreviation, country_id) VALUES
    ('São Paulo', 'SP', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Rio de Janeiro', 'RJ', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Buenos Aires', 'BA', (SELECT id FROM countries WHERE iso_code = 'AR'));

-- Cities
INSERT INTO cities (name, state_id) VALUES
    ('São Paulo', (SELECT id FROM states WHERE abbreviation = 'SP')),
    ('Rio de Janeiro', (SELECT id FROM states WHERE abbreviation = 'RJ')),
    ('Buenos Aires', (SELECT id FROM states WHERE abbreviation = 'BA'));

-- Venues
INSERT INTO venues (name, capacity, city_id) VALUES
    ('Maracanã', 78000, (SELECT id FROM cities WHERE name = 'Rio de Janeiro')),
    ('Morumbi', 66000, (SELECT id FROM cities WHERE name = 'São Paulo')),
    ('La Bombonera', 54000, (SELECT id FROM cities WHERE name = 'Buenos Aires'));

-- People (for players, coaches, officials)
INSERT INTO people (first_name, last_name, birth_date, gender, nationality_id) VALUES
    ('João', 'Silva', '1990-05-15', 'male', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Carlos', 'Oliveira', '1985-03-22', 'male', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Maria', 'Santos', '1992-07-10', 'female', (SELECT id FROM countries WHERE iso_code = 'BR')),
    ('Lionel', 'Messi', '1987-06-24', 'male', (SELECT id FROM countries WHERE iso_code = 'AR')),
    ('Roberto', 'Martinez', '1973-07-13', 'male', (SELECT id FROM countries WHERE iso_code = 'ES'));

-- Players
INSERT INTO players (person_id, height, weight, dominant_foot, position) VALUES
    ((SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva'), 178, 75, 'right', 'Forward'),
    ((SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi'), 170, 72, 'left', 'Forward');

-- Entities
INSERT INTO entities (name, short_name, type, country_id, city_id) VALUES
    ('Flamengo Football Club', 'Flamengo', 'club', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Rio de Janeiro')),
    ('Santos Football Club', 'Santos', 'club', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'São Paulo')),
    ('Brazilian Football Confederation', 'CBF', 'federation', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'Rio de Janeiro'));

-- Sports (already inserted in 03_organizations.sql)

-- Federations
INSERT INTO federations (entity_id, sport_id, acronym, geographic_scope) VALUES
    ((SELECT id FROM entities WHERE short_name = 'CBF'), (SELECT id FROM sports WHERE name = 'Football'), 'CBF', 'national');

-- Teams
INSERT INTO teams (name, short_name, entity_id, sport_id, city_id, main_venue_id) VALUES
    ('Flamengo', 'FLA', (SELECT id FROM entities WHERE short_name = 'Flamengo'), (SELECT id FROM sports WHERE name = 'Football'), 
     (SELECT id FROM cities WHERE name = 'Rio de Janeiro'), (SELECT id FROM venues WHERE name = 'Maracanã')),
    ('Santos', 'SAN', (SELECT id FROM entities WHERE short_name = 'Santos'), (SELECT id FROM sports WHERE name = 'Football'), 
     (SELECT id FROM cities WHERE name = 'São Paulo'), (SELECT id FROM venues WHERE name = 'Morumbi'));

-- Team categories
INSERT INTO team_categories (team_id, category_id, season_year) VALUES
    ((SELECT id FROM teams WHERE short_name = 'FLA'), (SELECT id FROM categories WHERE short_name = 'PRO'), 2023),
    ((SELECT id FROM teams WHERE short_name = 'SAN'), (SELECT id FROM categories WHERE short_name = 'PRO'), 2023),
    ((SELECT id FROM teams WHERE short_name = 'FLA'), (SELECT id FROM categories WHERE short_name = 'U20'), 2023);

-- Team staff
-- Add an extra coach for sample data
INSERT INTO people (first_name, last_name, birth_date, gender, nationality_id) VALUES
    ('Paulo', 'Ferreira', '1980-01-20', 'male', (SELECT id FROM countries WHERE iso_code = 'BR'));

-- Staff assignment - showing different coaches for different categories
INSERT INTO team_staff (team_id, team_category_id, person_id, role_id, start_date) VALUES
    -- Roberto Martinez - Head Coach for Professional team
    ((SELECT id FROM teams WHERE short_name = 'FLA'), 
     (SELECT id FROM team_categories 
      WHERE team_id = (SELECT id FROM teams WHERE short_name = 'FLA') 
      AND category_id = (SELECT id FROM categories WHERE short_name = 'PRO')
      AND season_year = 2023),
     (SELECT id FROM people WHERE first_name = 'Roberto' AND last_name = 'Martinez'),
     (SELECT id FROM role_types WHERE name = 'Head Coach'),
     '2023-01-01'),
    
    -- Paulo Ferreira - Head Coach for U20 team
    ((SELECT id FROM teams WHERE short_name = 'FLA'), 
     (SELECT id FROM team_categories 
      WHERE team_id = (SELECT id FROM teams WHERE short_name = 'FLA') 
      AND category_id = (SELECT id FROM categories WHERE short_name = 'U20')
      AND season_year = 2023),
     (SELECT id FROM people WHERE first_name = 'Paulo' AND last_name = 'Ferreira'),
     (SELECT id FROM role_types WHERE name = 'Head Coach'),
     '2023-01-15'),
    
    -- Carlos Oliveira - Club President (applies to the entire club, no specific category)
    ((SELECT id FROM teams WHERE short_name = 'FLA'), 
     NULL, -- NULL team_category_id means this role applies to all categories
     (SELECT id FROM people WHERE first_name = 'Carlos' AND last_name = 'Oliveira'),
     (SELECT id FROM role_types WHERE name = 'President'),
     '2022-01-01');

-- Player affiliations - with career history
-- First, create more teams to demonstrate career progression
INSERT INTO entities (name, short_name, type, country_id, city_id) VALUES
    ('Palmeiras Football Club', 'Palmeiras', 'club', (SELECT id FROM countries WHERE iso_code = 'BR'), (SELECT id FROM cities WHERE name = 'São Paulo'));

INSERT INTO teams (name, short_name, entity_id, sport_id, city_id) VALUES
    ('Palmeiras', 'PAL', 
     (SELECT id FROM entities WHERE short_name = 'Palmeiras'), 
     (SELECT id FROM sports WHERE name = 'Football'), 
     (SELECT id FROM cities WHERE name = 'São Paulo'));

-- Create team categories for the new team
INSERT INTO team_categories (team_id, category_id, season_year) VALUES
    ((SELECT id FROM teams WHERE short_name = 'PAL'), 
     (SELECT id FROM categories WHERE short_name = 'PRO'), 2023);

-- João Silva's career history (multiple teams)
INSERT INTO player_team_affiliations (
    player_id, team_id, category_id, season_year, jersey_number, 
    start_date, end_date, status, transfer_type, transfer_fee, previous_team_id
) VALUES
    -- First club - Santos (youth career 2019-2021)
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM teams WHERE short_name = 'SAN'),
     (SELECT id FROM categories WHERE short_name = 'U20'),
     2019, 23, '2019-01-10', '2021-06-30', 'released', 'youth_academy', NULL, NULL),
     
    -- Second club - Palmeiras (short stint 2021-2022)
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM teams WHERE short_name = 'PAL'),
     (SELECT id FROM categories WHERE short_name = 'PRO'),
     2021, 17, '2021-07-01', '2022-12-31', 'released', 'permanent', 1500000.00, 
     (SELECT id FROM teams WHERE short_name = 'SAN')),
     
    -- Current club - Flamengo (2023-present)
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM teams WHERE short_name = 'FLA'),
     (SELECT id FROM categories WHERE short_name = 'PRO'),
     2023, 10, '2023-01-15', NULL, 'active', 'permanent', 3000000.00,
     (SELECT id FROM teams WHERE short_name = 'PAL'));

-- Lionel Messi at Santos
INSERT INTO player_team_affiliations (
    player_id, team_id, category_id, season_year, jersey_number, 
    start_date, status, transfer_type
) VALUES
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi')),
     (SELECT id FROM teams WHERE short_name = 'SAN'),
     (SELECT id FROM categories WHERE short_name = 'PRO'),
     2023, 10, '2023-02-01', 'active', 'free_transfer');

-- Add some achievements
INSERT INTO player_achievements (
    player_id, affiliation_id, achievement_type, achievement_name, achievement_date, season_year, is_team_achievement
) VALUES
    -- João's achievements at Flamengo
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM player_team_affiliations 
      WHERE player_id = (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva'))
      AND team_id = (SELECT id FROM teams WHERE short_name = 'FLA')
      AND season_year = 2023),
     'personal', 'Top Scorer', '2023-05-20', 2023, false),
     
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM player_team_affiliations 
      WHERE player_id = (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva'))
      AND team_id = (SELECT id FROM teams WHERE short_name = 'FLA')
      AND season_year = 2023),
     'team', 'League Champion', '2023-12-10', 2023, true);

-- Add some career statistics
INSERT INTO player_career_statistics (
    player_id, affiliation_id, season_year, games_played, games_started, minutes_played, goals_scored, assists
) VALUES
    -- João's statistics at Flamengo
    ((SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
     (SELECT id FROM player_team_affiliations 
      WHERE player_id = (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva'))
      AND team_id = (SELECT id FROM teams WHERE short_name = 'FLA')
      AND season_year = 2023),
     2023, 34, 30, 2700, 22, 8);

-- Leagues
INSERT INTO leagues (name, season_year, federation_id, sport_id, category_id, format, gender, start_date, end_date, status) VALUES
    ('Brazilian Serie A', 2023, 
     (SELECT id FROM federations WHERE acronym = 'CBF'),
     (SELECT id FROM sports WHERE name = 'Football'),
     (SELECT id FROM categories WHERE short_name = 'PRO'),
     'round-robin', 'male', '2023-04-01', '2023-12-10', 'ongoing'),
    ('Brazilian U20 Championship', 2023, 
     (SELECT id FROM federations WHERE acronym = 'CBF'),
     (SELECT id FROM sports WHERE name = 'Football'),
     (SELECT id FROM categories WHERE short_name = 'U20'),
     'group+knockout', 'male', '2023-03-15', '2023-10-30', 'ongoing');

-- League teams
INSERT INTO league_teams (league_id, team_category_id) VALUES
    ((SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023),
     (SELECT id FROM team_categories 
      WHERE team_id = (SELECT id FROM teams WHERE short_name = 'FLA') 
      AND category_id = (SELECT id FROM categories WHERE short_name = 'PRO')
      AND season_year = 2023)),
    ((SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023),
     (SELECT id FROM team_categories 
      WHERE team_id = (SELECT id FROM teams WHERE short_name = 'SAN') 
      AND category_id = (SELECT id FROM categories WHERE short_name = 'PRO')
      AND season_year = 2023)),
    ((SELECT id FROM leagues WHERE name = 'Brazilian U20 Championship' AND season_year = 2023),
     (SELECT id FROM team_categories 
      WHERE team_id = (SELECT id FROM teams WHERE short_name = 'FLA') 
      AND category_id = (SELECT id FROM categories WHERE short_name = 'U20')
      AND season_year = 2023));

-- Eligibility rules
INSERT INTO eligibility_rules (federation_id, allow_cross_team_within_federation, allow_cross_federation) VALUES
    ((SELECT id FROM federations WHERE acronym = 'CBF'), false, true);

-- Sample match
INSERT INTO matches (
    league_id, home_team_id, away_team_id, match_number, scheduled_datetime, venue_id, status
) VALUES (
    (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023),
    (SELECT id FROM teams WHERE short_name = 'FLA'),
    (SELECT id FROM teams WHERE short_name = 'SAN'),
    1, '2023-04-15 16:00:00',
    (SELECT id FROM venues WHERE name = 'Maracanã'),
    'scheduled'
);

-- Sample match squads (players selected for the match)
INSERT INTO match_squads (
    match_id, team_id, player_id, jersey_number, is_starter, position
) VALUES (
    -- Flamengo squad
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'FLA'),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
    10, true, 'Forward'
),
(
    -- Santos squad
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'SAN'),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi')),
    10, true, 'Forward'
);

-- Sample match events
INSERT INTO match_events (
    match_id, team_id, player_id, event_type, minute, details
) VALUES (
    -- Goal scored by João Silva
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'FLA'),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
    'goal', 35, '{"description": "Great header from a corner kick"}'
),
(
    -- Yellow card for Messi
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'SAN'),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi')),
    'yellow_card', 42, '{"reason": "Tactical foul"}'
);

-- Sample match statistics
INSERT INTO match_statistics (
    match_id, team_id, statistic_type, value
) VALUES (
    -- Team statistics
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'FLA'),
    'possession', 55
),
(
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM teams WHERE short_name = 'SAN'),
    'possession', 45
);

INSERT INTO match_statistics (
    match_id, player_id, statistic_type, value
) VALUES (
    -- Player statistics
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'João' AND last_name = 'Silva')),
    'shots_on_target', 3
),
(
    (SELECT id FROM matches WHERE league_id = (SELECT id FROM leagues WHERE name = 'Brazilian Serie A' AND season_year = 2023) 
     AND match_number = 1),
    (SELECT id FROM players WHERE person_id = (SELECT id FROM people WHERE first_name = 'Lionel' AND last_name = 'Messi')),
    'passes_completed', 47
);
