-- ===========================================================
-- Schema for Sports Federations Management
-- ===========================================================

CREATE EXTENSION IF NOT EXISTS citext; 

-- Simple trigger function for updated_at timestamp
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END$$;

-- Countries
CREATE TABLE IF NOT EXISTS countries (
    id SERIAL PRIMARY KEY,
    name CITEXT NOT NULL,                       -- Country name (e.g., Brazil)
    iso_code CHAR(2) UNIQUE NOT NULL,           -- ISO-3166-1 alpha-2 code (e.g., BR, US)
    active BOOLEAN NOT NULL DEFAULT TRUE,       -- Whether the country is active in the system
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(), -- Record creation timestamp
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()  -- Last update timestamp
);
COMMENT ON TABLE countries IS 'List of countries (ISO-3166-1 alpha-2).';
COMMENT ON COLUMN countries.name IS 'Official country name.';
COMMENT ON COLUMN countries.iso_code IS 'Two-letter ISO country code.';
COMMENT ON COLUMN countries.active IS 'Defines if the country is active for federation management.';

CREATE TRIGGER trg_countries_updated_at
BEFORE UPDATE ON countries
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- States / Provinces
CREATE TABLE IF NOT EXISTS states (
    id SERIAL PRIMARY KEY,
    name CITEXT NOT NULL,                       -- State or province name
    abbreviation VARCHAR(5) NOT NULL,           -- Short code (e.g., SP, CA)
    country_id INTEGER NOT NULL REFERENCES countries(id) ON DELETE CASCADE, -- FK to country
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE states IS 'States or provinces within a country.';
COMMENT ON COLUMN states.abbreviation IS 'State/province abbreviation (ISO-3166-2-like).';

CREATE TRIGGER trg_states_updated_at
BEFORE UPDATE ON states
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Cities
CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name CITEXT NOT NULL,                       -- City name
    state_id INTEGER REFERENCES states(id) ON DELETE SET NULL, -- FK to state
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE cities IS 'Cities associated with states/provinces.';
COMMENT ON COLUMN cities.state_id IS 'Reference to the state this city belongs to.';

CREATE TRIGGER trg_cities_updated_at
BEFORE UPDATE ON cities
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Sports
CREATE TABLE IF NOT EXISTS sports (
    id SERIAL PRIMARY KEY,
    name CITEXT NOT NULL UNIQUE,               -- Sport name (e.g., Football, Basketball)
    description TEXT,                           -- Sport description
    team_based BOOLEAN NOT NULL DEFAULT TRUE,   -- True if it is a team-based sport
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE sports IS 'List of sports disciplines managed by federations.';

CREATE TRIGGER trg_sports_updated_at
BEFORE UPDATE ON sports
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Geographic scope type
CREATE TYPE geographic_scope AS ENUM (
    'global',
    'continental', 
    'national',
    'regional',
    'state',
    'local'
);

-- Federations
CREATE TABLE IF NOT EXISTS federations (
    id SERIAL PRIMARY KEY,
    name CITEXT NOT NULL,                       -- Federation name (e.g., FIFA, CBF)
    acronym CITEXT,                             -- Federation acronym
    sport_id INTEGER NOT NULL REFERENCES sports(id) ON DELETE CASCADE, -- Sport governed
    geographic_scope geographic_scope NOT NULL, -- Scope: global, continental, national...
    parent_federation_id INTEGER REFERENCES federations(id) ON DELETE SET NULL, -- Parent body
    city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL, -- Headquarters city
    foundation_date DATE,                       -- Federation foundation date
    logo_url TEXT,                              -- Logo image URL
    website TEXT,                               -- Official website
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT federations_website_format_chk CHECK (website IS NULL OR website ~* '^(https?://)'),
    CONSTRAINT federations_logo_format_chk CHECK (logo_url IS NULL OR logo_url ~* '^(https?://)')
);
COMMENT ON TABLE federations IS 'Sports governing bodies (federations, confederations, associations).';
COMMENT ON COLUMN federations.acronym IS 'Short acronym of the federation (e.g., FIFA).';
COMMENT ON COLUMN federations.geographic_scope IS 'Level of federation: global, continental, national, regional, state or local.';
COMMENT ON COLUMN federations.parent_federation_id IS 'Optional parent federation (e.g., FIFA is parent of CBF).';
COMMENT ON COLUMN federations.city_id IS 'City where the headquarters is located.';
COMMENT ON COLUMN federations.foundation_date IS 'Date when the federation was founded.';
COMMENT ON COLUMN federations.logo_url IS 'Link to federation logo image.';
COMMENT ON COLUMN federations.website IS 'Official website of the federation.';

CREATE INDEX IF NOT EXISTS idx_federations_sport_id ON federations(sport_id);
CREATE INDEX IF NOT EXISTS idx_federations_city_id ON federations(city_id);
CREATE INDEX IF NOT EXISTS idx_federations_parent ON federations(parent_federation_id);

CREATE TRIGGER trg_federations_updated_at
BEFORE UPDATE ON federations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();