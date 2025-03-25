# Tests in SportifyAPI

This directory contains all tests for the SportifyAPI project.

We follow Clean Architecture principles, Domain-Driven Design (DDD), SOLID, and Clean Code best practices.

---

## Test Types

We organize our tests into two main categories:

```
tests/
├── unit/                # Isolated tests for use cases and domain logic
│   ├── fakes/           # Fake repositories and unit of work implementations
│   └── use_cases/       # Tests for application use cases
├── integration/         # Tests for FastAPI routes and full stack flows
```

---

## Unit Tests (Pure logic)

- We **do not hit the database**.
- We use **Fake Repositories** and a **Fake Unit of Work** to simulate behavior.
- Fast, reliable, and isolated.

### Example: GetCountryByIdUseCase

```python
countries = {
    1: Country(id=1, name="Brazil", iso_code="BR"),
}
fake_repo = FakeCountryRepository(countries)
uow = FakeUnitOfWork(fake_repo)

use_case = GetCountryByIdUseCase(uow)
result = await use_case.execute(1)

assert result.name == "Brazil"
```

> This is a pure unit test: it only verifies business logic, not database integration.

---

## Integration Tests (Full flow)

- These tests **call real FastAPI endpoints**.
- They use **HTTP clients** like `httpx` or `TestClient`.
- They verify the end-to-end behavior of the application.

---

## Fakes vs Mocks

We prefer using **fakes** in unit tests instead of mocks:

- **Fakes** simulate real behavior (e.g., in-memory stores).
- **Mocks** verify interactions (e.g., checking if a method was called).

Fakes lead to **more meaningful and robust tests** in DDD and Clean Architecture.

---

## Future Guidelines

- Create one test file per use case.
- Use meaningful test names (`test_create_country_should_persist`).
- Separate unit and integration contexts.
- Keep tests **fast, focused, and deterministic**.

---

## Running Tests

```bash
make test  # runs pytest
```

Make sure you have dev dependencies installed via Poetry.

---

Happy testing! 🚀