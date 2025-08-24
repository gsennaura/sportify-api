/*
League tables for SportifyAPI
- Competitions organized by federations
- Teams participating in leagues
- Configurable eligibility rules
*/

-- Leagues table - competitions organized by federations
CREATE TABLE IF NOT EXISTS leagues (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    season_year INTEGER NOT NULL,
    federation_id INTEGER REFERENCES federations(id) ON DELETE SET NULL,
    sport_id INTEGER REFERENCES sports(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    start_date DATE,
    end_date DATE,
    format VARCHAR(30) CHECK (format IN ('round-robin', 'knockout', 'group+knockout', 'swiss')),
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'mixed')),
    status VARCHAR(20) CHECK (status IN ('planned', 'ongoing', 'completed', 'cancelled')) DEFAULT 'planned',
    active BOOLEAN DEFAULT true,
    UNIQUE(name, season_year, category_id)
);

-- League teams - teams participating in leagues
CREATE TABLE IF NOT EXISTS league_teams (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    registration_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'withdrawn', 'disqualified')),
    UNIQUE(league_id, team_id)
);

-- Eligibility rules for player participation
CREATE TABLE IF NOT EXISTS eligibility_rules (
    id SERIAL PRIMARY KEY,
    federation_id INTEGER REFERENCES federations(id) ON DELETE CASCADE,
    league_id INTEGER REFERENCES leagues(id) ON DELETE CASCADE,
    allow_cross_team_within_federation BOOLEAN DEFAULT false,
    allow_cross_federation BOOLEAN DEFAULT true,
    allow_cross_league BOOLEAN DEFAULT false,
    min_days_between_team_changes INTEGER DEFAULT 0,
    description TEXT,
    active BOOLEAN DEFAULT true,
    CHECK (federation_id IS NOT NULL OR league_id IS NOT NULL)
);

-- League relationships for cross-league eligibility
CREATE TABLE IF NOT EXISTS league_relationships (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    related_league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    allow_shared_players BOOLEAN DEFAULT false,
    UNIQUE(league_id, related_league_id)
);

-- Add comments for documentation
COMMENT ON TABLE leagues IS 'Competitions organized by federations';
COMMENT ON TABLE league_teams IS 'Teams participating in leagues';
COMMENT ON TABLE eligibility_rules IS 'Rules governing player eligibility across teams and leagues';
COMMENT ON TABLE league_relationships IS 'Specific eligibility rules between two leagues';