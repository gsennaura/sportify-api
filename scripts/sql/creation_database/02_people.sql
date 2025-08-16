/*
People and roles tables for SportifyAPI
- Core people table for all individuals
- Role definitions for different positions (player, coach, president, etc.)
- Person-role relationships
*/

-- People table - core information for all individuals
CREATE TABLE people (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
    nationality_id INTEGER REFERENCES countries(id) ON DELETE SET NULL,
    birth_city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL,
    photo_url VARCHAR(255),
    active BOOLEAN DEFAULT true
);

-- Create indexes for common queries
CREATE INDEX idx_people_name ON people(last_name, first_name);
CREATE INDEX idx_people_birth_date ON people(birth_date);

-- Player-specific attributes
CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    height DECIMAL(5,2), -- in cm
    weight DECIMAL(5,2), -- in kg
    dominant_foot VARCHAR(10) CHECK (dominant_foot IN ('left', 'right', 'both')),
    position VARCHAR(50),
    active BOOLEAN DEFAULT true,
    UNIQUE(person_id)
);

-- Role types (used for both team and federation staff)
CREATE TABLE role_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    category VARCHAR(20) NOT NULL CHECK (category IN ('player', 'technical', 'medical', 'management', 'administrative')),
    active BOOLEAN DEFAULT true,
    UNIQUE(name)
);

-- Insert common role types
INSERT INTO role_types (name, description, category) VALUES
    ('Player', 'Active player on the field', 'player'),
    ('Head Coach', 'Main team coach', 'technical'),
    ('Assistant Coach', 'Assistant to the head coach', 'technical'),
    ('Physical Trainer', 'Responsible for physical conditioning', 'technical'),
    ('Team Doctor', 'Medical professional for the team', 'medical'),
    ('Physiotherapist', 'Handles injuries and recovery', 'medical'),
    ('President', 'Organization president', 'management'),
    ('Vice President', 'Second in command', 'management'),
    ('Director', 'Department director', 'management'),
    ('Technical Director', 'Oversees technical aspects', 'management'),
    ('Team Manager', 'Day-to-day team management', 'administrative'),
    ('Secretary', 'Administrative support', 'administrative');

-- Contact information for people
CREATE TABLE contact_info (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('email', 'phone', 'address', 'social')),
    value TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    active BOOLEAN DEFAULT true
);

-- Add comments for documentation
COMMENT ON TABLE players IS 'Extended attributes specific to athletes';
COMMENT ON TABLE role_types IS 'Different roles people can have in teams or federations';
COMMENT ON TABLE contact_info IS 'Contact information for people';