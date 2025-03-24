from typing import Optional
from sportifyapi.domain.entities.country import Country
from sportifyapi.infrastructure.database.unit_of_work import UnitOfWork
from sportifyapi.infrastructure.database.repositories.country_repository import CountryRepository


class GetCountryByIdUseCase:
    """Use case for retrieving a country by its ID."""

    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self, country_id: int) -> Optional[Country]:
        country_repo: CountryRepository = self.uow.get_repository(CountryRepository)
        return await country_repo.get_by_id(country_id) 
