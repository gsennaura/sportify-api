#!/bin/bash
set -e

echo "SportifyAPI Database Initialization"
echo "==================================="
echo "Environment: ${ENVIRONMENT:-development}"
echo "Database: $POSTGRES_DB"
echo "User: $POSTGRES_USER"
echo ""
echo "PostgreSQL is automatically executing SQL files in order:"
echo "========================================================"

# Schema files that PostgreSQL will execute automatically
SCHEMA_FILES=(
    "01_location.sql - Countries, Cities, Venues"
    "02_people.sql - People, Players, Staff, Roles"  
    "03_organizations.sql - Sports, Entities, Federations"
    "04_categories.sql - Age Categories"
    "05_teams.sql - Teams, Transfers, Affiliations"
    "06_leagues.sql - Leagues, Competitions"
    "07_matches.sql - Matches, Events"
)

for file_info in "${SCHEMA_FILES[@]}"; do
    echo "✓ $file_info"
done

# Sample data info
if [ "${ENVIRONMENT:-development}" != "production" ]; then
    echo "✓ 99_sample_data.sql - Sample data for testing"
else
    echo "ℹ Skipping sample data in production mode"
fi

echo ""
echo "All SQL files are being executed automatically by PostgreSQL"
echo "Database initialization will complete shortly..."
echo "==========================================================="