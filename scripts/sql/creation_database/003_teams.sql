-- ===========================================================
-- Clubs: a club must belong to a federation
-- ===========================================================
CREATE TABLE IF NOT EXISTS clubs (
    id SERIAL PRIMARY KEY,
    name CITEXT NOT NULL,                                -- Club official name
    short_name CITEXT,                                   -- Optional shorter display name
    acronym CITEXT,                                      -- Optional acronym/sigla
    federation_id INTEGER NOT NULL                       -- Owning/affiliated federation
        REFERENCES federations(id) ON DELETE CASCADE,
    city_id INTEGER REFERENCES cities(id) ON DELETE SET NULL, -- Headquarters city
    foundation_date DATE,
    crest_url TEXT,                                      -- Badge/crest image
    website TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT clubs_website_format_chk CHECK (website IS NULL OR website ~* '^(https?://)'),
    CONSTRAINT clubs_crest_format_chk   CHECK (crest_url IS NULL OR crest_url ~* '^(https?://)'),

    -- Avoid duplicates inside the same federation
    CONSTRAINT clubs_unique_name_per_fed UNIQUE (federation_id, name),
    CONSTRAINT clubs_unique_acronym_per_fed UNIQUE (federation_id, acronym)
);
COMMENT ON TABLE clubs IS 'Sports clubs registered under a federation.';
COMMENT ON COLUMN clubs.federation_id IS 'Federation the club belongs to (mandatory).';

CREATE INDEX IF NOT EXISTS idx_clubs_federation_id ON clubs(federation_id);
CREATE INDEX IF NOT EXISTS idx_clubs_city_id ON clubs(city_id);

CREATE TRIGGER trg_clubs_updated_at
BEFORE UPDATE ON clubs
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ===========================================================
-- Club ↔ Athlete assignments
-- ===========================================================
-- Allows history via start_date/end_date and carries a status flag.
-- If you only need “current membership”, keep one row with NULL end_date.
CREATE TABLE IF NOT EXISTS club_athlete_assignments (
    club_id INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    athlete_id INTEGER NOT NULL REFERENCES athletes(person_id) ON DELETE CASCADE,
    position_id INTEGER REFERENCES athlete_positions(id) ON DELETE SET NULL, -- optional default position within the club
    shirt_number INTEGER,
    status VARCHAR(20) NOT NULL DEFAULT 'active'   -- active | inactive | loaned | suspended
        CHECK (status IN ('active','inactive','loaned','suspended')),
    start_date DATE,
    end_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (club_id, athlete_id, start_date),

    -- Sanity: end_date cannot be before start_date
    CONSTRAINT club_athlete_dates_chk CHECK (
        end_date IS NULL OR start_date IS NULL OR end_date >= start_date
    )
);
COMMENT ON TABLE club_athlete_assignments IS 'Athlete memberships in a club (historical, with status).';
COMMENT ON COLUMN club_athlete_assignments.status IS 'Membership status: active, inactive, loaned, or suspended.';
CREATE INDEX IF NOT EXISTS idx_caa_athlete ON club_athlete_assignments(athlete_id);
CREATE INDEX IF NOT EXISTS idx_caa_club ON club_athlete_assignments(club_id);
CREATE INDEX IF NOT EXISTS idx_caa_current ON club_athlete_assignments(club_id, athlete_id) WHERE end_date IS NULL;

CREATE TRIGGER trg_caa_updated_at
BEFORE UPDATE ON club_athlete_assignments
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ===========================================================
-- Club ↔ Staff assignments
-- ===========================================================
-- Staff member can have a concrete role in the club (role_id optional if you just want the link).
CREATE TABLE IF NOT EXISTS club_staff_assignments (
    club_id INTEGER NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    staff_id INTEGER NOT NULL REFERENCES staff(person_id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES staff_roles(id) ON DELETE SET NULL, -- specific role at the club
    status VARCHAR(20) NOT NULL DEFAULT 'active'   -- active | inactive | suspended
        CHECK (status IN ('active','inactive','suspended')),
    start_date DATE,
    end_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (club_id, staff_id, start_date),

    CONSTRAINT club_staff_dates_chk CHECK (
        end_date IS NULL OR start_date IS NULL OR end_date >= start_date
    )
);
COMMENT ON TABLE club_staff_assignments IS 'Staff memberships and specific roles within a club (historical).';
COMMENT ON COLUMN club_staff_assignments.role_id IS 'Optional concrete role inside the club (from staff_roles).';
CREATE INDEX IF NOT EXISTS idx_csa_staff ON club_staff_assignments(staff_id);
CREATE INDEX IF NOT EXISTS idx_csa_club ON club_staff_assignments(club_id);
CREATE INDEX IF NOT EXISTS idx_csa_current ON club_staff_assignments(club_id, staff_id) WHERE end_date IS NULL;

CREATE TRIGGER trg_csa_updated_at
BEFORE UPDATE ON club_staff_assignments
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ===========================================================
-- Federation ↔ Staff assignments
-- ===========================================================
-- For staff working at/for the federation itself (independent of clubs).
CREATE TABLE IF NOT EXISTS federation_staff_assignments (
    federation_id INTEGER NOT NULL REFERENCES federations(id) ON DELETE CASCADE,
    staff_id INTEGER NOT NULL REFERENCES staff(person_id) ON DELETE CASCADE,
    role_id INTEGER REFERENCES staff_roles(id) ON DELETE SET NULL, -- e.g., Director, Secretary, etc.
    status VARCHAR(20) NOT NULL DEFAULT 'active'   -- active | inactive | suspended
        CHECK (status IN ('active','inactive','suspended')),
    start_date DATE,
    end_date DATE,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    PRIMARY KEY (federation_id, staff_id, start_date),

    CONSTRAINT fed_staff_dates_chk CHECK (
        end_date IS NULL OR start_date IS NULL OR end_date >= start_date
    )
);
COMMENT ON TABLE federation_staff_assignments IS 'Staff roles and memberships within a federation (historical).';
CREATE INDEX IF NOT EXISTS idx_fsa_fed ON federation_staff_assignments(federation_id);
CREATE INDEX IF NOT EXISTS idx_fsa_staff ON federation_staff_assignments(staff_id);
CREATE INDEX IF NOT EXISTS idx_fsa_current ON federation_staff_assignments(federation_id, staff_id) WHERE end_date IS NULL;

CREATE TRIGGER trg_fsa_updated_at
BEFORE UPDATE ON federation_staff_assignments
FOR EACH ROW EXECUTE FUNCTION set_updated_at();