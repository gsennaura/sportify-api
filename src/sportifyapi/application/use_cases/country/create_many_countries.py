from typing import List
from sportifyapi.domain.entities.country import Country
from sportifyapi.infrastructure.database.unit_of_work import UnitOfWork
from sportifyapi.infrastructure.database.repositories.country_repository import (
    CountryRepository,
)
from sportifyapi.api.schemas.country.country_schema import CountryCreateRequest


class CreateManyCountriesUseCase:
    """Use case for creating multiple countries in a single transaction."""

    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self, input_data: List[CountryCreateRequest]) -> List[Country]:
        countries = [
            Country(id=None, name=c.name, iso_code=c.iso_code) for c in input_data
        ]
        country_repo: CountryRepository = self.uow.get_repository(CountryRepository)

        # Persist entities without committing yet
        await country_repo.base_repo.create_many_deferred(
            [country_repo._to_model(country) for country in countries]
        )

        # UnitOfWork will commit at context manager exit
        return countries
