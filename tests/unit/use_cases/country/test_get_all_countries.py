# import pytest
# from typing import Dict
# from sportifyapi.application.use_cases.country.get_all_countries import (
#     GetAllCountriesUseCase,
# )
# from tests.unit.fakes.country.fake_country_repository import FakeCountryRepository
# from tests.unit.fakes.country.fake_unit_of_work import FakeUnitOfWork
# from sportifyapi.domain.entities.country import Country


# @pytest.mark.asyncio
# async def test_get_all_countries_should_return_all():
#     # Arrange
#     countries: Dict[int, Country] = {
#         1: Country(id=1, name="Brazil", iso_code="BR"),
#         2: Country(id=2, name="Argentina", iso_code="AR"),
#         3: Country(id=3, name="Chile", iso_code="CL"),
#     }
#     fake_repo = FakeCountryRepository(countries)
#     uow = FakeUnitOfWork(fake_repo)
#     use_case = GetAllCountriesUseCase(uow)

#     # Act
#     result = await use_case.execute()

#     # Assert
#     assert isinstance(result, list)
#     assert len(result) == 3
#     assert any(c.name == "Brazil" for c in result)
#     assert any(c.iso_code == "AR" for c in result)


# @pytest.mark.asyncio
# async def test_get_all_countries_should_return_empty_list():
#     # Arrange
#     fake_repo = FakeCountryRepository({})
#     uow = FakeUnitOfWork(fake_repo)
#     use_case = GetAllCountriesUseCase(uow)

#     # Act
#     result = await use_case.execute()

#     # Assert
#     assert result == []