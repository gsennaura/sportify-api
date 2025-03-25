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

## 🧠 Domain-Driven Design + Clean Architecture: Countries Example

This project applies **Domain-Driven Design (DDD)** and **Clean Architecture** principles to create a highly maintainable and scalable backend system.

Let's walk through a real-world example: the `Country` entity and its complete **CRUD** implementation using:

- DDD layers (Entity, Repository Interface, Use Cases)
- Clean Architecture separation of concerns
- SOLID principles (especially SRP and DIP)

---

### 🧱 Why This Structure?

| Layer        | Responsibility                                        |
|--------------|--------------------------------------------------------|
| **Domain**   | Pure business rules, agnostic to frameworks/libraries |
| **Application** | Orchestrates business logic via use cases           |
| **Infrastructure** | Implements access to external systems (DB, APIs) |
| **API**      | Handles HTTP logic (FastAPI routes/controllers)       |

This separation makes testing easier, improves modularity, and decouples concerns.

---

### 🔍 Domain Layer

#### `domain/entities/country.py`
```python
class Country:
    def __init__(self, id: Optional[int], name: str, iso_code: str):
        self.id = id
        self.name = name
        self.iso_code = iso_code
```
> ✅ Pure logic: no SQLAlchemy, no Pydantic. This is our business entity.

#### `domain/repositories/country_repository_interface.py`
```python
class CountryRepositoryInterface(Protocol):
    async def get_by_id(self, id: int) -> Optional[Country]: ...
    async def get_all(self) -> List[Country]: ...
    async def create(self, country: Country) -> Country: ...
    async def delete(self, id: int) -> Optional[Country]: ...
    async def update(self, id: int, data: dict) -> Optional[Country]: ...
```
> ✅ Defines **what** our repository should do, not **how**.

---

### 🧠 Application Layer

#### Example: `application/use_cases/country/get_country_by_id.py`
```python
class GetCountryByIdUseCase:
    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self, country_id: int) -> Optional[Country]:
        repo = self.uow.get_repository(CountryRepository)
        return await repo.get_by_id(country_id)
```
> ✅ Encapsulates the business logic. Use Cases are action-focused (verbs). Easy to test.

---

### 🧱 Infrastructure Layer

#### `infrastructure/database/repositories/country_repository.py`
```python
class CountryRepository(CountryRepositoryInterface):
    def __init__(self, session: AsyncSession):
        self.session = session
        self.base_repo = BaseRepository(CountryModel, session)

    async def get_by_id(self, id: int) -> Optional[Country]:
        model = await self.base_repo.get_by_id(id)
        return self._to_entity(model) if model else None

    def _to_entity(self, model: CountryModel) -> Country:
        return Country(id=model.id, name=model.name, iso_code=model.iso_code)
```
> ✅ This is the implementation that connects to the database (SQLAlchemy). It adapts the model to the domain entity.

---

### 🌐 API Layer

#### `api/controllers/country_controller.py`
```python
@router.get("/{country_id}", response_model=CountryResponse)
async def get_country_by_id(country_id: int):
    async with get_unit_of_work() as uow:
        use_case = GetCountryByIdUseCase(uow)
        country = await use_case.execute(country_id)
        if not country:
            raise HTTPException(status_code=404, detail="Country not found")
        return country
```
> ✅ The controller knows about **use cases**, not repositories or SQLAlchemy.

---

### 🧪 Bonus: Unit of Work (Transaction Management)

```python
class UnitOfWork:
    def get_repository(self, repo_type):
        ...

@asynccontextmanager
async def get_unit_of_work():
    async for session in get_session():
        uow = UnitOfWork(session)
        try:
            yield uow
            await uow.commit()
        except:
            await uow.rollback()
            raise
        finally:
            await uow.close()
```
> ✅ Guarantees atomic operations (single transaction). Useful for multiple inserts/updates.

---

### 🧰 Summary of What We've Done (Countries)

- ✅ Created **Domain Entity** (`Country`)
- ✅ Defined **Repository Interface** for abstraction
- ✅ Built **Concrete Repository** to access the DB
- ✅ Implemented **Use Cases** for each action (Get, Create, Update, Delete)
- ✅ Created **Pydantic Schemas** for API validation
- ✅ Connected it all via **Controllers** in the API

---

### ✅ Why This Matters

- Clean code that's easy to **test, scale, and change**
- Business logic is **decoupled from framework or DB**
- Facilitates **unit testing** without mocks from infrastructure
- Promotes **separation of concerns** and **open/closed** principle (SOLID)

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
