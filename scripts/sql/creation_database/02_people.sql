/*
People and roles tables for SportifyAPI
- Core people table for all individuals
- Role definitions for different positions (player, coach, president, etc.)
- Person-role relationships
*/

-- People table - core information for all individuals
CREATE TABLE IF NOT EXISTS people (
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

-- Player positions table
CREATE TABLE IF NOT EXISTS player_positions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- Insert default soccer positions (in Portuguese)
INSERT INTO player_positions (name, description) VALUES
    ('Goleiro', 'Responsável por defender o gol'),
    ('Lateral Direito', 'Defensor pelo lado direito'),
    ('Zagueiro', 'Defensor central'),
    ('Lateral Esquerdo', 'Defensor pelo lado esquerdo'),
    ('Volante', 'Meio-campista defensivo'),
    ('Meio-campista', 'Jogador central do meio-campo'),
    ('Meia Ofensivo', 'Meio-campista ofensivo'),
    ('Ponta Direita', 'Atacante pelo lado direito'),
    ('Atacante', 'Jogador de ataque'),
    ('Ponta Esquerda', 'Atacante pelo lado esquerdo'),
    ('Centroavante', 'Atacante central')
ON CONFLICT (name) DO NOTHING;

-- Player-specific attributes
CREATE TABLE IF NOT EXISTS players (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    height DECIMAL(5,2), -- in cm
    weight DECIMAL(5,2), -- in kg
    dominant_foot VARCHAR(10) CHECK (dominant_foot IN ('left', 'right', 'both')),
    position_id INTEGER REFERENCES player_positions(id) ON DELETE SET NULL,
    active BOOLEAN DEFAULT true,
    UNIQUE(person_id)
);

-- Role types (used for both team and federation staff)
CREATE TABLE IF NOT EXISTS role_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    category VARCHAR(20) NOT NULL CHECK (category IN ('player', 'technical', 'medical', 'management', 'administrative')),
    active BOOLEAN DEFAULT true,
    UNIQUE(name)
);

-- Insert common role types
INSERT INTO role_types (name, description, category) VALUES
    ('Técnico Principal', 'Treinador principal da equipe', 'technical'),
    ('Auxiliar Técnico', 'Assistente do técnico principal', 'technical'),
    ('Preparador Físico', 'Responsável pelo condicionamento físico', 'technical'),
    ('Goleiro Técnico', 'Treinador especializado em goleiros', 'technical'),
    ('Médico', 'Responsável pela saúde dos atletas', 'medical'),
    ('Fisioterapeuta', 'Tratamento e reabilitação', 'medical'),
    ('Nutricionista', 'Orientação nutricional', 'medical'),
    ('Presidente', 'Presidente do clube', 'management'),
    ('Vice-Presidente', 'Vice-presidente do clube', 'management'),
    ('Diretor Esportivo', 'Responsável pelo departamento esportivo', 'management'),
    ('Gerente de Futebol', 'Gestor das operações futebolísticas', 'management'),
    ('Secretário', 'Responsável por questões administrativas', 'administrative')
ON CONFLICT (name) DO NOTHING;

-- Staff-specific attributes (extends people) - NOW AFTER role_types is created
CREATE TABLE IF NOT EXISTS staff (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    main_role_id INTEGER REFERENCES role_types(id) ON DELETE SET NULL, -- Main function/role of the staff
    document_number VARCHAR(30), -- Optional: staff-specific document/registration
    notes TEXT, -- Optional: extra info about the staff
    active BOOLEAN DEFAULT true,
    UNIQUE(person_id)
);

-- Contact information for people
CREATE TABLE IF NOT EXISTS contact_info (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('email', 'phone', 'address', 'social')),
    value TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    active BOOLEAN DEFAULT true
);

-- Add comments for documentation
COMMENT ON TABLE people IS 'Core table for all individuals in the system';
COMMENT ON TABLE players IS 'Extended attributes specific to athletes';
COMMENT ON TABLE staff IS 'Staff members (coaches, directors, etc), extends people';
COMMENT ON TABLE role_types IS 'Different roles people can have in teams or federations';
COMMENT ON TABLE contact_info IS 'Contact information for people';
COMMENT ON TABLE player_positions IS 'Possible positions/functions for players (e.g., Atacante, Meio-campista, Zagueiro, etc)';