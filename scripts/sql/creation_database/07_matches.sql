CREATE TABLE IF NOT EXISTS matches (
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

CREATE TABLE IF NOT EXISTS match_participants (
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

CREATE TABLE IF NOT EXISTS match_results (
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

CREATE TABLE IF NOT EXISTS match_reports (
    id SERIAL PRIMARY KEY,
    match_id INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    report TEXT NOT NULL, -- Texto detalhado da súmula
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Exemplos:
-- "Relatório de Flamengo x Palmeiras: 2 expulsões, 1 pênalti convertido..."
-- "Relatório de Brasil x Argentina: Jogo pegado, gol no último minuto..."

CREATE TABLE IF NOT EXISTS match_events (
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

CREATE TABLE IF NOT EXISTS match_player_statistics (
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

CREATE TABLE IF NOT EXISTS match_scores (
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