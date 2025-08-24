/*
Categories for SportifyAPI
- Defines different age groups and competition levels
- Used to organize teams and leagues
*/

-- Categories table - age groups and competition levels
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    short_name VARCHAR(20),
    description VARCHAR(255),
    age_min INTEGER,
    age_max INTEGER,
    gender VARCHAR(20) NOT NULL DEFAULT 'male',
    is_professional BOOLEAN DEFAULT false,
    active BOOLEAN DEFAULT true,
    UNIQUE(name)
);

-- Insert common categories
INSERT INTO categories (name, short_name, age_min, age_max, is_professional, description)
VALUES 
    ('Profissional', 'PRO', 17, NULL, true, 'Nível principal profissional'),
    ('Sub-20', 'U20', 17, 20, false, 'Categoria de base sub-20'),
    ('Sub-17', 'U17', 15, 17, false, 'Categoria de base sub-17'),
    ('Sub-15', 'U15', 13, 15, false, 'Categoria de base sub-15'),
    ('Sub-13', 'U13', 11, 13, false, 'Categoria de base sub-13'),
    ('Sub-11', 'U11', 9, 11, false, 'Categoria de base sub-11'),
    ('Amador', 'AM', NULL, NULL, false, 'Competição em nível amador'),
    ('Masters', 'MST', 35, NULL, false, 'Categoria masters/veteranos')
ON CONFLICT (name) DO NOTHING;

-- Add comments for documentation
COMMENT ON TABLE categories IS 'Categories represent different age groups or competition levels';
COMMENT ON COLUMN categories.age_min IS 'Minimum age for players in this category';
COMMENT ON COLUMN categories.age_max IS 'Maximum age for players in this category';
COMMENT ON COLUMN categories.is_professional IS 'Whether this is a professional-level category';
COMMENT ON COLUMN categories.gender IS 'Gender for this category: male, female, both, etc.';
