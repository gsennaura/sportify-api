from typing import AsyncGenerator

from sqlalchemy.ext.asyncio import (AsyncSession, async_sessionmaker,
                                    create_async_engine)
from sqlalchemy.orm import declarative_base

from .config import config

# Set up database URL from the config
DATABASE_URL = config.DATABASE_URL

# Create the async engine for database connection
engine = create_async_engine(DATABASE_URL, echo=True)

# Create the session maker for handling database sessions
async_session = async_sessionmaker(engine, expire_on_commit=False)

# Declarative base class for the ORM models
Base = declarative_base()


# Function to get a session for database transactions
async def get_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session() as session:
        yield session
