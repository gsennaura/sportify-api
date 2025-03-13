CREATE TABLE IF NOT EXISTS people (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    birth_date DATE NOT NULL,
    city_id INT REFERENCES cities(id) ON DELETE SET NULL,  -- Evita remoção acidental de cidades
    height DECIMAL(4,2) CHECK (height > 0),  -- Garante que valores negativos não sejam inseridos
    weight DECIMAL(5,2) CHECK (weight > 0),
    official_website VARCHAR(255)
);

-- Exemplos:
-- Pessoas:
-- "Lionel Messi", Nascido em: 24/06/1987, Cidade: Rosario (Argentina), Altura: 1.70m, Peso: 72kg
-- "Neymar Jr", Nascido em: 05/02/1992, Cidade: Mogi das Cruzes (Brasil), Altura: 1.75m, Peso: 68kg

CREATE TABLE IF NOT EXISTS person_social_links (
    id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    platform VARCHAR(50) NOT NULL,  -- Exemplo: "Instagram", "Twitter", "Facebook"
    url VARCHAR(255) NOT NULL
);

-- Exemplos:
-- "Lionel Messi" -> Instagram: "https://instagram.com/messi"
-- "Neymar Jr" -> Twitter: "https://twitter.com/neymarjr"

CREATE TABLE IF NOT EXISTS characteristic_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS characteristics (
    id SERIAL PRIMARY KEY,
    type_id INT NOT NULL REFERENCES characteristic_types(id) ON DELETE CASCADE,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS person_characteristic (
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    characteristic_id INT NOT NULL REFERENCES characteristics(id) ON DELETE CASCADE,
    PRIMARY KEY (person_id, characteristic_id)
);

-- Exemplos:
-- Tipos: "Físico", "Técnico", "Psicológico"
-- Características: "Velocidade", "Força", "Precisão", "Resistência"

CREATE TABLE IF NOT EXISTS person_country (
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    country_id INT NOT NULL REFERENCES countries(id) ON DELETE SET NULL,  -- Evita remoção acidental de países
    PRIMARY KEY (person_id, country_id)
);

-- Exemplos:
-- "Lionel Messi" -> País: Argentina (AR)
-- "Neymar Jr" -> País: Brasil (BR)