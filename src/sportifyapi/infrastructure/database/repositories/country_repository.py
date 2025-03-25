# src/sportifyapi/infrastructure/database/repositories/country_repository.py

from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.repositories.country_repository_interface import (
    CountryRepositoryInterface,
)
from sportifyapi.infrastructure.database.models.models import Countries as CountryModel
from sportifyapi.infrastructure.database.repositories.base_repository import (
    BaseRepository,
)


class CountryRepository(CountryRepositoryInterface):
    """
    Concrete implementation of the CountryRepositoryInterface using SQLAlchemy.
    """

    def __init__(self, session: AsyncSession):
        self.session = session
        self.base_repo = BaseRepository[CountryModel](CountryModel, session)

    async def get_by_id(self, country_id: int) -> Optional[Country]:
        country_model = await self.base_repo.get_by_id(country_id)
        return self._to_entity(country_model) if country_model else None

    async def get_all(self) -> List[Country]:
        country_models = await self.base_repo.get_all()
        return [self._to_entity(model) for model in country_models]

    async def get_by_iso_code(self, iso_code: str) -> Optional[Country]:
        """
        Retrieve a country by its ISO code.
        """
        stmt = select(CountryModel).where(CountryModel.iso_code == iso_code)
        result = await self.session.execute(stmt)
        model = result.scalar_one_or_none()
        return self._to_entity(model) if model else None

    async def create(self, country: Country) -> Country:
        """
        Persist a new country to the database.
        """
        model = CountryModel(
            id=country.id,
            name=country.name,
            iso_code=country.iso_code,
        )
        created = await self.base_repo.create(model)
        return self._to_entity(created)

    async def delete(self, country_id: int) -> Optional[Country]:
        model = await self.base_repo.get_by_id(country_id)
        if not model:
            return None

        await self.base_repo.delete(country_id)
        return self._to_entity(model)

    async def update(self, country_id: int, update_data: dict) -> Optional[Country]:
        """
        Update an existing country record by ID with the provided fields.
        Returns the updated Country entity or None if not found.
        """
        updated_model = await self.base_repo.update(country_id, update_data)
        return self._to_entity(updated_model) if updated_model else None

    def _to_entity(self, model: CountryModel) -> Country:
        """
        Map SQLAlchemy model to domain entity.
        """
        return Country(
            id=model.id,
            name=model.name,
            iso_code=model.iso_code,
        )

    def _to_model(self, entity: Country) -> CountryModel:
        return CountryModel(
            id=entity.id,
            name=entity.name,
            iso_code=entity.iso_code,
        )