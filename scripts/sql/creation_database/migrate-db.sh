#!/bin/bash
set -e

echo "SportifyAPI Database Setup"
echo "========================="
echo "Environment: ${ENVIRONMENT:-development}"
echo "Database: $POSTGRES_DB"

# Always run schema scripts (they are idempotent with IF NOT EXISTS)
echo ""
echo "Executando scripts de criação..."
echo "==============================="

# Run each script
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/01_location.sql
echo "✓ 01_location.sql"

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/02_people.sql  
echo "✓ 02_people.sql"

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/03_organizations.sql
echo "✓ 03_organizations.sql"

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/04_categories.sql
echo "✓ 04_categories.sql"

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/05_teams.sql
echo "✓ 05_teams.sql"

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/06_leagues.sql
echo "✓ 06_leagues.sql"

psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/07_matches.sql
echo "✓ 07_matches.sql"

# Check if sample data should be loaded (only once)
echo ""
echo "Verificando dados de exemplo..."
echo "=============================="

# Check if sample data already exists
COUNTRY_COUNT=$(psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -t -c "SELECT COUNT(*) FROM countries;" 2>/dev/null | xargs || echo "0")

if [ "$COUNTRY_COUNT" -gt 0 ]; then
    echo "ℹ Dados de exemplo já existem (países: $COUNTRY_COUNT), pulando..."
elif [ "${ENVIRONMENT:-development}" = "production" ]; then
    echo "ℹ Modo produção - não carregando dados de exemplo"
else
    echo "Carregando dados de exemplo..."
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f /docker-entrypoint-initdb.d/99_sample_data.sql
    echo "✓ 99_sample_data.sql"
fi

echo ""
echo "Estatísticas do banco:"
echo "====================="
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
    SELECT 
        'Countries' as tabela, COUNT(*) as registros FROM countries
    UNION ALL SELECT 
        'Teams' as tabela, COUNT(*) as registros FROM teams  
    UNION ALL SELECT 
        'Players' as tabela, COUNT(*) as registros FROM players
    UNION ALL SELECT 
        'Federations' as tabela, COUNT(*) as registros FROM federations;"

echo ""
echo "✅ SportifyAPI database está pronto!"
