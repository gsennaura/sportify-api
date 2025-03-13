CREATE TABLE federations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    level VARCHAR(50) NOT NULL CHECK (level IN ('municipal', 'regional', 'state', 'national', 'continental', 'world')),
    parent_federation_id INT REFERENCES federations(id) ON DELETE SET NULL,
    founded_date DATE,
    country_id INT REFERENCES countries(id) ON DELETE SET NULL
);

-- Exemplos:
-- "CBF" (Confederação Brasileira de Futebol) - Nível Nacional - Brasil
-- "FIFA" (Federação Internacional de Futebol) - Nível Mundial
-- "UEFA" (União das Federações Europeias de Futebol) - Nível Continental - Europa

CREATE TABLE entity_federation (
    entity_id INT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    federation_id INT NOT NULL REFERENCES federations(id) ON DELETE CASCADE,
    PRIMARY KEY (entity_id, federation_id)
);

-- Exemplos:
-- "Flamengo" -> Membro da "CBF"
-- "Barcelona" -> Membro da "La Liga" (que está vinculada à RFEF e UEFA)

CREATE TABLE federation_sport (
    federation_id INT NOT NULL REFERENCES federations(id) ON DELETE CASCADE,
    sport_id INT NOT NULL REFERENCES sports(id) ON DELETE CASCADE,
    PRIMARY KEY (federation_id, sport_id)
);

-- Exemplos:
-- "CBF" -> Gerencia "Futebol"
-- "FIVB" (Federação Internacional de Vôlei) -> Gerencia "Vôlei"

CREATE TABLE sports (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- Exemplos:
-- "Futebol", "Basquete", "Tênis", "Natação", "Atletismo"

CREATE TABLE person_federation (
    id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    federation_id INT NOT NULL REFERENCES federations(id) ON DELETE CASCADE,
    role_id INT REFERENCES roles(id) ON DELETE SET NULL,  -- Se um cargo for removido, o vínculo da pessoa continua existindo
    start_date DATE NOT NULL,
    end_date DATE,
    department VARCHAR(100), 
    responsibilities TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE, -- Indica se este é o vínculo mais recente da pessoa com a federação
    CONSTRAINT unique_person_federation UNIQUE (person_id, federation_id, role_id, start_date)
);

-- Exemplos:
-- "Ednaldo Rodrigues" -> Presidente da "CBF" desde 2022
-- "Gianni Infantino" -> Presidente da "FIFA" desde 2016
