from typing import List
from sportifyapi.domain.entities.country import Country
from sportifyapi.infrastructure.database.repositories.country_repository import CountryRepository
from sportifyapi.infrastructure.database.unit_of_work import UnitOfWork


class GetAllCountriesUseCase:
    """Use case for retrieving all countries."""

    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self) -> List[Country]:
        country_repo: CountryRepository = self.uow.get_repository(CountryRepository)
        return await country_repo.get_all()
