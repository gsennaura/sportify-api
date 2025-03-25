# tests/unit/use_cases/country/test_create_country.py

import pytest
from sportifyapi.application.use_cases.country.create_country import CreateCountryUseCase
from sportifyapi.domain.entities.country import Country
from sportifyapi.api.schemas.country.country_schema import CountryCreateRequest
from tests.unit.fakes.country.fake_country_repository import FakeCountryRepository
from tests.unit.fakes.country.fake_unit_of_work import FakeUnitOfWork


@pytest.mark.asyncio
async def test_create_country_should_return_created_country():
    # Arrange
    fake_repo = FakeCountryRepository({})
    uow = FakeUnitOfWork(fake_repo)
    use_case = CreateCountryUseCase(uow)
    input_data = CountryCreateRequest(name="Canada", iso_code="CA")

    # Act
    result = await use_case.execute(input_data)

    # Assert
    assert isinstance(result, Country)
    assert result.name == "Canada"
    assert result.iso_code == "CA"