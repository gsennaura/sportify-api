# SportifyAPI Database Schema

This directory contains SQL scripts that create the SportifyAPI database structure. The scripts implement a comprehensive sports management system capable of handling teams, leagues, players, and matches with a focus on flexibility and detailed tracking.

## Getting Started

To set up the SportifyAPI database:

1. **Using Docker (Recommended)**:
   ```bash
   # From the project root directory
   docker-compose up -d
   ```
   The database will be automatically created and initialized using the scripts in this directory.

2. **Manual Setup** (if not using Docker):
   ```bash
   createdb sportify
   
   # Run scripts in sequence - order is important due to dependencies!
   psql -d sportify -f 01_location.sql
   psql -d sportify -f 02_people.sql
   psql -d sportify -f 03_organizations.sql
   psql -d sportify -f 04_categories.sql
   psql -d sportify -f 05_teams.sql
   psql -d sportify -f 06_leagues.sql
   psql -d sportify -f 07_matches.sql
   
   # Optionally load sample data
   psql -d sportify -f 99_sample_data.sql
   ```

> **Important Note**: There is a circular reference between `leagues` and `player_achievements` tables. The `player_achievements` table references `leagues`, which is created in a later script. PostgreSQL will handle this correctly when all scripts are run in sequence, but be aware of this dependency.

## Core Business Concepts

### Team Structure
- **Teams** have a location and main stadium/venue
- Teams belong to **Entities** (clubs, organizations)
- One entity can have **multiple teams** across different sports and categories
- Teams have **staff** (presidents, directors, coaches) which can be:
  - Team-wide (e.g., president)
  - Category-specific (e.g., U17 coach)
- Teams have **players** (athletes)
- Teams can have **multiple categories** (age groups/competition levels)

### Player Affiliations
- A player can represent **different categories** within the same team
- A player can only play for **one team per league**
- Whether a player can play for different teams in different leagues is **configurable**
- Federation-level restrictions can be set
- **Complete career history** tracking with:
  - Previous teams and transfer details
  - Achievements and statistics
  - Contract information

### Competition Organization
- **Federations** organize leagues
- **Leagues** contain teams competing in specific categories
- **Matches** track detailed events and statistics

## Database Files Structure

| File | Purpose | Key Tables |
|------|---------|------------|
| `00_load_order.sql` | Documentation and load order | N/A |
| `01_location.sql` | Geographic data and venues | `countries`, `states`, `cities`, `venues` |
| `02_people.sql` | People records and roles | `people`, `players`, `role_types`, `contact_info` |
| `03_organizations.sql` | Organizations and sports | `sports`, `entities`, `federations`, `organization_staff` |
| `04_categories.sql` | Age groups and levels | `categories` |
| `05_teams.sql` | Teams and affiliations | `teams`, `team_categories`, `team_staff`, `player_team_affiliations`, `player_achievements`, `player_career_statistics` |
| `06_leagues.sql` | Leagues and eligibility | `leagues`, `league_teams`, `eligibility_rules`, `league_relationships` |
| `07_matches.sql` | Match data | `matches`, `match_squads`, `match_events`, `match_statistics` |
| `99_sample_data.sql` | Test data | (Inserts into all tables) |

## Entity Relationship Overview

The database schema follows a modular design with clear relationships between entities:

```
                                  ┌───────────┐
                      ┌───────────┤ Countries │
                      │           └───────────┘
                      │                 │
                      │                 ▼
┌─────────┐     ┌─────┴─────┐     ┌──────────┐     ┌───────┐
│ Sports  │────►│ Entities  │◄────┤  Cities  │────►│Venues │
└─────────┘     └───────────┘     └──────────┘     └───────┘
     │                │                                 │
     │                ▼                                 │
     │          ┌───────────┐                           │
     └────────►│Federations│                           │
               └───────────┘                           │
                     │                                 │
                     ▼                                 │
┌─────────┐    ┌───────────┐                           │
│Categories│◄───┤  Leagues  │                          │
└─────────┘    └───────────┘                           │
     │               │                                 │
     │               ▼                                 │
     │         ┌───────────┐                           │
     └────────►│League Teams│                          │
               └───────────┘                           │
                     │                                 │
                     │                                 │
                     ▼                                 │
┌─────────┐    ┌───────────┐                           │
│  People  │◄───┤   Teams   │◄──────────────────────────┘
└─────────┘    └───────────┘
     │               │
     │               ▼
     │         ┌───────────────┐
     └────────►│Team Categories│
               └───────────────┘
                     │
                     ▼
┌─────────┐    ┌───────────────────────┐    ┌────────────┐
│ Players │◄───┤Player Team Affiliations│───►│  Matches   │
└─────────┘    └───────────────────────┘    └────────────┘
                           │                      │
                           │                      ▼
                           │                ┌────────────────┐
                           └───────────────►│Match Statistics│
                                            └────────────────┘
```

## Key Features & Technical Details

### Entity-Team Relationship

The database uses a hierarchical structure for organizations and teams:

1. **Entities (Organizations)**
   - Represent clubs, federations, associations, etc.
   - Store organization-level data like name, foundation date, country, logo

