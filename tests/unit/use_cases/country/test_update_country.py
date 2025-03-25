import pytest
from sportifyapi.application.use_cases.country.update_country import (
    UpdateCountryUseCase,
)
from sportifyapi.domain.entities.country import Country
from tests.unit.fakes.country.fake_country_repository import FakeCountryRepository
from tests.unit.fakes.country.fake_unit_of_work import FakeUnitOfWork


@pytest.mark.asyncio
async def test_update_country_should_return_updated_country():
    # Arrange
    countries = {
        1: Country(id=1, name="Brasil", iso_code="BR"),
    }
    fake_repo = FakeCountryRepository(countries)
    uow = FakeUnitOfWork(fake_repo)
    use_case = UpdateCountryUseCase(uow)

    # Act
    updated_country = Country(id=1, name="Brazil", iso_code="BR")
    result = await use_case.execute(1, updated_country)

    # Assert
    assert result is not None
    assert result.name == "Brazil"
    assert countries[1].name == "Brazil"  # Confirm repo was updated


@pytest.mark.asyncio
async def test_update_country_should_return_none_for_nonexistent():
    # Arrange
    countries = {}
    fake_repo = FakeCountryRepository(countries)
    uow = FakeUnitOfWork(fake_repo)
    use_case = UpdateCountryUseCase(uow)

    # Act
    updated_country = Country(id=99, name="Nowhere", iso_code="XX")
    result = await use_case.execute(99, updated_country)

    # Assert
    assert result is None
