/*
Organization tables for SportifyAPI
- Generic entities for organizational structures
- Sports definition
- Federations as sports governing bodies
*/

-- Sports table - defines sports disciplines
CREATE TABLE IF NOT EXISTS sports (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    team_based BOOLEAN NOT NULL DEFAULT true, -- Individual vs team sport
    active BOOLEAN DEFAULT true,
    UNIQUE(name)
);

-- Insert common sports
INSERT INTO sports (name, team_based) VALUES
    ('Futebol', true),
    ('Basquete', true),
    ('Vôlei', true),
    ('Tênis', false),
    ('Natação', false),
    ('Atletismo', false)
ON CONFLICT (name) DO NOTHING;

-- Entities table - generic organizations
CREATE TABLE IF NOT EXISTS entities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    short_name VARCHAR(20),
    type VARCHAR(20) NOT NULL CHECK (type IN ('club', 'federation', 'association', 'company', 'government')),
    foundation_date DATE,
    country_id INTEGER REFERENCES countries(id) ON DELETE SET NULL,
    city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL,
    logo_url VARCHAR(255),
    website VARCHAR(255),
    active BOOLEAN DEFAULT true
);

-- Federations table - sports governing bodies
CREATE TABLE IF NOT EXISTS federations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    acronym VARCHAR(20),
    sport_id INTEGER NOT NULL REFERENCES sports(id) ON DELETE CASCADE,
    geographic_scope VARCHAR(30) CHECK (geographic_scope IN ('global', 'continental', 'national', 'regional', 'state', 'local')),
    parent_federation_id INTEGER REFERENCES federations(id) ON DELETE SET NULL,
    country_id INTEGER REFERENCES countries(id) ON DELETE SET NULL,
    city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL,
    foundation_date DATE,
    logo_url VARCHAR(255),
    website VARCHAR(255),
    active BOOLEAN DEFAULT true
);

-- Federation staff - staff with roles in federations
CREATE TABLE IF NOT EXISTS federation_staff (
    id SERIAL PRIMARY KEY,
    federation_id INTEGER NOT NULL REFERENCES federations(id) ON DELETE CASCADE,
    staff_id INTEGER NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES role_types(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    active BOOLEAN DEFAULT true
);

-- Organization staff - people with roles in organizations
CREATE TABLE IF NOT EXISTS organization_staff (
    id SERIAL PRIMARY KEY,
    entity_id INTEGER NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES role_types(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    active BOOLEAN DEFAULT true
);

-- Add comments for documentation
COMMENT ON TABLE sports IS 'Different sports disciplines supported by the system';
COMMENT ON TABLE entities IS 'Generic organizations like clubs, federations, and companies';
COMMENT ON TABLE federations IS 'Sports governing bodies at different levels';
COMMENT ON TABLE federation_staff IS 'Staff with roles in federations';
COMMENT ON TABLE organization_staff IS 'People with roles in organizations';
