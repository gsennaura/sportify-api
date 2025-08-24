-- ===========================================================
-- Base identity
-- ===========================================================
CREATE TABLE IF NOT EXISTS people (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,                  -- Person's first name
    last_name VARCHAR(100) NOT NULL,                  -- Person's last name
    document VARCHAR(20) UNIQUE NOT NULL,             -- Identification document (e.g., CPF)
    birth_date DATE,
    gender VARCHAR(10) CHECK (gender IN ('male','female','other')),
    nationality_id INTEGER REFERENCES countries(id) ON DELETE SET NULL,
    birth_city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL,
    photo_url VARCHAR(255),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE people IS 'Registry of all individuals (athletes, referees, staff, etc.).';
COMMENT ON COLUMN people.document IS 'Main identification document (CPF for Brazil, Passport elsewhere).';

CREATE TRIGGER trg_people_updated_at
BEFORE UPDATE ON people
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ===========================================================
-- Sub-entities (1–1 with people)
-- ===========================================================

-- Athletes
CREATE TABLE IF NOT EXISTS athletes (
    person_id INTEGER PRIMARY KEY REFERENCES people(id) ON DELETE CASCADE,
    athlete_number VARCHAR(40) UNIQUE,           -- Athlete registry/card number
    primary_sport_id INTEGER REFERENCES sports(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active','free_agent','suspended','retired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE athletes IS 'Athlete profile extending a person (independent from club assignments).';

CREATE TRIGGER trg_athletes_updated_at
BEFORE UPDATE ON athletes
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Referees
CREATE TABLE IF NOT EXISTS referees (
    person_id INTEGER PRIMARY KEY REFERENCES people(id) ON DELETE CASCADE,
    referee_registry_number VARCHAR(40) UNIQUE,
    grade VARCHAR(30),
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active','available','suspended','retired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE referees IS 'Referee profile extending a person (independent from federation assignments).';

CREATE TRIGGER trg_referees_updated_at
BEFORE UPDATE ON referees
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Staff
CREATE TABLE IF NOT EXISTS staff (
    person_id INTEGER PRIMARY KEY REFERENCES people(id) ON DELETE CASCADE,
    staff_registry_number VARCHAR(40) UNIQUE,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active','available','suspended','retired')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
COMMENT ON TABLE staff IS 'Staff profile extending a person (independent from club assignments).';

CREATE TRIGGER trg_staff_updated_at
BEFORE UPDATE ON staff
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ===========================================================
-- Lookup tables (roles/positions)
-- ===========================================================

-- Staff roles
CREATE TABLE IF NOT EXISTS staff_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(30)
        CHECK (category IN ('technical','medical','management','administrative')),
    UNIQUE(name)
);

-- Referee roles
CREATE TABLE IF NOT EXISTS referee_roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    UNIQUE(name)
);

-- Athlete positions
CREATE TABLE IF NOT EXISTS athlete_positions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    UNIQUE(name)
);

-- ===========================================================
-- Capability tags (many-to-many, independent of assignments)
-- ===========================================================

CREATE TABLE IF NOT EXISTS athlete_position_tags (
    athlete_id INTEGER NOT NULL REFERENCES athletes(person_id) ON DELETE CASCADE,
    position_id INTEGER NOT NULL REFERENCES athlete_positions(id) ON DELETE CASCADE,
    PRIMARY KEY (athlete_id, position_id)
);

CREATE TABLE IF NOT EXISTS staff_role_tags (
    staff_id INTEGER NOT NULL REFERENCES staff(person_id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES staff_roles(id) ON DELETE CASCADE,
    PRIMARY KEY (staff_id, role_id)
);

CREATE TABLE IF NOT EXISTS referee_role_tags (
    referee_id INTEGER NOT NULL REFERENCES referees(person_id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES referee_roles(id) ON DELETE CASCADE,
    PRIMARY KEY (referee_id, role_id)
);