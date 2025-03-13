CREATE TABLE uniform_brands (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE sponsors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE entity_brand (
    id SERIAL PRIMARY KEY,
    entity_id INT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    brand_id INT NOT NULL REFERENCES uniform_brands(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE
);

CREATE TABLE entity_sponsor (
    id SERIAL PRIMARY KEY,
    entity_id INT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    sponsor_id INT NOT NULL REFERENCES sponsors(id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE
);

CREATE TABLE entities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    nickname VARCHAR(100),
    foundation_date DATE,
    city_id INT REFERENCES cities(id) ON DELETE SET NULL,
    tax_id VARCHAR(18) UNIQUE,  -- Exemplo: CNPJ no Brasil
    address TEXT,
    president VARCHAR(150),
    official_website VARCHAR(255),
    email VARCHAR(150),
    historical_names TEXT
);

-- Exemplos:
-- "FC Barcelona", Fundado em 1899, Barcelona, Espanha
-- "Manchester United", Fundado em 1878, Manchester, Inglaterra

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE person_entity (
    id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    entity_id INT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    role_id INT REFERENCES roles(id) ON DELETE SET NULL,  -- Se um cargo for removido, não queremos excluir o vínculo
    start_date DATE NOT NULL,
    end_date DATE,
    salary DECIMAL(10,2),
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,  -- Indica se este é o vínculo mais recente da pessoa com essa entidade
    CONSTRAINT unique_person_entity UNIQUE (person_id, entity_id, role_id, start_date)
);

-- Exemplos:
-- "Pep Guardiola" -> "Manchester City" (Técnico) - Desde 2016
-- "Cristiano Ronaldo" -> "Real Madrid" (Atleta) - 2009 a 2018