/*
Team tables for SportifyAPI
- Teams with venues and categories
- Player affiliations with teams
- Staff and their affiliations with teams
*/

-- Teams table - core team information
CREATE TABLE IF NOT EXISTS teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    short_name VARCHAR(30),
    entity_id INTEGER NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    sport_id INTEGER NOT NULL REFERENCES sports(id) ON DELETE CASCADE,
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    federation_id INTEGER NOT NULL REFERENCES federations(id) ON DELETE CASCADE,
    foundation_date DATE,
    logo_url VARCHAR(255),
    primary_color VARCHAR(20),
    secondary_color VARCHAR(20),
    city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL,
    main_venue_id INTEGER REFERENCES venues(id) ON DELETE SET NULL,
    active BOOLEAN DEFAULT true,
    CONSTRAINT unique_team_name UNIQUE (entity_id, name, sport_id, category_id)
);

-- Transfer types table (must be created BEFORE any transfer tables)
CREATE TABLE IF NOT EXISTS transfer_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    description TEXT
);

-- Insert default transfer types (in Portuguese)
INSERT INTO transfer_types (name, description) VALUES
    ('Venda', 'Transferência definitiva mediante pagamento'),
    ('Empréstimo', 'Transferência temporária para outro clube'),
    ('Livre', 'Jogador sem contrato, chega sem custos'),
    ('Retorno de Empréstimo', 'Jogador retorna de empréstimo'),
    ('Promoção', 'Promoção da base para o profissional'),
    ('Troca', 'Transferência por troca de jogadores')
ON CONFLICT (name) DO NOTHING;

-- Team staff transfers table (staff movements between teams)
CREATE TABLE IF NOT EXISTS team_staff_transfers (
    id SERIAL PRIMARY KEY,
    staff_id INTEGER NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    previous_team_id INTEGER REFERENCES teams(id) ON DELETE SET NULL,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    next_team_id INTEGER REFERENCES teams(id) ON DELETE SET NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'deactive')),
    transfer_type_id INTEGER REFERENCES transfer_types(id) ON DELETE SET NULL,
    transfer_value DECIMAL(15,2),
    season INTEGER,
    role_id INTEGER NOT NULL REFERENCES role_types(id) ON DELETE CASCADE,
    notes TEXT
);

-- Team staff affiliations - staff registered with teams
CREATE TABLE IF NOT EXISTS team_staff_affiliations (
    id SERIAL PRIMARY KEY,
    staff_id INTEGER NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    team_staff_transfer_id INTEGER REFERENCES team_staff_transfers(id) ON DELETE SET NULL,
    role_id INTEGER NOT NULL REFERENCES role_types(id) ON DELETE CASCADE,
    contract_years INTEGER,
    active BOOLEAN DEFAULT true,
    notes TEXT
);

-- Team transfers table (player movements between teams)
CREATE TABLE IF NOT EXISTS team_transfers (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    previous_team_id INTEGER REFERENCES teams(id) ON DELETE SET NULL,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    next_team_id INTEGER REFERENCES teams(id) ON DELETE SET NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'deactive')),
    transfer_type_id INTEGER REFERENCES transfer_types(id) ON DELETE SET NULL,
    transfer_value DECIMAL(15,2),
    season INTEGER,
    notes TEXT
);

-- Player team affiliations - players registered with teams
CREATE TABLE IF NOT EXISTS player_team_affiliations (
    id SERIAL PRIMARY KEY,
    player_id INTEGER NOT NULL REFERENCES players(id) ON DELETE CASCADE,
    team_id INTEGER NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    team_transfer_id INTEGER REFERENCES team_transfers(id) ON DELETE SET NULL,
    jersey_number INTEGER CHECK (jersey_number > 0 AND jersey_number <= 999),
    contract_years INTEGER,
    active BOOLEAN DEFAULT true,
    notes TEXT
);

-- Remove player_achievements and player_career_statistics tables
-- Remove player_career_history view

-- Create indexes for team affiliations to ensure unique combinations
CREATE UNIQUE INDEX idx_team_staff_unique_no_transfer 
    ON team_staff_affiliations(staff_id, team_id, role_id) 
    WHERE team_staff_transfer_id IS NULL;

CREATE UNIQUE INDEX idx_team_staff_unique_with_transfer 
    ON team_staff_affiliations(staff_id, team_id, role_id, team_staff_transfer_id) 
    WHERE team_staff_transfer_id IS NOT NULL;

CREATE UNIQUE INDEX idx_player_team_unique_no_transfer 
    ON player_team_affiliations(player_id, team_id) 
    WHERE team_transfer_id IS NULL;

CREATE UNIQUE INDEX idx_player_team_unique_with_transfer 
    ON player_team_affiliations(player_id, team_id, team_transfer_id) 
    WHERE team_transfer_id IS NOT NULL;

-- Add comments for documentation
COMMENT ON TABLE teams IS 'Sports teams that can participate in competitions. Each team must be registered with a federation to participate in official competitions.';
COMMENT ON TABLE staff IS 'Staff members (coaches, directors, etc), extends people';
COMMENT ON TABLE team_staff_transfers IS 'Staff movements between teams';
COMMENT ON TABLE team_staff_affiliations IS 'Staff registrations with teams, linked to transfers';
COMMENT ON TABLE transfer_types IS 'Types of player transfers (sale, loan, free, etc)';
COMMENT ON TABLE team_transfers IS 'Player movements between teams';
COMMENT ON TABLE player_team_affiliations IS 'Player registrations with teams, linked to transfers';