2. **Teams**
   - Have a foreign key `entity_id` linking to their parent entity
   - Represent actual sporting teams that participate in competitions
   - Can have multiple categories (Professional, U20, etc.)

This enables:
- One organization managing multiple teams
- Teams sharing common organizational attributes
- Federation-team-league relationships

## Entity-Team Relationship in Detail

The relationship between entities and teams is a key design feature of this database schema:

### How It Works

1. **Entities** (in `03_organizations.sql`) represent organizational bodies like:
   - Sports clubs
   - Federations
   - Associations

2. **Teams** (in `05_teams.sql`) represent the actual sporting teams:
   - A team MUST belong to an entity (`entity_id` foreign key)
   - A team is tied to a specific sport (`sport_id` foreign key)
   - A team can have multiple categories (age groups/competition levels)

### Examples

Consider a large sports club organization like "FC Barcelona" that fields teams in multiple sports:

```
Entity: FC Barcelona (organization)
├── Team: FC Barcelona (football/soccer team)
│   ├── Category: Professional
│   ├── Category: U21
│   └── Category: Women's Team
├── Team: FC Barcelona Basket (basketball team)
│   ├── Category: Professional
│   └── Category: Junior
└── Team: FC Barcelona Handball (handball team)
    └── Category: Professional
```

### SQL Structure

This relationship is defined through these key fields:

```sql
-- Entities table
CREATE TABLE entities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('club', 'federation', 'association', 'company', 'government')),
    -- other fields
);

-- Teams table
CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    entity_id INTEGER NOT NULL REFERENCES entities(id) ON DELETE CASCADE,
    sport_id INTEGER NOT NULL REFERENCES sports(id) ON DELETE CASCADE,
    -- other fields
);
```

### Design Benefits

This two-tier approach offers several advantages:

1. **Organizational Accuracy**: Properly models real-world sports structures
2. **Data Normalization**: Prevents duplication of organizational info
3. **Flexibility**: Supports various organizational models (multi-sport clubs, single-team entities)
4. **Unified Management**: Enables organization-wide operations and reporting

If your use case only needs single teams without organizational hierarchy, you can simply create one entity per team.

### Configurable Eligibility Rules
The database supports complex eligibility rules for players:

```sql
-- Example: Allow players to play in multiple leagues for same federation
INSERT INTO eligibility_rules (federation_id, allow_cross_league) 
VALUES ([federation_id], true);

-- Example: Restrict players to one team per federation
INSERT INTO eligibility_rules (federation_id, allow_cross_team_within_federation) 
VALUES ([federation_id], false);
```

### Common Queries and Use Cases

```sql
-- Find all players for a team in a specific category
SELECT p.first_name, p.last_name, pta.jersey_number
FROM people p
JOIN players pl ON p.id = pl.person_id
JOIN player_team_affiliations pta ON pl.id = pta.player_id
JOIN teams t ON pta.team_id = t.id
JOIN categories c ON pta.category_id = c.id
WHERE t.short_name = 'FLA'
  AND c.short_name = 'PRO'
  AND pta.status = 'active'
  AND pta.season_year = 2023;
```

For additional queries, see the examples in each SQL file.

## Useful Query Examples

Here are some practical SQL queries for common operations with this database schema:

### Team Management

```sql
-- Get all teams for an entity (e.g., club) with their categories
SELECT t.id, t.name, t.short_name, 
       array_agg(DISTINCT c.name) as categories
FROM teams t
JOIN team_categories tc ON t.id = tc.team_id
JOIN categories c ON tc.category_id = c.id
WHERE t.entity_id = 1  -- Entity ID
AND tc.season_year = 2023
GROUP BY t.id, t.name, t.short_name;

-- Get all staff for a team, including category-specific roles
SELECT p.first_name, p.last_name, 
       rt.name as role,
       c.name as category,
       ts.start_date
FROM team_staff ts
JOIN people p ON ts.person_id = p.id
JOIN role_types rt ON ts.role_id = rt.id
LEFT JOIN team_categories tc ON ts.team_category_id = tc.id
LEFT JOIN categories c ON tc.category_id = c.id
WHERE ts.team_id = 1  -- Team ID
ORDER BY rt.category, c.name NULLS FIRST;
```

### Player Operations

```sql
-- Get player career history
SELECT p.first_name, p.last_name,
       t.name as team_name,
       c.name as category_name,
       pta.start_date, pta.end_date,
       pta.transfer_type, pta.transfer_fee
FROM players pl
JOIN people p ON pl.person_id = p.id
JOIN player_team_affiliations pta ON pl.id = pta.player_id
JOIN teams t ON pta.team_id = t.id
JOIN categories c ON pta.category_id = c.id
WHERE pl.id = 1  -- Player ID
ORDER BY pta.start_date DESC;

-- Get player statistics
SELECT t.name as team_name,
       c.name as category_name,
       pcs.season_year,
       pcs.games_played,
       pcs.goals_scored,
       pcs.assists
FROM player_career_statistics pcs
JOIN player_team_affiliations pta ON pcs.affiliation_id = pta.id
JOIN teams t ON pta.team_id = t.id
JOIN categories c ON pta.category_id = c.id
WHERE pcs.player_id = 1  -- Player ID
ORDER BY pcs.season_year DESC;
```

