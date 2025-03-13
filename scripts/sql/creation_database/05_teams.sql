CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE  -- Exemplo: "Sub-15", "Sub-17", "Profissional", "Amador"
);

CREATE TABLE IF NOT EXISTS teams (
    id SERIAL PRIMARY KEY,
    entity_id INT NOT NULL REFERENCES entities(id) ON DELETE CASCADE,  -- Clube ou entidade dona do time
    name VARCHAR(100) NOT NULL,  -- Nome do time (ex: "Cruzeiro Sub-17 Azul")
    category_id INT NOT NULL REFERENCES categories(id) ON DELETE CASCADE, -- Categoria (Sub-15, Profissional, etc.)
    sport_id INT NOT NULL REFERENCES sports(id) ON DELETE CASCADE,  -- Modalidade esportiva do time
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_team_name UNIQUE (entity_id, name, sport_id)
);

-- Exemplos:
-- "Flamengo Sub-20" (Categoria: Sub-20, Esporte: Futebol)
-- "Pinheiros Natação Elite" (Categoria: Profissional, Esporte: Natação)
-- "Minas Tênis Clube Basquete" (Categoria: Profissional, Esporte: Basquete)

CREATE TABLE IF NOT EXISTS team_players (
    id SERIAL PRIMARY KEY,
    team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE, -- Time ao qual pertence
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE, -- Pessoa vinculada ao time
    role_id INT REFERENCES roles(id) ON DELETE SET NULL, -- Função no time (se for deletada, mantém o vínculo)
    shirt_number INT CHECK (shirt_number > 0 AND shirt_number <= 99), -- Número da camisa (opcional)
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'inactive', 'loaned', 'injured', 'suspended', 'staff', 'released')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exemplos:
-- "Pedro" -> "Flamengo Profissional" (Atleta, Camisa 9, Status: Ativo)
-- "Tite" -> "Seleção Brasileira" (Treinador, Sem camisa, Status: Staff)
-- "Neymar" -> "Santos FC" (Atleta, Camisa 11, Status: Released - Ex-jogador)
