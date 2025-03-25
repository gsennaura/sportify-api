# src/sportifyapi/application/use_cases/country/delete_country.py

from typing import Optional
from sportifyapi.domain.entities.country import Country
from sportifyapi.infrastructure.database.unit_of_work import UnitOfWork
from sportifyapi.infrastructure.database.repositories.country_repository import CountryRepository


class DeleteCountryUseCase:
    """Use case to delete a country."""

    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self, country_id: int) -> Optional[Country]:
        country_repo: CountryRepository = self.uow.get_repository(CountryRepository)

        # Check if country exists
        existing = await country_repo.get_by_id(country_id)
        if not existing:
            return None

        return await country_repo.delete(country_id)
