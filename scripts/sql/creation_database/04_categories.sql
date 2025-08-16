/*
Categories for SportifyAPI
- Defines different age groups and competition levels
- Used to organize teams and leagues
*/

-- Categories table - age groups and competition levels
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    short_name VARCHAR(20),
    description VARCHAR(255),
    age_min INTEGER,
    age_max INTEGER,
    is_professional BOOLEAN DEFAULT false,
    active BOOLEAN DEFAULT true,
    UNIQUE(name)
);

-- Insert common categories
INSERT INTO categories (name, short_name, age_min, age_max, is_professional, description)
VALUES 
    ('Professional', 'PRO', 17, NULL, true, 'Main professional level'),
    ('Under 20', 'U20', 17, 20, false, 'Under 20 youth category'),
    ('Under 17', 'U17', 15, 17, false, 'Under 17 youth category'),
    ('Under 15', 'U15', 13, 15, false, 'Under 15 youth category'),
    ('Under 13', 'U13', 11, 13, false, 'Under 13 youth category'),
    ('Under 11', 'U11', 9, 11, false, 'Under 11 youth category'),
    ('Amateur', 'AM', NULL, NULL, false, 'Amateur level competition'),
    ('Masters', 'MST', 35, NULL, false, 'Masters/veterans category');

-- Add comments for documentation
COMMENT ON TABLE categories IS 'Categories represent different age groups or competition levels';
COMMENT ON COLUMN categories.age_min IS 'Minimum age for players in this category';
COMMENT ON COLUMN categories.age_max IS 'Maximum age for players in this category';
COMMENT ON COLUMN categories.is_professional IS 'Whether this is a professional-level category';
