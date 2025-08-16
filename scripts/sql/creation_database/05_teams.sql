/*
Team tables for SportifyAPI
- Teams with venues and categories
- Team-category relationships for different age groups/levels
- Player affiliations with teams
*/

-- Teams table - core team information
CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    short_name VARCHAR(30),
    entity_id INTEGER NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    sport_id INTEGER NOT NULL REFERENCES sports(id) ON DELETE CASCADE,
    foundation_date DATE,
    logo_url VARCHAR(255),
    primary_color VARCHAR(20),
    secondary_color VARCHAR(20),
    city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL,
    main_venue_id INTEGER REFERENCES venues(id) ON DELETE SET NULL,
    active BOOLEAN DEFAULT true,
    CONSTRAINT unique_team_name UNIQUE (entity_id, name, sport_id)
);

-- Team categories - a team can have multiple categories (e.g., U17, Professional)
CREATE TABLE team_categories (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    season_year INTEGER NOT NULL,
    active BOOLEAN DEFAULT true,
    UNIQUE(team_id, category_id, season_year)
);

-- Team staff - coaches, directors, etc.
CREATE TABLE team_staff (
    id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    team_category_id INTEGER REFERENCES team_categories(id) ON DELETE CASCADE, -- Staff can be assigned to specific categories
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES role_types(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    active BOOLEAN DEFAULT true,
    -- Allow same person to have different roles in different categories
    CONSTRAINT unique_team_staff_role UNIQUE (team_id, team_category_id, person_id, role_id, COALESCE(end_date, '9999-12-31'::DATE))
);

-- Player team affiliations - players registered with teams/categories
CREATE TABLE player_team_affiliations (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    season_year INTEGER NOT NULL,
    jersey_number INTEGER CHECK (jersey_number > 0 AND jersey_number <= 99),
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' 
        CHECK (status IN ('active', 'inactive', 'loaned', 'injured', 'suspended', 'released')),
    transfer_type VARCHAR(30) CHECK (transfer_type IN ('permanent', 'loan', 'free_transfer', 'youth_academy', 'return_from_loan', 'promoted')),
    transfer_fee DECIMAL(15,2),
    contract_years INTEGER,
    previous_team_id INTEGER REFERENCES teams(id) ON DELETE SET NULL,
    achievement_summary TEXT,
    notes TEXT,
    UNIQUE(player_id, team_id, category_id, season_year, COALESCE(end_date, '9999-12-31'::DATE))
);

-- Player career achievements - detailed accomplishments during their career
CREATE TABLE player_achievements (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    affiliation_id INTEGER REFERENCES player_team_affiliations(id) ON DELETE SET NULL,
    league_id INTEGER REFERENCES leagues(id) ON DELETE SET NULL,
    achievement_type VARCHAR(50) NOT NULL,
    achievement_name VARCHAR(255) NOT NULL,
    achievement_date DATE,
    season_year INTEGER,
    details TEXT,
    is_team_achievement BOOLEAN DEFAULT false
);

-- Player career statistics - aggregated statistics per season
CREATE TABLE player_career_statistics (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    affiliation_id INTEGER REFERENCES player_team_affiliations(id) ON DELETE SET NULL,
    season_year INTEGER NOT NULL,
    games_played INTEGER DEFAULT 0,
    games_started INTEGER DEFAULT 0,
    minutes_played INTEGER DEFAULT 0,
    goals_scored INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    yellow_cards INTEGER DEFAULT 0,
    red_cards INTEGER DEFAULT 0,
    additional_stats JSONB -- For sport-specific statistics
);

-- Create view for player career history
CREATE OR REPLACE VIEW player_career_history AS
SELECT 
    p.id AS player_id,
    CONCAT(pp.first_name, ' ', pp.last_name) AS player_name,
    t.name AS team_name,
    c.name AS category_name,
    pta.season_year,
    pta.start_date,
    pta.end_date,
    pta.status,
    pta.transfer_type,
    pta.transfer_fee,
    pt.name AS previous_team_name,
    pta.achievement_summary,
    (SELECT COUNT(*) FROM player_achievements pa WHERE pa.affiliation_id = pta.id) AS achievement_count,
    (SELECT COUNT(*) FROM player_career_statistics pcs WHERE pcs.affiliation_id = pta.id) AS has_statistics
FROM 
    player_team_affiliations pta
JOIN 
    players p ON pta.player_id = p.id
JOIN 
    people pp ON p.person_id = pp.id
JOIN 
    teams t ON pta.team_id = t.id
JOIN 
    categories c ON pta.category_id = c.id
LEFT JOIN 
    teams pt ON pta.previous_team_id = pt.id
ORDER BY 
    pp.last_name, pp.first_name, pta.start_date DESC;

-- Add comments for documentation
COMMENT ON TABLE teams IS 'Sports teams that can participate in competitions';
COMMENT ON TABLE team_categories IS 'Teams participating in specific categories for a season';
COMMENT ON TABLE team_staff IS 'Staff members with roles in teams, can be assigned to specific categories';
COMMENT ON COLUMN team_staff.team_category_id IS 'When NULL, the staff member role applies to the entire team; when specified, only to that category';
COMMENT ON TABLE player_team_affiliations IS 'Player registrations with teams and categories';
COMMENT ON TABLE player_achievements IS 'Individual and team achievements earned by players';
COMMENT ON TABLE player_career_statistics IS 'Statistical performance data for players by season';
COMMENT ON VIEW player_career_history IS 'Comprehensive view of player career movements between teams';
