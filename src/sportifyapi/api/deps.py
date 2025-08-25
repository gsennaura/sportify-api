"""API dependency injection."""

from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.database import get_db_session
from ..domain.repositories.country_repository import CountryRepository
from ..infrastructure.database.repositories.country_repository import SQLCountryRepository


async def get_country_repository(
    session: AsyncSession = Depends(get_db_session)
) -> CountryRepository:
    """
    Dependency to get country repository.
    
    This is where we inject the concrete implementation
    of the repository interface.
    """
    return SQLCountryRepository(session)
