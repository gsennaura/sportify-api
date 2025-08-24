# SportifyAPI Database Schema

Este banco de dados implementa um sistema abrangente de gestão esportiva focado no futebol com relacionamentos adequados entre jogadores, equipes, organizações e federações.

## 🗺️ Localização e Geografia

```mermaid
erDiagram
    COUNTRIES {
        int id PK
        string name
        string iso_code UK
        bool active
    }
    
    CITIES {
        int id PK
        string name
        int country_id FK
        bool active
    }
    
    VENUES {
        int id PK
        string name
        string address
        int capacity
        int city_id FK
        bool active
    }
    
    COUNTRIES ||--o{ CITIES : contains
    CITIES ||--o{ VENUES : located_in
```

## 👥 Pessoas e Funções

```mermaid
erDiagram
    PEOPLE {
        int id PK
        string first_name
        string last_name
        date birth_date
        string gender
        int nationality_id FK
        int birth_city_id FK
        string phone
        string email
        bool active
    }
    
    PLAYER_POSITIONS {
        int id PK
        string name UK
        text description
    }
    
    PLAYERS {
        int id PK
        int person_id FK
        int position_id FK
        int height_cm
        int weight_kg
        string preferred_foot
        bool active
    }
    
    ROLE_TYPES {
        int id PK
        string name UK
        text description
        string category
        bool active
    }
    
    STAFF {
        int id PK
        int person_id FK
        int main_role_id FK
        string document_number
        text notes
        bool active
    }
    
    PEOPLE ||--o{ PLAYERS : extends
    PEOPLE ||--o{ STAFF : extends
    PLAYER_POSITIONS ||--o{ PLAYERS : defines_position
    ROLE_TYPES ||--o{ STAFF : main_role
```

## 🏢 Organizações e Esportes

```mermaid
erDiagram
    SPORTS {
        int id PK
        string name UK
        text description
        bool team_based
        bool active
    }
    
    ENTITIES {
        int id PK
        string name
        string short_name
        string type
        date foundation_date
        int country_id FK
        int city_id FK
        bool active
    }
    
    FEDERATIONS {
        int id PK
        string name
        string acronym
        int sport_id FK
        string geographic_scope
        int parent_federation_id FK
        int country_id FK
        date foundation_date
        bool active
    }
    
    CATEGORIES {
        int id PK
        string name UK
        string short_name
        text description
        int min_age
        int max_age
        bool active
    }
    
    SPORTS ||--o{ FEDERATIONS : governs
    FEDERATIONS ||--o{ FEDERATIONS : parent_child
```

## ⚽ Equipes

```mermaid
erDiagram
    TEAMS {
        int id PK
        string name
        string short_name
        int entity_id FK
        int sport_id FK
        int category_id FK
        int federation_id FK
        date foundation_date
        int city_id FK
        int main_venue_id FK
        bool active
    }
    
    TRANSFER_TYPES {
        int id PK
        string name UK
        text description
    }
    
    TEAM_TRANSFERS {
        int id PK
        int player_id FK
        int previous_team_id FK
        int team_id FK
        int next_team_id FK
        date start_date
        date end_date
        string status
        int transfer_type_id FK
        decimal transfer_value
        int season
        text notes
    }
    
    TEAM_STAFF_TRANSFERS {
        int id PK
        int staff_id FK
        int previous_team_id FK
        int team_id FK
        int next_team_id FK
        date start_date
        date end_date
        string status
        int transfer_type_id FK
        decimal transfer_value
        int season
        int role_id FK
        text notes
    }
    
    TRANSFER_TYPES ||--o{ TEAM_TRANSFERS : categorizes
    TRANSFER_TYPES ||--o{ TEAM_STAFF_TRANSFERS : categorizes
```

## 🔗 Relacionamento: Organizações → Equipes

```mermaid
erDiagram
    ENTITIES {
        int id PK
        string name
        string type
        bool active
    }
    
    SPORTS {
        int id PK
        string name UK
        bool active
    }
    
    FEDERATIONS {
        int id PK
        string name
        string acronym
        int sport_id FK
        bool active
    }
    
    CATEGORIES {
        int id PK
        string name UK
        bool active
    }
    
    TEAMS {
        int id PK
        string name
        int entity_id FK
        int sport_id FK
        int category_id FK
        int federation_id FK
        bool active
    }
    
    ENTITIES ||--o{ TEAMS : owns
    SPORTS ||--o{ TEAMS : plays
    CATEGORIES ||--o{ TEAMS : competes_in
    FEDERATIONS ||--o{ TEAMS : registers
```

## 🤝 Relacionamento: Pessoas → Equipes

```mermaid
erDiagram
    PLAYERS {
        int id PK
        int person_id FK
        bool active
    }
    
    STAFF {
        int id PK
        int person_id FK
        bool active
    }
    
    TEAMS {
        int id PK
        string name
        bool active
    }
    
    PLAYER_TEAM_AFFILIATIONS {
        int id PK
        int player_id FK
        int team_id FK
        int team_transfer_id FK
        string jersey_number
        int contract_years
        bool active
        text notes
    }
    
    TEAM_STAFF_AFFILIATIONS {
        int id PK
        int staff_id FK
        int team_id FK
        int team_staff_transfer_id FK
        int role_id FK
        int contract_years
        bool active
        text notes
    }
    
    TEAM_TRANSFERS {
        int id PK
        int player_id FK
        int team_id FK
        date start_date
        date end_date
        string status
    }
    
    TEAM_STAFF_TRANSFERS {
        int id PK
        int staff_id FK
        int team_id FK
        date start_date
        date end_date
        string status
    }
    
    PLAYERS ||--o{ PLAYER_TEAM_AFFILIATIONS : affiliated_with
    TEAMS ||--o{ PLAYER_TEAM_AFFILIATIONS : has_players
    STAFF ||--o{ TEAM_STAFF_AFFILIATIONS : works_for
    TEAMS ||--o{ TEAM_STAFF_AFFILIATIONS : employs
    
    TEAM_TRANSFERS ||--o{ PLAYER_TEAM_AFFILIATIONS : creates
    TEAM_STAFF_TRANSFERS ||--o{ TEAM_STAFF_AFFILIATIONS : creates
```

