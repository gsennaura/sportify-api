from typing import Optional
from sportifyapi.domain.entities.country import Country
from sportifyapi.infrastructure.database.unit_of_work import UnitOfWork
from sportifyapi.infrastructure.database.repositories.country_repository import CountryRepository


class CreateCountryUseCase:
    """Use case to create a new country."""

    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self, name: str, iso_code: str) -> Optional[Country]:
        country_repo: CountryRepository = self.uow.get_repository(CountryRepository)

        # Check if country already exists
        existing = await country_repo.get_by_iso_code(iso_code)
        if existing:
            return None

        country = Country(id=None, name=name, iso_code=iso_code)
        return await country_repo.create(country)
