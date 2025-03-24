# Infrastructure Layer - README

This directory contains all **infrastructure-related components** that provide concrete implementations for external systems used by the application, such as the database, cache, message brokers, and integrations with external APIs.

The infrastructure layer plays a crucial role in the **Clean Architecture** and **Domain-Driven Design (DDD)**, where the domain logic is kept free from technical details, and this layer encapsulates all the necessary infrastructure to support the application's needs.

---

## 📂 Directory Structure

```bash
infrastructure/
├── cache/                      # Redis, Memcached, or other caching implementations
├── database/
│   ├── alembic/               # Alembic migrations (used with SQLAlchemy)
│   ├── models/                # Auto-generated SQLAlchemy ORM models from the database
│   ├── repositories/          # Concrete implementations of domain repository interfaces
│   ├── base_repository.py     # Generic CRUD repository using SQLAlchemy
│   └── unit_of_work.py        # Transaction management using Unit of Work pattern
├── external_services/         # Integration with third-party APIs and services
```

---

## 🧱 `base_repository.py`

This file provides a **Generic Repository** with basic CRUD operations. It can be extended by feature-specific repositories, minimizing code duplication and enforcing standard patterns across data access layers.

### Responsibilities:
- Retrieve records (`get_by_id`, `get_all`)
- Insert one or many records (`create`, `create_many`)
- Defer creation to be committed later (`create_deferred`)
- Update and delete operations

This promotes **DRY** principles and allows for consistent reuse of common database operations.

---

## ♻️ `unit_of_work.py`

> References: https://lsilvadev.medium.com/design-pattern-unit-of-work-37b985416dcc

### What is it?

The **Unit of Work (UoW)** is a design pattern used to group multiple operations that should be executed within a single database transaction.

> "The purpose of the Unit of Work pattern is to maintain a list of objects affected by a business transaction and to coordinate the writing out of changes and the resolution of concurrency problems."  
> — *Martin Fowler*

### Why do we use it?

- **Atomicity**: ensures that a group of changes is committed together.
- **Consistency**: helps avoid partial updates in case of errors.
- **Isolation of concerns**: separates business logic from transaction handling.

### Implementation Details

Our implementation uses `AsyncSession` from SQLAlchemy and exposes a simple async context manager:

```python
async with UnitOfWork() as uow:
    await uow.people.create(...)
    await uow.teams.create(...)
    await uow.commit()
```

Repositories are injected into the `UnitOfWork`, and share the same session, allowing coordination and shared lifecycle.

---

## ✨ Benefits

- Enforces **Clean Architecture**: domain stays pure and infrastructure is encapsulated.
- Promotes **SOLID Principles**:
  - **Single Responsibility**: each class/module has a specific responsibility.
  - **Dependency Inversion**: domain depends on abstractions, not implementations.
- Simplifies **testing** and **transactional boundaries**.

---

## 📌 To Do Steps

- Add caching implementations inside `/cache`
- Add external APIs under `/external_services`
- Expand repository base with advanced queries if needed

---

> _This folder evolves as your system integrates with more technologies. Each piece here should be replaceable without affecting the domain or application layers._

