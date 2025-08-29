# ------------------------------------------------------------
# SportifyAPI Makefile (first-run friendly, auto PATH & docker perms)
# ------------------------------------------------------------

-include .env
export

SHELL := /bin/bash
.ONESHELL:
.SILENT:
.DEFAULT_GOAL := help

# Detecta se usuário está no grupo docker; se não, usa sudo docker
DOCKER_BIN := $(shell groups $(USER) | grep -q '\bdocker\b' && echo docker || echo 'sudo docker')
COMPOSE    := $(DOCKER_BIN) compose

# Serviços conforme docker-compose.yml
SERVICE_API ?= api
SERVICE_DB  ?= db

# DB
DB_NAME ?= sportify
DB_USER ?= postgres

# Diretórios
SRC_DIR     ?= src
ENV_FILE    ?= .env
ENV_EXAMPLE ?= .env.example

# Detecta Poetry (ordem: sistema, ~/.poetry/bin, ~/.local/bin)
POETRY_BIN := $(shell command -v poetry 2>/dev/null || \
                 test -x "$$HOME/.poetry/bin/poetry" && echo "$$HOME/.poetry/bin/poetry" || \
                 test -x "$$HOME/.local/bin/poetry"  && echo "$$HOME/.local/bin/poetry" )

# ------------- helpers internos -------------
define add_path_to_bashrc
	if ! grep -q 'POETRY PATH - SPORTIFY' $$HOME/.bashrc 2>/dev/null; then \
	  echo '' >> $$HOME/.bashrc; \
	  echo '# POETRY PATH - SPORTIFY' >> $$HOME/.bashrc; \
	  echo 'export PATH="$$HOME/.poetry/bin:$$HOME/.local/bin:$$PATH"' >> $$HOME/.bashrc; \
	fi
endef

define ensure_poetry
	if [ -z "$(POETRY_BIN)" ]; then \
		echo "📦 Instalando Poetry..."; \
		curl -sSL https://install.python-poetry.org | python3 -; \
		$(call add_path_to_bashrc); \
		# Tenta ativar no shell atual:
		export PATH="$$HOME/.poetry/bin:$$HOME/.local/bin:$$PATH"; \
		POETRY_BIN=$$(command -v poetry 2>/dev/null); \
		if [ -z "$$POETRY_BIN" ]; then \
			echo "⚠️  Poetry instalado, mas o PATH ainda não foi recarregado."; \
			echo "   Abra um novo terminal OU rode: source $$HOME/.bashrc"; \
			exit 1; \
		fi; \
	else \
		# Garante PATH no shell atual mesmo se já existir:
		export PATH="$$HOME/.poetry/bin:$$HOME/.local/bin:$$PATH"; \
	fi
endef

define ensure_env
	if [ ! -f $(ENV_FILE) ]; then \
		if [ -f $(ENV_EXAMPLE) ]; then \
			echo "📝 Criando $(ENV_FILE) a partir de $(ENV_EXAMPLE)..."; \
			cp $(ENV_EXAMPLE) $(ENV_FILE); \
		else \
			echo "⚠️  $(ENV_EXAMPLE) não encontrado. Crie seu $(ENV_FILE) manualmente."; \
		fi \
	else \
		echo "✅ $(ENV_FILE) já existe."; \
	fi
endef

define wait_db
	echo "⏳ Aguardando banco de dados ficar pronto...";
	until $(COMPOSE) exec -T $(SERVICE_DB) pg_isready -U $(DB_USER) -d $(DB_NAME) >/dev/null 2>&1; do \
		sleep 1; \
	done
	echo "✅ Banco de dados respondendo.";
endef

define check_prereqs
	if ! command -v docker >/dev/null 2>&1; then \
		echo "❌ Docker não encontrado. Instale: https://docs.docker.com/get-docker/"; \
		exit 1; \
	fi
	docker compose version >/dev/null 2>&1 || { echo "❌ Docker Compose (plugin) não encontrado."; exit 1; }
	if ! command -v curl >/dev/null 2>&1; then \
		echo "❌ curl não encontrado. Instale via apt/dnf/pacman."; \
		exit 1; \
	fi
	if ! command -v python3 >/dev/null 2>&1; then \
		echo "❌ python3 não encontrado. Instale via apt/dnf/pacman."; \
		exit 1; \
	fi
endef

# ------------- targets -------------

.PHONY: setup
## setup: Prepara tudo (Poetry no PATH, deps Python, .env, build)
setup:
	echo "🔍 Checando pré-requisitos (docker / compose / curl / python3)..."
	$(call check_prereqs)

	$(call ensure_poetry)
	# Descobre poetry agora com PATH atualizado
	POETRY=$$(command -v poetry)
	echo "📦 Usando $$($$POETRY --version)"

	echo "📦 Instalando dependências Python..."
	$$POETRY install

	$(call ensure_env)

	echo "🐳 Construindo imagens Docker (usando $(DOCKER_BIN))..."
	if ! $(DOCKER_BIN) info >/dev/null 2>&1; then
		echo "⚠️  Sem permissão para falar com o Docker como usuário atual.";
		echo "   Vou tentar com sudo automaticamente (foi por isso que $(DOCKER_BIN) foi escolhido).";
	fi
	$(COMPOSE) build

	echo "✅ Setup concluído. Rode: make up"

