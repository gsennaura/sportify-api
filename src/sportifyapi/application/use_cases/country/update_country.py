
from typing import Optional
from sportifyapi.domain.entities.country import Country
from sportifyapi.infrastructure.database.unit_of_work import UnitOfWork
from sportifyapi.infrastructure.database.repositories.country_repository import CountryRepository
from sportifyapi.api.schemas.country.country_schema import CountryUpdateRequest


class UpdateCountryUseCase:
    """Use case for updating a country."""

    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self, country_id: int, data: CountryUpdateRequest) -> Optional[Country]:
        country_repo: CountryRepository = self.uow.get_repository(CountryRepository)

        existing = await country_repo.get_by_id(country_id)
        if not existing:
            return None

        update_data = data.model_dump(exclude_unset=True)
        return await country_repo.update(country_id, update_data)
