/*
Location tables for SportifyAPI
- Countries, States, Cities for geographical structure
- Venues (stadiums) that can be shared by multiple teams
*/

-- Countries table
CREATE TABLE IF NOT EXISTS countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    iso_code CHAR(2) UNIQUE NOT NULL,
    active BOOLEAN DEFAULT true
);

-- States/provinces table
CREATE TABLE IF NOT EXISTS states (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    abbreviation VARCHAR(5) NOT NULL,
    country_id INTEGER NOT NULL REFERENCES countries(id) ON DELETE CASCADE,
    active BOOLEAN DEFAULT true,
    UNIQUE(country_id, abbreviation)
);

-- Cities table
CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    state_id INTEGER REFERENCES states(id) ON DELETE SET NULL,
    active BOOLEAN DEFAULT true
);

-- Venues table (stadiums, arenas, etc.)
CREATE TABLE IF NOT EXISTS venues (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    capacity INTEGER,
    address VARCHAR(255),
    city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL,
    gps_coordinates POINT,
    photo_url VARCHAR(255),
    active BOOLEAN DEFAULT true
);

-- Add comments for documentation
COMMENT ON TABLE venues IS 'Venues represent stadiums, arenas, or other places where sports events take place';
COMMENT ON COLUMN venues.capacity IS 'Maximum number of spectators the venue can hold';
COMMENT ON COLUMN venues.gps_coordinates IS 'Geographic coordinates of the venue (latitude, longitude)';