.PHONY: build
## build: Apenas build das imagens Docker
build:
	echo "🐳 Buildando imagens (usando $(DOCKER_BIN))..."
	$(COMPOSE) build
	echo "✅ Imagens construídas."

.PHONY: up
## up: Sobe containers com banco de dados
up:
	@echo "🚀 Subindo aplicação..."
	$(COMPOSE) up -d --build
	$(call wait_db)
	@echo "✅ Containers rodando! API: http://localhost:8000"
	@echo "💡 Use 'make generate-models' para gerar modelos SQLAlchemy"
	@echo "📜 Logs em tempo real (Ctrl+C para sair)"
	$(COMPOSE) logs -f

.PHONY: down
## down: Derruba containers
down:
	echo "🛑 Derrubando containers..."
	$(COMPOSE) down

.PHONY: reset-setup
## reset-setup: Remove tudo que o setup criou (venv, env, docker images/volumes)
reset-setup:
	echo "🗑️  Limpando ambiente de desenvolvimento (setup)..."
	# Remove .venv criado pelo poetry
	rm -rf .venv
	# Remove .env (recria depois com make setup)
	rm -f .env
	# Remove imagens/volumes do projeto
	$(COMPOSE) down -v --rmi all --remove-orphans
	# Remove volumes específicos se necessário
	$(DOCKER_BIN) volume rm -f sportify-api_pgdata >/dev/null 2>&1 || true
	# Opcional: limpar cache do poetry
	# rm -rf ~/.cache/pypoetry
	echo "✅ Setup limpo. Rode 'make setup' para reconfigurar do zero."

.PHONY: logs
## logs: Mostra logs
logs:
	$(COMPOSE) logs -f

.PHONY: connect
## connect: Abre psql no container do DB
connect:
	$(COMPOSE) exec $(SERVICE_DB) psql -U $(DB_USER) -d $(DB_NAME)

.PHONY: tidy
## tidy: Formata e limpa código
tidy:
	POETRY=$$(command -v poetry || echo "$$HOME/.poetry/bin/poetry" )
	export PATH="$$HOME/.poetry/bin:$$HOME/.local/bin:$$PATH"
	$$POETRY run black --line-length 88 $(SRC_DIR)
	$$POETRY run isort $(SRC_DIR)
	$$POETRY run autoflake --remove-all-unused-imports --recursive --in-place $(SRC_DIR)

.PHONY: test
## test: Roda testes
test:
	POETRY=$$(command -v poetry || echo "$$HOME/.poetry/bin/poetry" )
	export PATH="$$HOME/.poetry/bin:$$HOME/.local/bin:$$PATH"
	$$POETRY run pytest --maxfail=1 --disable-warnings --tb=short

# ---------------- Modelos SQLAlchemy ----------------

.PHONY: generate-models
## generate-models: Gera modelos SQLAlchemy baseados no banco existente
generate-models:
	@echo "🔄 Gerando modelos SQLAlchemy baseados no banco de dados..."
	$(call wait_db)
	$(COMPOSE) exec -T $(SERVICE_API) sqlacodegen postgresql://postgres:postgres@db:5432/sportify \
		--generator declarative \
		--noviews \
		--tables athlete_positions,athlete_position_tags,athletes,cities,club_athlete_assignments,club_staff_assignments,clubs,countries,federation_staff_assignments,federations,people,referee_role_tags,referee_roles,referees,sports,staff,staff_role_tags,staff_roles,states \
		--outfile /tmp/generated_models.py
	@echo "📁 Copiando modelos gerados..."
	$(COMPOSE) exec -T $(SERVICE_API) cp /tmp/generated_models.py /app/src/sportifyapi/infrastructure/database/models/generated_models.py
	@echo "✅ Modelos gerados em: src/sportifyapi/infrastructure/database/models/generated_models.py"
	@echo "📝 Revise o arquivo e adapte conforme necessário!"

.PHONY: doctor
## doctor: Verifica docker, compose, poetry e conexão ao DB
doctor:
	echo "🔎 Docker bin: $(DOCKER_BIN)"
	$(DOCKER_BIN) --version || true
	$(COMPOSE) version || true
	POETRY=$$(command -v poetry || echo "$$HOME/.poetry/bin/poetry"); echo "📦 Poetry: $$($$POETRY --version 2>/dev/null || echo 'não encontrado')"
	echo "⏳ Checando serviços..."
	$(COMPOSE) ps
	echo "⏳ Checando DB..."
	$(COMPOSE) exec -T $(SERVICE_DB) pg_isready -U $(DB_USER) -d $(DB_NAME) || echo "⚠️ DB ainda não responde"

.PHONY: clean
## clean: Prune Docker
clean:
	$(DOCKER_BIN) system prune -f

.PHONY: help
## help: Mostra esta ajuda
help:
	echo "SportifyAPI - Comandos disponíveis:"
	awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z0-9\._-]+:.*?##/ {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
