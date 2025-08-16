#!/bin/bash
set -e

echo "SportifyAPI Database Initialization"
echo "==================================="
echo "Environment: ${ENVIRONMENT:-development}"
echo "Database: $POSTGRES_DB"
echo "User: $POSTGRES_USER"

# Function to run SQL scripts with error handling
run_sql_script() {
    local script=$1
    local path="/docker-entrypoint-initdb.d/$script"
    
    if [ -f "$path" ]; then
        echo "Running $script..."
        if psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -f "$path"; then
            echo "✓ $script completed successfully"
            return 0
        else
            echo "✗ Error running $script"
            return 1
        fi
    else
        echo "✗ Warning: $script not found at $path!"
        return 1
    fi
}

# Process schema files in correct order
echo ""
echo "Creating database schema..."
echo "=========================="
SCHEMA_FILES=(
    "01_location.sql"
    "02_people.sql"
    "03_organizations.sql"
    "04_categories.sql"
    "05_teams.sql"
    "06_leagues.sql"
    "07_matches.sql"
)

for script in "${SCHEMA_FILES[@]}"; do
    run_sql_script "$script"
done

# Load sample data if not in production mode
if [ "${ENVIRONMENT:-development}" != "production" ]; then
    echo ""
    echo "Loading sample data..."
    echo "===================="
    if run_sql_script "99_sample_data.sql"; then
        echo "Sample data loaded successfully"
    else
        echo "Warning: Failed to load sample data"
    fi
fi

echo ""
echo "Database initialization complete!"
echo "================================"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "SELECT count(*) as countries FROM countries;"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "SELECT count(*) as teams FROM teams;"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" -c "SELECT count(*) as players FROM players;"
echo ""
echo "SportifyAPI database is ready to use!"