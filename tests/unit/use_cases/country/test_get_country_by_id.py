# import pytest
# from sportifyapi.application.use_cases.country.get_country_by_id import (
#     GetCountryByIdUseCase,
# )
# from tests.unit.fakes.country.fake_country_repository import FakeCountryRepository
# from tests.unit.fakes.country.fake_unit_of_work import FakeUnitOfWork
# from sportifyapi.domain.entities.country import Country


# @pytest.mark.asyncio
# async def test_get_country_by_id_should_return_country():
#     # Arrange
#     countries = {
#         1: Country(id=1, name="Brazil", iso_code="BR"),
#         2: Country(id=2, name="Argentina", iso_code="AR"),
#     }
#     fake_repo = FakeCountryRepository(countries)
#     uow = FakeUnitOfWork(fake_repo)
#     use_case = GetCountryByIdUseCase(uow)

#     # Act
#     result = await use_case.execute(1)

#     # Assert
#     assert result is not None
#     assert result.id == 1
#     assert result.name == "Brazil"
#     assert result.iso_code == "BR"


# @pytest.mark.asyncio
# async def test_get_country_by_id_should_return_none_for_nonexistent():
#     # Arrange
#     countries = {
#         1: Country(id=1, name="Brazil", iso_code="BR"),
#     }
#     fake_repo = FakeCountryRepository(countries)
#     uow = FakeUnitOfWork(fake_repo)
#     use_case = GetCountryByIdUseCase(uow)

#     # Act
#     result = await use_case.execute(99)

#     # Assert
#     assert result is None
