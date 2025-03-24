# src/sportifyapi/infrastructure/database/repositories/country_repository.py

from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession

from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.repositories.country_repository_interface import CountryRepositoryInterface
from sportifyapi.infrastructure.database.models.models import Countries as CountryModel
from sportifyapi.infrastructure.database.repositories.base_repository import BaseRepository


class CountryRepository(CountryRepositoryInterface):
    """
    Concrete implementation of the CountryRepositoryInterface using SQLAlchemy.
    """

    def __init__(self, session: AsyncSession):
        self.session = session
        self.base_repo = BaseRepository[CountryModel](CountryModel, session)

    async def get_by_id(self, country_id: int) -> Optional[Country]:
        model = await self.base_repo.get_by_id(country_id)
        return self._to_entity(model) if model else None

    async def get_all(self) -> List[Country]:
        models = await self.base_repo.get_all()
        return [self._to_entity(m) for m in models]

    async def create(self, country: Country) -> Country:
        model = CountryModel(
            id=country.id,
            name=country.name,
            iso_code=country.iso_code,
        )
        saved = await self.base_repo.create(model)
        return self._to_entity(saved)

    def _to_entity(self, model: CountryModel) -> Country:
        return Country(
            id=model.id,
            name=model.name,
            iso_code=model.iso_code,
        )
