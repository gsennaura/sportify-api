CREATE TABLE IF NOT EXISTS leagues (
    id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    federation_id INT REFERENCES federations(id) ON DELETE SET NULL, -- Federação ou entidade organizadora
    founded_date DATE,
    official_website VARCHAR(255),
    description TEXT
);

-- Exemplos:
-- "Premier League" - Organizada pela FA (Federação Inglesa)
-- "La Liga" - Organizada pela RFEF (Federação Espanhola)
-- "Brasileirão" - Organizado pela CBF

CREATE TABLE IF NOT EXISTS league_editions (
    id SERIAL PRIMARY KEY,
    league_id INT NOT NULL REFERENCES leagues(id) ON DELETE CASCADE,
    sport_id INT NOT NULL REFERENCES sports(id) ON DELETE CASCADE,  -- Modalidade esportiva
    category_id INT NOT NULL REFERENCES categories(id) ON DELETE CASCADE, -- Categoria (Profissional, Sub-20, etc.)
    season VARCHAR(20) NOT NULL,  -- Exemplo: "2024", "2023/24"
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female', 'mixed')), -- Nova coluna para diferenciar competições masculinas, femininas e mistas
    format VARCHAR(50) NOT NULL CHECK (format IN ('elimination', 'round_robin', 'mixed', 'group_stage')),
    competition_type VARCHAR(20) NOT NULL CHECK (competition_type IN ('team', 'individual')) DEFAULT 'team',
    status VARCHAR(20) NOT NULL CHECK (status IN ('planned', 'ongoing', 'completed', 'cancelled')),
    official_website VARCHAR(255)
);

-- Exemplos:
-- "Campeonato Brasileiro Série A 2024" - Profissional, Masculino, Futebol
-- "Libertadores Feminina 2024" - Profissional, Feminino, Futebol
-- "Olimpíadas 2024 - Atletismo" - Profissional, Misto, Atletismo

CREATE TABLE IF NOT EXISTS league_edition_groupings (
    id SERIAL PRIMARY KEY,
    league_edition_id INT NOT NULL REFERENCES league_editions(id) ON DELETE CASCADE,
    phase VARCHAR(50) NOT NULL CHECK (phase IN ('group_stage', 'knockout', 'final')),
    level INT NOT NULL CHECK (level > 0), -- Indica a ordem da fase na competição
    classification_rule JSONB NOT NULL -- Define quantos se classificam nessa fase
);

-- Exemplos:
-- "Fase de Grupos" -> Nível: 1, Classificam-se 2 por grupo
-- "Quartas de Final" -> Nível: 2, Eliminatória
-- "Final" -> Nível: 3, Apenas um jogo

CREATE TABLE IF NOT EXISTS league_committee (
    id SERIAL PRIMARY KEY,
    league_edition_id INT NOT NULL REFERENCES league_editions(id) ON DELETE CASCADE,
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    role VARCHAR(100) NOT NULL CHECK (role IN ('director', 'referee_manager', 'disciplinary_manager', 'marketing_manager', 'operations_manager')),
    start_date DATE NOT NULL,
    end_date DATE NULL -- Permite NULL para membros ainda ativos
);

-- Exemplos:
-- "Diretor do Brasileirão 2024" -> Nome: "João Silva", Cargo: "Director"
-- "Gestor de Arbitragem da Champions 2024" -> Nome: "Carlos Torres", Cargo: "Referee Manager"

CREATE TABLE IF NOT EXISTS league_edition_teams (
    id SERIAL PRIMARY KEY,
    league_edition_id INT NOT NULL REFERENCES league_editions(id) ON DELETE CASCADE,
    team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE, -- Agora vinculamos o time, não apenas a entidade
    max_registered_players INT NOT NULL DEFAULT 30, -- Limite de jogadores permitidos para essa edição
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exemplos:
-- "Flamengo" registrado na "Libertadores 2024" - Máximo: 30 jogadores
-- "Barcelona" registrado na "La Liga 2023/24" - Máximo: 25 jogadores

CREATE TABLE IF NOT EXISTS league_edition_standings (
    id SERIAL PRIMARY KEY,
    league_edition_id INT NOT NULL REFERENCES league_editions(id) ON DELETE CASCADE,
    team_id INT REFERENCES teams(id) ON DELETE CASCADE,
    person_id INT REFERENCES people(id) ON DELETE CASCADE, -- Para esportes individuais
    matches_played INT NOT NULL DEFAULT 0,
    wins INT NOT NULL DEFAULT 0,
    draws INT NOT NULL DEFAULT 0,
    losses INT NOT NULL DEFAULT 0,
    goals_for INT NOT NULL DEFAULT 0, 
    goals_against INT NOT NULL DEFAULT 0, 
    goal_difference INT NOT NULL DEFAULT 0,
    points INT NOT NULL DEFAULT 0,
    total_time DECIMAL(10,2) DEFAULT 0, -- Soma dos tempos em esportes individuais de tempo
    total_score DECIMAL(10,2) DEFAULT 0, -- Soma dos pontos em ginástica
    ranking INT DEFAULT NULL -- Ranking geral na edição
);

-- Exemplos:
-- "Flamengo - Brasileirão 2024" -> 38 jogos, 22 vitórias, 3 empates, 13 derrotas, 69 pontos
-- "Usain Bolt - 100m Olimpíadas 2024" -> 9.58 segundos, 1º lugar

CREATE TABLE IF NOT EXISTS league_edition_group_participants (
    id SERIAL PRIMARY KEY,
    league_edition_grouping_id INT NOT NULL REFERENCES league_edition_groupings(id) ON DELETE CASCADE,
    team_id INT REFERENCES teams(id) ON DELETE CASCADE,
    person_id INT REFERENCES people(id) ON DELETE CASCADE,
    matches_played INT NOT NULL DEFAULT 0,
    wins INT NOT NULL DEFAULT 0,
    draws INT NOT NULL DEFAULT 0,
    losses INT NOT NULL DEFAULT 0,
    goals_for INT NOT NULL DEFAULT 0, 
    goals_against INT NOT NULL DEFAULT 0, 
    goal_difference INT NOT NULL DEFAULT 0,
    points INT NOT NULL DEFAULT 0,
    total_time DECIMAL(10,2) DEFAULT 0, -- Soma dos tempos em esportes de tempo (natação, atletismo)
    total_score DECIMAL(10,2) DEFAULT 0, -- Soma de pontos em ginástica, por exemplo
    ranking INT DEFAULT NULL -- Ranking dentro do grupo/fase
);