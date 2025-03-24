# SportifyAPI

A professional backend API built with **FastAPI**, **PostgreSQL**, **SQLAlchemy**, and **Docker**, designed to manage sports tournaments and related entities efficiently.

---

## 🚀 Technologies

- **Python 3.12**
- **FastAPI**
- **SQLAlchemy (Async ORM)**
- **Alembic** for database migrations
- **PostgreSQL**
- **Docker & Docker Compose**
- **Poetry** (Dependency management)
- **Pydantic** for data validation
- **Flake8, Black, isort, Autoflake** for code quality

---

## ✅ Prerequisites

Before running the project, ensure you have these installed:

- [Docker and Docker Compose](https://docs.docker.com/get-docker/)
- [Poetry](https://python-poetry.org/docs/#installation) *(optional but recommended for dependency management outside Docker)*
- Git

---

## 🛠️ Installation and Setup

### 1\. Clone the repository:

```bash
git clone git@github.com:gsennaura/sportify-api.git
cd sportify-api
```

### 2\. Start the application

Run Docker Compose to start API and PostgreSQL:

```bash
make docker-up
```

Once running, the API will be accessible at:
```
http://localhost:8000
```

Automatic API documentation:
- Swagger UI: [`http://localhost:8000/docs`](http://localhost:8000/docs)
- Redoc documentation:
```
http://localhost:8000/redoc
```

---

## Generate Database Models (optional)

If you already have an existing database schema, you can generate your SQLAlchemy ORM models automatically:

- Make sure the database is up and running using Docker:

```bash
make generate-models
```

- This command will generate the SQLAlchemy models based on your existing PostgreSQL database schema and store them at:

```bash
src/sportifyapi/infrastructure/database/models/models.py
```

## 📌 Database Migrations with Alembic

After defining models, you need to create database migrations using **Alembic**:

### 1\. Initialize Alembic (only needed once):
```bash
make docker-exec
poetry run alembic init migrations
```

### 2\. Generate migration script based on model changes:
```bash
make docker-exec
poetry run alembic revision --autogenerate -m "Initial migration"
```

### 3\. Apply the migration to the database:
```bash
make docker-exec
poetry run alembic upgrade head
```

---

## 🛠 Code Quality & Formatting

To maintain high code quality, we use **Flake8**, **Black**, **isort**, and **Autoflake**. 

### 🏗 **Lint & Format Automatically**

```bash
make tidy  # Fix formatting & lint issues
```

### 🔍 **Check Linting and Run Tests**

```bash
make check  # Runs lint, format, and tests
```

### 🛠 **Available Makefile Commands**

```bash
make docker-up       # Start containers
make docker-down     # Stop containers
make docker-build    # Build Docker images
make docker-clean    # Clean up unused Docker resources
make docker-prune    # Remove stopped containers, networks, and cache
make docker-logs     # Show API container logs
make docker-exec     # Enter the API container
make format          # Format code (Black, isort, autoflake)
make lint            # Run linting checks (Flake8)
make test            # Run unit tests (pytest)
make tidy            # Format & lint code automatically
make check           # Run all checks (format + lint + test)
```

---

## 📂 Project Structure (Clean Architecture + DDD)

This project follows a **Clean Architecture** and **Domain-Driven Design (DDD)** approach to provide clear separation of concerns, maintainability, and scalability:

```bash
src/
└── sportifyapi/
    ├── api/                          # HTTP Layer (FastAPI)
    │   ├── controllers/              # Endpoints (API routes)
    │   ├── schemas/                  # Pydantic Validations (API Contracts)
    │   └── middlewares/              # Auth, Logs, HTTP errors treatment
    │
    ├── application/                  # Casos de Uso (Orquestração de regras de negócio)
    │   ├── use_cases/                # Cada caso de uso claramente definido
    │   └── services/                 # Regras de negócio e orquestração complexa
    │
    ├── domain/                       # Domínio puro (DDD)
    │   ├── entities/                 # Entidades do domínio (Regras centrais)
    │   ├── value_objects/            # Objetos de valor (DDD)
    │   ├── repositories/             # Interfaces de repositório (abstrações)
    │   └── exceptions/               # Exceções customizadas do domínio
    │
    ├── infrastructure/               # Implementações concretas
    │   ├── database/                 # SQLAlchemy, Models e ORM
    │   │   ├── alembic/              # Migrações do Alembic
    │   │   ├── models/               # Modelos específicos para ORM
    │   │   └── repositories/         # Implementações concretas dos repositorios
    │   ├── cache/                    # Implementação Redis/Memcached
    │   └── external_services/        # Integrações externas (API externas, AWS, etc.)
    │
    ├── core/                         # Configuração, logs, conexões globais
    │   ├── config.py                 # Variáveis de ambiente, constantes
    │   └── database.py               # Conexão com o banco, sessões ORM
    │
    ├── tests/                        # Testes unitários e integração
    │   ├── unit/
    │   └── integration/
    │
    └── main.py                       # Ponto de entrada da aplicação FastAPI


```

🧩 O que significa cada diretório (resumo):
Diretório	Conteúdo	Relacionado a (Clean Arch/DDD)

api/controllers	FastAPI endpoints (rotas HTTP)	Interface (adapters)
api/schemas	Modelos de validação Pydantic (input/output API)	Interface (adapters)
api/middlewares	Autenticação, logs, tratamento de erros	Interface (adapters)
application/use_cases	Casos de uso que representam ações do usuário	Application Layer
application/services	Serviços de negócios, orquestração	Application Layer
domain/entities	Entidades com regras de negócio puras	Domain Layer (DDD)
domain/value_objects	Objetos de valor	Domain Layer (DDD)
domain/repositories	Interfaces abstratas de repositórios	Domain Layer (DDD)
infrastructure/	Implementações concretas (ex: SQLAlchemy)	Infrastructure Layer (adapters)
core/	Configuração global e conexões	Cross-Cutting Concerns
tests/	Testes	Cross-Cutting Concerns

---

### Database Initialization Scripts

SQL scripts used to initialize and populate the database for local development or testing environments.  
Location:

- scripts/sql/creation_database/

---

## 📝 Contribution Guidelines

Please use clear commit messages in English following the [conventional commits](https://www.conventionalcommits.org/) standard.

Example:
```bash
git commit -m "feat: add new endpoint for tournaments"
```

---

## 🛡️ License

This project is under the MIT License. See [LICENSE](LICENSE) for more details.
