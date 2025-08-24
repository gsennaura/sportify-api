-include .env
export

# Makefile simplificado para SportifyAPI

.PHONY: up down clean reset logs connect tidy test

## Inicia a aplicação (build + up + logs)
up:
	@echo "🚀 Iniciando SportifyAPI..."
	docker compose up --build -d
	@echo "✅ Containers iniciados. Mostrando logs..."
	docker compose logs -f

## Para todos os containers
down:
	@echo "🛑 Parando containers..."
	docker compose down

## Reset completo (remove volumes e reinicia)
reset:
	@echo "🔄 Reset completo do ambiente..."
	docker compose down
	docker volume rm -f sportify-api_pgdata || true
	docker system prune -f
	@echo "✅ Ambiente limpo. Use 'make up' para reiniciar."

## Mostra logs de todos os containers
logs:
	docker compose logs -f

## Conecta ao banco de dados
connect:
	docker compose exec db psql -U postgres -d sportify

## Limpa e formata o código
tidy:
	poetry run black --line-length 88 src
	poetry run isort src
	poetry run autoflake --remove-all-unused-imports --recursive --in-place src

## Executa testes
test:
	poetry run pytest --maxfail=1 --disable-warnings --tb=short

## Limpa recursos não utilizados
clean:
	docker system prune -f

## Ajuda - mostra comandos disponíveis
help:
	@echo "SportifyAPI - Comandos disponíveis:"
	@echo ""
	@echo "  make up      - Inicia aplicação (build + up + logs)"
	@echo "  make down    - Para todos os containers"
	@echo "  make reset   - Reset completo (remove volumes)"
	@echo "  make logs    - Mostra logs em tempo real"
	@echo "  make connect - Conecta ao banco de dados"
	@echo "  make tidy    - Formata o código"
	@echo "  make test    - Executa testes"
	@echo "  make clean   - Limpa recursos Docker"
	@echo "  make help    - Mostra esta ajuda"