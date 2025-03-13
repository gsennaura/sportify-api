CREATE TABLE countries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    iso_code CHAR(2) UNIQUE NOT NULL
);

CREATE TABLE states (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    abbreviation CHAR(2) UNIQUE NOT NULL,
    country_id INT NOT NULL REFERENCES countries(id) ON DELETE CASCADE
);

CREATE TABLE cities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    state_id INT REFERENCES states(id) ON DELETE SET NULL  -- Evita exclusões acidentais de cidades
);

-- Exemplos:
-- Países: Brasil (BR), Argentina (AR), Estados Unidos (US)
-- Estados: São Paulo (SP) - Brasil, Buenos Aires (BA) - Argentina
-- Cidades: São Paulo (SP), Buenos Aires (BA), Rio de Janeiro (RJ)

CREATE TABLE locations (
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

CREATE TABLE people (
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

CREATE TABLE person_social_links (
    id SERIAL PRIMARY KEY,
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    platform VARCHAR(50) NOT NULL,  -- Exemplo: "Instagram", "Twitter", "Facebook"
    url VARCHAR(255) NOT NULL
);

-- Exemplos:
-- "Lionel Messi" -> Instagram: "https://instagram.com/messi"
-- "Neymar Jr" -> Twitter: "https://twitter.com/neymarjr"

CREATE TABLE characteristic_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE characteristics (
    id SERIAL PRIMARY KEY,
    type_id INT NOT NULL REFERENCES characteristic_types(id) ON DELETE CASCADE,
    name VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE person_characteristic (
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    characteristic_id INT NOT NULL REFERENCES characteristics(id) ON DELETE CASCADE,
    PRIMARY KEY (person_id, characteristic_id)
);

-- Exemplos:
-- Tipos: "Físico", "Técnico", "Psicológico"
-- Características: "Velocidade", "Força", "Precisão", "Resistência"

CREATE TABLE person_country (
    person_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    country_id INT NOT NULL REFERENCES countries(id) ON DELETE SET NULL,  -- Evita remoção acidental de países
    PRIMARY KEY (person_id, country_id)
);

-- Exemplos:
-- "Lionel Messi" -> País: Argentina (AR)
-- "Neymar Jr" -> País: Brasil (BR)

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

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE  -- Exemplo: "Sub-15", "Sub-17", "Profissional", "Amador"
);

CREATE TABLE teams (
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

CREATE TABLE team_players (
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

CREATE TABLE leagues (
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

CREATE TABLE league_editions (
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

CREATE TABLE league_committee (
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

CREATE TABLE league_edition_teams (
    id SERIAL PRIMARY KEY,
    league_edition_id INT NOT NULL REFERENCES league_editions(id) ON DELETE CASCADE,
    team_id INT NOT NULL REFERENCES teams(id) ON DELETE CASCADE, -- Agora vinculamos o time, não apenas a entidade
    max_registered_players INT NOT NULL DEFAULT 30, -- Limite de jogadores permitidos para essa edição
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exemplos:
-- "Flamengo" registrado na "Libertadores 2024" - Máximo: 30 jogadores
-- "Barcelona" registrado na "La Liga 2023/24" - Máximo: 25 jogadores

CREATE TABLE league_edition_standings (
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

CREATE TABLE league_edition_group_participants (
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

CREATE TABLE league_edition_groupings (
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

CREATE TABLE matches (
    id SERIAL PRIMARY KEY,
    league_edition_grouping_id INT NOT NULL REFERENCES league_edition_groupings(id) ON DELETE CASCADE,
    match_number INT DEFAULT NULL, -- Ex: Rodada 1, Quartas de Final (Pode ser NULL para eliminatórias diretas)
    date TIMESTAMP NOT NULL,
    location_id INT NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
    leg INT DEFAULT 1 CHECK (leg >= 1), -- Permite diferenciar ida e volta (1 = Ida, 2 = Volta, etc.)
    status VARCHAR(20) NOT NULL CHECK (status IN ('scheduled', 'ongoing', 'completed', 'cancelled'))
);

-- Exemplos:
-- "Flamengo x Palmeiras" - Rodada 5, Maracanã, 10/05/2024, Status: Completed
-- "Brasil x Argentina" - Final, Copa América, 15/07/2024, Status: Scheduled

CREATE TABLE match_participants (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id INT REFERENCES teams(id) ON DELETE CASCADE, -- Preenchido se for esporte coletivo
    player_id INT REFERENCES people(id) ON DELETE CASCADE, -- Preenchido se for esporte individual
    position INT DEFAULT NULL CHECK (
        (position IS NULL) OR (player_id IS NOT NULL AND team_id IS NULL)
    ), -- Garante que apenas esportes individuais usam posição
    score DECIMAL(10,2) DEFAULT NULL, -- Pode armazenar gols, tempo, pontos, etc.
    score_type VARCHAR(20) NOT NULL CHECK (score_type IN ('none', 'goals', 'points', 'time', 'sets', 'distance')), -- Agora aceita 'none'
    is_winner BOOLEAN DEFAULT FALSE -- Define se esse competidor venceu a partida
);

-- Exemplos:
-- "Flamengo x Palmeiras" -> Score: 2x1, Score Type: Goals
-- "Usain Bolt 100m Rasos" -> Tempo: 9.58s, Score Type: Time, Posição: 1º Lugar

CREATE TABLE match_results (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    winner_team_id INT REFERENCES teams(id) ON DELETE CASCADE,
    winner_player_id INT REFERENCES people(id) ON DELETE CASCADE,
    is_draw BOOLEAN DEFAULT FALSE, -- Indica empate em esportes coletivos
    details JSONB -- Pode armazenar estatísticas adicionais (sets vencidos, tempo total, etc.)
);

-- Exemplos:
-- "Flamengo 2x2 Palmeiras" -> Empate
-- "Brasil x Argentina" -> Vitória do Brasil, Placar: 1x0

CREATE TABLE match_reports (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    report TEXT NOT NULL, -- Texto detalhado da súmula
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exemplos:
-- "Relatório de Flamengo x Palmeiras: 2 expulsões, 1 pênalti convertido..."
-- "Relatório de Brasil x Argentina: Jogo pegado, gol no último minuto..."

CREATE TABLE match_events (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    player_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    team_id INT REFERENCES teams(id) ON DELETE CASCADE,
    event_type VARCHAR(20) NOT NULL CHECK (event_type IN ('goal', 'assist', 'yellow_card', 'red_card', 'substitution', 'foul')),
    event_time INT NOT NULL, -- Minuto do evento
    extra_info TEXT
);

-- Exemplos:
-- "Gabigol" - Flamengo - Gol aos 72 minutos
-- "Casemiro" - Brasil - Cartão Amarelo aos 45 minutos

CREATE TABLE match_player_statistics (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    player_id INT NOT NULL REFERENCES people(id) ON DELETE CASCADE,
    team_id INT REFERENCES teams(id) ON DELETE CASCADE,
    minutes_played INT NOT NULL DEFAULT 0,
    goals INT NOT NULL DEFAULT 0,
    assists INT NOT NULL DEFAULT 0,
    shots INT NOT NULL DEFAULT 0,
    passes INT NOT NULL DEFAULT 0,
    fouls_committed INT NOT NULL DEFAULT 0,
    yellow_cards INT NOT NULL DEFAULT 0,
    red_cards INT NOT NULL DEFAULT 0
);

-- Exemplos:
-- "Lionel Messi" - Jogo contra Real Madrid - 90 min, 2 gols, 1 assistência
-- "Cristiano Ronaldo" - Jogo contra Bayern - 88 min, 3 chutes, 1 gol

CREATE TABLE match_scores (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    team_id INT REFERENCES teams(id) ON DELETE CASCADE,
    player_id INT REFERENCES people(id) ON DELETE CASCADE,
    period INT NOT NULL, -- Tempo do jogo, set, round, etc.
    score INT NOT NULL
);

-- Exemplos:
-- Flamengo 1º Tempo: 1 gol
-- Palmeiras 1º Tempo: 0 gols
-- Flamengo 2º Tempo: 1 gol
-- Palmeiras 2º Tempo: 1 gol
-- Resultado final: 2x1