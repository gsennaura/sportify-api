# 🏆 Sportify API – Clean Architecture

> **A sports management API built with Clean Architecture, DDD, and SOLID principles.**

## 📁 Architecture Overview

```
src/sportifyapi/
├── main.py                 # 🚀 FastAPI application entry point
├── api/                    # 🌐 API layer (controllers, schemas)
│   ├── controllers/        # 🎮 Route handlers
│   └── schemas/           # 📋 Request/Response models
├── application/           # 📋 Application layer (use cases)
│   └── use_cases/         # 🎯 Business logic orchestration
├── domain/                # 🏗️ Domain layer (entities, repositories)
│   ├── entities/          # 🧱 Business entities
│   ├── repositories/      # 📦 Repository interfaces
│   └── value_objects/     # 💎 Value objects
├── infrastructure/        # 🔧 Infrastructure layer
│   └── database/          # 🗄️ Database implementations
│       ├── models/        # 📊 SQLAlchemy models
│       └── repositories/  # 🔌 Repository implementations
└── core/                  # ⚙️ Core configuration
    └── database.py        # 🔗 Database connection
```

## 🎯 Key Principles

### Clean Architecture Layers:
1. **Domain**: Pure business logic (entities, value objects)
2. **Application**: Use cases that orchestrate domain operations
3. **Infrastructure**: External concerns (database, APIs)
4. **API**: HTTP interface layer

### Benefits:
- ✅ **Testable**: Each layer can be tested in isolation
- ✅ **Maintainable**: Changes in one layer don't affect others
- ✅ **Scalable**: Easy to add new features
- ✅ **Framework Independent**: Business logic doesn't depend on FastAPI/SQLAlchemy

## 🚀 Quick Start

1. **Start the application** (from project root):
   ```bash
   make up
   ```

2. **Generate database models** (when schema changes):
   ```bash
   make generate-models
   ```

3. **Access the API**:
   - API: http://localhost:8000
   - Docs: http://localhost:8000/docs

## 📚 Learn More

- 🏗️ [Country Implementation Example](./docs/COUNTRY_IMPLEMENTATION.md)
- 🛠️ [Implementation Examples](./docs/IMPLEMENTATION_EXAMPLES.md)
- 📋 [Implementation Summary](./docs/IMPLEMENTATION_SUMMARY.md)

## 🔄 Development Workflow

1. **Database changes**: Update SQL scripts in `scripts/sql/`
2. **Model sync**: Run `make generate-models`
3. **Implement features**: Follow the Clean Architecture pattern
4. **Test**: Write unit tests for use cases, integration tests for APIs

---

**Remember**: This architecture keeps business logic independent of frameworks. Your domain entities don't know about FastAPI, SQLAlchemy, or databases! 🚀
