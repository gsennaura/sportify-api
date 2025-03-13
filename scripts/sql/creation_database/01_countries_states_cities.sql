CREATE TABLE IF NOT EXISTS countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    iso_code CHAR(2) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS states (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    abbreviation CHAR(2) UNIQUE NOT NULL,
    country_id INT NOT NULL REFERENCES countries(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    state_id INT REFERENCES states(id) ON DELETE SET NULL  -- Evita exclusões acidentais de cidades
);

-- Exemplos:
-- Países: Brasil (BR), Argentina (AR), Estados Unidos (US)
-- Estados: São Paulo (SP) - Brasil, Buenos Aires (BA) - Argentina
-- Cidades: São Paulo (SP), Buenos Aires (BA), Rio de Janeiro (RJ)

CREATE TABLE IF NOT EXISTS locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,  -- Nome do estádio, ginásio, arena, etc.
    city_id INT REFERENCES cities(id) ON DELETE SET NULL,  -- Evita exclusões acidentais
    address TEXT,  -- Endereço detalhado (opcional)
    latitude DECIMAL(10,8),  -- Melhor precisão geográfica
    longitude DECIMAL(10,8)
);

-- Exemplos:
-- Locais de partidas:
-- "Estádio Maracanã", Cidade: Rio de Janeiro, Brasil
-- "La Bombonera", Cidade: Buenos Aires, Argentina
-- "Camp Nou", Cidade: Barcelona, Espanha
