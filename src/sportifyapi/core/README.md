# Core Layer of SportifyAPI

The `core` directory contains the essential configuration and database setup for the application. This layer serves as the foundation of the project, providing services such as configuration management and database connection handling.

---

## Structure

- **config.py**: Contains configuration variables and environment settings. Configurations like `DATABASE_URL`, `SECRET_KEY`, `DEBUG`, and `LOGGING_LEVEL` are set up here.
- **database.py**: Contains the database connection setup, using SQLAlchemy with async support. It provides an engine and session factory to interact with the database asynchronously.
  
---

## Usage

### Configuration

The configuration is stored in the `config.py` file. You can set environment variables such as:

- `DATABASE_URL`: Connection URL for the PostgreSQL database.
- `SECRET_KEY`: Secret key for securing application data.
- `DEBUG`: Set to `True` for development mode.
- `LOGGING_LEVEL`: Adjust the logging verbosity.

These variables can be accessed through the `Config` class in `config.py`.

### Database

The database connection is set up in `database.py`. It uses SQLAlchemy's `asyncpg` dialect for PostgreSQL, allowing asynchronous queries. 

To interact with the database, you can use the `get_session()` function to obtain a session for database operations. Example:

```python
from src.sportifyapi.core.database import get_session

async with get_session() as session:
    # Perform database operations with the session
    pass
