-include .env
export

# Makefile for SportifyAPI (Docker only)

.PHONY: format lint test check docker-clean docker-build docker-up docker-down docker-prune docker-logs docker-exec rebuild generate-models test-unit db-create db-reset db-connect db-diagram db-dump-schema db-dump-full check-prereqs

## Run code formatting and cleanup:
## - Black: formats code to a consistent style (PEP8, 88-char line length)
## - isort: automatically sorts and organizes imports
## - autoflake: removes unused imports and variables
tidy:
	poetry run black --line-length 88 src
	poetry run isort src
	poetry run autoflake --remove-all-unused-imports --recursive --in-place src

## Format and lint the code (runs inside Docker container)
format:
	poetry run black --line-length 88 src
	poetry run isort src
	poetry run autoflake --remove-all-unused-imports --recursive --in-place src
	poetry run flake8 --config=.flake8 src

## Run lint checks inside Docker
lint:
	poetry run flake8 --config=.flake8 src

## Run tests inside Docker (ensures the PYTHONPATH is set correctly for tests)
test:
	poetry run pytest --maxfail=1 --disable-warnings --tb=short

## Run all checks (format + lint + test) inside Docker
check: format lint test

## Build Docker images
docker-build:
	docker compose build

## Check prerequisites for SportifyAPI development
check-prereqs:
	@./scripts/check_prerequisites.sh

## Start Docker containers (with prerequisites check)
docker-up: check-prereqs
	docker compose up --build -d

## Stop Docker containers
docker-down:
	docker compose down

## Clean all unused Docker resources (volumes, networks, etc.)
docker-clean:
	docker system prune -a --volumes -f

## Remove all stopped containers, unused networks, dangling images, and build cache
docker-prune:
	docker system prune -af --volumes

## Show logs from the API container
docker-logs:
	docker compose logs -f api

## Enter the API container (for debugging)
docker-exec:
	docker compose exec api bash

## Rebuild the Docker environment and start containers (with prerequisites check)
rebuild: check-prereqs docker-down docker-clean docker-build docker-up docker-logs

## Generate models automatically based on the database schema
generate-models:
	poetry run sqlacodegen $(DATABASE_SYNC_URL) --outfile src/sportifyapi/infrastructure/database/models/models.py
	make tidy

## Unit tests (ensures the PYTHONPATH is set correctly)
test-unit:
	PYTHONPATH=src poetry run pytest tests/unit

## Create the database (starts PostgreSQL container only)
db-create:
	docker compose up -d db

## Reset the database (removes volume and recreates)
db-reset:
	docker compose down
	docker volume rm -f sportify-api_pgdata
	docker compose up -d db

## Connect to the database using psql
db-connect:
	docker compose exec db psql -U postgres -d sportify

## Generate a database schema diagram (requires schemaspy)
db-diagram:
	mkdir -p ./docs/database
	docker run --rm \
		--network sportify-api_default \
		-v "${PWD}/docs/database:/output" \
		-e SCHEMASPY_OUTPUT_DIR=/output \
		schemaspy/schemaspy:latest \
		-t pgsql \
		-host db \
		-port 5432 \
		-db sportify \
		-u postgres \
		-p postgres \
		-s public
	@echo "Schema diagram generated in docs/database/index.html"

## Dump database schema (no data)
db-dump-schema:
	docker compose exec db pg_dump -U postgres -d sportify --schema-only > scripts/sql/schema_dump.sql
	@echo "Schema dumped to scripts/sql/schema_dump.sql"

## Dump database with data
db-dump-full:
	docker compose exec db pg_dump -U postgres -d sportify > scripts/sql/full_dump.sql
	@echo "Full database dumped to scripts/sql/full_dump.sql"