## 🏆 Competições e Ligas

```mermaid
erDiagram
    FEDERATIONS {
        int id PK
        string name
        bool active
    }
    
    LEAGUES {
        int id PK
        string name
        int season_year
        int federation_id FK
        int sport_id FK
        int category_id FK
        date start_date
        date end_date
        string format
        string status
        bool active
    }
    
    TEAMS {
        int id PK
        string name
        bool active
    }
    
    LEAGUE_TEAMS {
        int id PK
        int league_id FK
        int team_id FK
        date registration_date
        string status
    }
    
    FEDERATIONS ||--o{ LEAGUES : organizes
    LEAGUES ||--o{ LEAGUE_TEAMS : contains
    TEAMS ||--o{ LEAGUE_TEAMS : participates
```

## ⚽ Partidas e Eventos

```mermaid
erDiagram
    TEAMS {
        int id PK
        string name
        bool active
    }
    
    LEAGUES {
        int id PK
        string name
        bool active
    }
    
    VENUES {
        int id PK
        string name
        bool active
    }
    
    STAFF {
        int id PK
        bool active
    }
    
    MATCHES {
        int id PK
        int home_team_id FK
        int away_team_id FK
        int league_id FK
        int venue_id FK
        datetime match_date
        int home_score
        int away_score
        string status
        int referee_id FK
        text notes
    }
    
    PLAYERS {
        int id PK
        bool active
    }
    
    PLAYER_SQUADS {
        int id PK
        int match_id FK
        int player_id FK
        int team_id FK
        string squad_type
        int jersey_number
        int position_id FK
        bool starter
        text notes
    }
    
    MATCH_EVENTS {
        int id PK
        int match_id FK
        int player_id FK
        int team_id FK
        string event_type
        int minute
        int position_id FK
        text description
    }
    
    TEAMS ||--o{ MATCHES : home_team
    TEAMS ||--o{ MATCHES : away_team
    LEAGUES ||--o{ MATCHES : part_of
    VENUES ||--o{ MATCHES : hosts
    STAFF ||--o{ MATCHES : referees
    
    MATCHES ||--o{ PLAYER_SQUADS : squad_selection
    PLAYERS ||--o{ PLAYER_SQUADS : selected_for
    TEAMS ||--o{ PLAYER_SQUADS : represents
    
    MATCHES ||--o{ MATCH_EVENTS : contains_events
    PLAYERS ||--o{ MATCH_EVENTS : participates_in
    TEAMS ||--o{ MATCH_EVENTS : team_context
```

## 🔄 Sistema de Transferências

```mermaid
erDiagram
    PLAYERS {
        int id PK
        bool active
    }
    
    STAFF {
        int id PK
        bool active
    }
    
    TEAMS {
        int id PK
        string name
        bool active
    }
    
    TRANSFER_TYPES {
        int id PK
        string name UK
        text description
    }
    
    TEAM_TRANSFERS {
        int id PK
        int player_id FK
        int previous_team_id FK
        int team_id FK
        int next_team_id FK
        date start_date
        date end_date
        string status
        int transfer_type_id FK
        decimal transfer_value
        int season
        text notes
    }
    
    TEAM_STAFF_TRANSFERS {
        int id PK
        int staff_id FK
        int previous_team_id FK
        int team_id FK
        int next_team_id FK
        date start_date
        date end_date
        string status
        int transfer_type_id FK
        decimal transfer_value
        int season
        int role_id FK
        text notes
    }
    
    PLAYER_TEAM_AFFILIATIONS {
        int id PK
        int player_id FK
        int team_id FK
        int team_transfer_id FK
        bool active
    }
    
    TEAM_STAFF_AFFILIATIONS {
        int id PK
        int staff_id FK
        int team_id FK
        int team_staff_transfer_id FK
        bool active
    }
    
    TRANSFER_TYPES ||--o{ TEAM_TRANSFERS : categorizes
    TRANSFER_TYPES ||--o{ TEAM_STAFF_TRANSFERS : categorizes
    
    PLAYERS ||--o{ TEAM_TRANSFERS : involves
    TEAMS ||--o{ TEAM_TRANSFERS : previous_team
    TEAMS ||--o{ TEAM_TRANSFERS : current_team
    TEAMS ||--o{ TEAM_TRANSFERS : next_team
    
    STAFF ||--o{ TEAM_STAFF_TRANSFERS : involves
    TEAMS ||--o{ TEAM_STAFF_TRANSFERS : previous_team
    TEAMS ||--o{ TEAM_STAFF_TRANSFERS : current_team
    TEAMS ||--o{ TEAM_STAFF_TRANSFERS : next_team
    
    TEAM_TRANSFERS ||--o{ PLAYER_TEAM_AFFILIATIONS : creates
    TEAM_STAFF_TRANSFERS ||--o{ TEAM_STAFF_AFFILIATIONS : creates
```