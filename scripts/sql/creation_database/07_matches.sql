/*
Match tables for SportifyAPI
- Match scheduling and results
- Player participation in matches
- Match events and statistics
*/

-- Matches table - individual games/matches
CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    league_id INTEGER NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    home_team_id INTEGER REFERENCES teams(id) ON DELETE CASCADE,
    away_team_id INTEGER REFERENCES teams(id) ON DELETE CASCADE,
    match_number INTEGER, -- Round number or match identifier within competition
    scheduled_datetime TIMESTAMP NOT NULL,
    venue_id INTEGER REFERENCES venues(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'scheduled' 
        CHECK (status IN ('scheduled', 'ongoing', 'completed', 'postponed', 'cancelled')),
    home_score INTEGER,
    away_score INTEGER,
    notes TEXT
);

-- Match squads - players selected for a match
CREATE TABLE match_squads (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    jersey_number INTEGER CHECK (jersey_number > 0 AND jersey_number <= 99),
    is_starter BOOLEAN DEFAULT false,
    position VARCHAR(50),
    UNIQUE(match_id, team_id, player_id)
);

-- Match events - goals, cards, substitutions, etc.
CREATE TABLE match_events (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    event_type VARCHAR(30) NOT NULL 
        CHECK (event_type IN ('goal', 'assist', 'yellow_card', 'red_card', 'substitution_in', 
                             'substitution_out', 'penalty_scored', 'penalty_missed', 'own_goal')),
    minute INTEGER NOT NULL CHECK (minute >= 0),
    additional_time INTEGER DEFAULT 0 CHECK (additional_time >= 0),
    details JSONB
);

-- Match statistics - team and player statistics
CREATE TABLE match_statistics (
    id SERIAL PRIMARY KEY,
    match_id INTEGER NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id INTEGER REFERENCES teams(id) ON DELETE CASCADE,
    player_id INTEGER REFERENCES players(id) ON DELETE CASCADE,
    statistic_type VARCHAR(50) NOT NULL,
    value NUMERIC(10,2) NOT NULL,
    CHECK (team_id IS NOT NULL OR player_id IS NOT NULL)
);

-- Add comments for documentation
COMMENT ON TABLE matches IS 'Individual matches/games between teams';
COMMENT ON TABLE match_squads IS 'Players selected for a match';
COMMENT ON TABLE match_events IS 'Key events during matches like goals and cards';
COMMENT ON TABLE match_statistics IS 'Statistical data from matches';
