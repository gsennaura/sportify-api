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

## 🗃️ Project Structure

```
sportify-api/
├── src/
│   ├── api/
│   │   ├── routers/
│   │   ├── schemas/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── core/
│   │   ├── config.py
│   │   └── database.py
│   ├── main.py
├── scripts/
│   └── sql/
│       └── creation_database/
├── migrations/
├── tests/
├── Dockerfile
├── docker-compose.yml
├── pyproject.toml
├── poetry.lock
├── Makefile
└── .flake8
```

---

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

## 📝 Contribution Guidelines

Please use clear commit messages in English following the [conventional commits](https://www.conventionalcommits.org/) standard.

Example:
```bash
git commit -m "feat: add new endpoint for tournaments"
```

---

## 🛡️ License

This project is under the MIT License. See [LICENSE](LICENSE) for more details.
