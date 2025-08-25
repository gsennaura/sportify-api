"""Country Repository Implementation."""

from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError

from ...domain.entities.country import Country
from ...domain.repositories.country_repository import CountryRepository
from ...domain.value_objects.iso_code import ISOCode
from ..models.country import CountryModel


class SQLCountryRepository(CountryRepository):
    """
    SQLAlchemy implementation of CountryRepository.
    
    This is the INFRASTRUCTURE implementation that knows about:
    - SQLAlchemy
    - Database sessions
    - SQL queries
    - Error handling
    """
    
    def __init__(self, session: AsyncSession):
        self._session = session
    
    async def save(self, country: Country) -> Country:
        """Save a country entity to database."""
        # Convert domain entity to database model
        db_country = CountryModel(
            name=country.name,
            iso_code=str(country.iso_code),
            active=country.is_active
        )
        
        try:
            self._session.add(db_country)
            await self._session.flush()  # Get the ID without committing
            
            # Convert back to domain entity
            return self._model_to_entity(db_country)
            
        except IntegrityError as e:
            await self._session.rollback()
            if "unique constraint" in str(e).lower():
                raise ValueError(f"Country with ISO code '{country.iso_code}' already exists")
            raise ValueError(f"Error saving country: {str(e)}")
    
    async def find_by_id(self, country_id: int) -> Optional[Country]:
        """Find country by ID."""
        stmt = select(CountryModel).where(CountryModel.id == country_id)
        result = await self._session.execute(stmt)
        db_country = result.scalar_one_or_none()
        
        if db_country:
            return self._model_to_entity(db_country)
        return None
    
    async def find_by_iso_code(self, iso_code: ISOCode) -> Optional[Country]:
        """Find country by ISO code."""
        stmt = select(CountryModel).where(CountryModel.iso_code == str(iso_code))
        result = await self._session.execute(stmt)
        db_country = result.scalar_one_or_none()
        
        if db_country:
            return self._model_to_entity(db_country)
        return None
    
    async def find_all(self, active_only: bool = False) -> List[Country]:
        """Find all countries."""
        stmt = select(CountryModel)
        
        if active_only:
            stmt = stmt.where(CountryModel.active == True)
        
        stmt = stmt.order_by(CountryModel.name)
        
        result = await self._session.execute(stmt)
        db_countries = result.scalars().all()
        
        return [self._model_to_entity(db_country) for db_country in db_countries]
    
    async def update(self, country: Country) -> Country:
        """Update existing country."""
        stmt = select(CountryModel).where(CountryModel.id == country.id)
        result = await self._session.execute(stmt)
        db_country = result.scalar_one_or_none()
        
        if not db_country:
            raise ValueError(f"Country with ID {country.id} not found")
        
        # Update fields
        db_country.name = country.name
        db_country.iso_code = str(country.iso_code)
        db_country.active = country.is_active
        
        try:
            await self._session.flush()
            return self._model_to_entity(db_country)
            
        except IntegrityError as e:
            await self._session.rollback()
            if "unique constraint" in str(e).lower():
                raise ValueError(f"Country with ISO code '{country.iso_code}' already exists")
            raise ValueError(f"Error updating country: {str(e)}")
    
    async def delete(self, country_id: int) -> bool:
        """Delete country by ID."""
        stmt = select(CountryModel).where(CountryModel.id == country_id)
        result = await self._session.execute(stmt)
        db_country = result.scalar_one_or_none()
        
        if db_country:
            await self._session.delete(db_country)
            return True
        return False
    
    async def exists_by_iso_code(self, iso_code: ISOCode) -> bool:
        """Check if country exists by ISO code."""
        stmt = select(CountryModel.id).where(CountryModel.iso_code == str(iso_code))
        result = await self._session.execute(stmt)
        return result.scalar_one_or_none() is not None
    
    def _model_to_entity(self, db_country: CountryModel) -> Country:
        """Convert database model to domain entity."""
        return Country(
            id=db_country.id,
            name=db_country.name,
            iso_code=ISOCode(db_country.iso_code),
            is_active=db_country.active,
            created_at=db_country.created_at,
            updated_at=db_country.updated_at
        )