### Match & League Queries

```sql
-- Get upcoming matches for a team
SELECT l.name as league_name,
       t_home.name as home_team,
       t_away.name as away_team,
       m.scheduled_datetime,
       v.name as venue
FROM matches m
JOIN leagues l ON m.league_id = l.id
JOIN teams t_home ON m.home_team_id = t_home.id
JOIN teams t_away ON m.away_team_id = t_away.id
LEFT JOIN venues v ON m.venue_id = v.id
WHERE (m.home_team_id = 1 OR m.away_team_id = 1)  -- Team ID
AND m.scheduled_datetime > CURRENT_TIMESTAMP
ORDER BY m.scheduled_datetime;

-- Get league standings (example using match data)
WITH team_results AS (
    SELECT 
        lt.league_id,
        lt.team_category_id,
        t.id as team_id,
        t.name as team_name,
        COUNT(m.id) as matches_played,
        SUM(CASE WHEN (m.home_team_id = t.id AND m.home_score > m.away_score) OR 
                      (m.away_team_id = t.id AND m.away_score > m.home_score) 
                 THEN 1 ELSE 0 END) as wins,
        SUM(CASE WHEN m.home_score = m.away_score THEN 1 ELSE 0 END) as draws,
        SUM(CASE WHEN (m.home_team_id = t.id AND m.home_score < m.away_score) OR 
                      (m.away_team_id = t.id AND m.away_score < m.home_score) 
                 THEN 1 ELSE 0 END) as losses
    FROM league_teams lt
    JOIN team_categories tc ON lt.team_category_id = tc.id
    JOIN teams t ON tc.team_id = t.id
    LEFT JOIN matches m ON (m.league_id = lt.league_id AND (m.home_team_id = t.id OR m.away_team_id = t.id))
    WHERE lt.league_id = 1  -- League ID
    AND m.status = 'completed'
    GROUP BY lt.league_id, lt.team_category_id, t.id, t.name
)
SELECT 
    team_name,
    matches_played,
    wins,
    draws,
    losses,
    (wins * 3 + draws) as points
FROM team_results
ORDER BY points DESC, wins DESC;
```

These queries demonstrate how to extract useful information from the SportifyAPI database structure for common sports management operations.

## Domain Entity Implementation Guide

When implementing domain entities that map to this database schema, consider the following approach:

### Recommended Domain Entities

1. **Country**
   ```python
   @dataclass
   class Country:
       id: Optional[int]
       name: str
       iso_code: str
       active: bool = True
   ```

2. **Team**
   ```python
   @dataclass
   class Team:
       id: Optional[int]
       name: str
       short_name: Optional[str]
       entity_id: int
       sport_id: int
       foundation_date: Optional[date]
       city_id: Optional[int]
       main_venue_id: Optional[int]
       categories: List['TeamCategory'] = field(default_factory=list)
       active: bool = True
   ```

3. **Player**
   ```python
   @dataclass
   class Player:
       id: Optional[int]
       person_id: int
       height: Optional[float]
       weight: Optional[float]
       dominant_foot: Optional[str]
       position: Optional[str]
       active: bool = True
       # Related data (to be loaded separately or via use case)
       affiliations: List['PlayerTeamAffiliation'] = field(default_factory=list)
       achievements: List['PlayerAchievement'] = field(default_factory=list)
       statistics: List['PlayerCareerStatistics'] = field(default_factory=list)
   ```

### Repository Pattern

Implement repositories using dependency inversion:

1. Define repository interfaces in the domain layer
2. Implement concrete repositories in the infrastructure layer
3. Use a Unit of Work pattern for transaction management

Example:

```python
# Domain layer
class TeamRepositoryInterface(Protocol):
    async def get_by_id(self, id: int) -> Optional[Team]: ...
    async def list_all(self) -> List[Team]: ...
    async def create(self, team: Team) -> Team: ...
    # other methods...

# Infrastructure layer
class TeamRepository(BaseRepository):
    async def get_by_id(self, id: int) -> Optional[Team]:
        async with self.unit_of_work.connection() as connection:
            result = await connection.fetchrow(
                "SELECT * FROM teams WHERE id = $1", id
            )
            if not result:
                return None
            return Team(**dict(result))
    # other methods...
```

### Many-To-Many Relationships

For complex relationships like player-team affiliations, consider these approaches:

1. **Direct Model Mapping**: Create domain entities for each table
2. **Aggregate Pattern**: Load related data as part of the aggregate root
3. **Query Objects**: Create specialized objects for complex queries

Remember to handle circular dependencies carefully, especially when implementing repositories for entities with complex relationships.

## Database Management with Make

The project includes several Make commands for database management:

```bash
# Start only the database
make db-create

# Reset the database (removes the volume and recreates)
make db-reset

# Connect to database with psql
make db-connect

# Generate database schema documentation
make db-diagram
```

These commands simplify common database operations during development.