# import pytest
# from sportifyapi.application.use_cases.country.create_many_countries import (
#     CreateManyCountriesUseCase,
# )
# from sportifyapi.api.schemas.country.country_schema import CountryCreateRequest
# from tests.unit.fakes.country.fake_country_repository import FakeCountryRepository
# from tests.unit.fakes.country.fake_unit_of_work import FakeUnitOfWork


# @pytest.mark.asyncio
# async def test_create_many_countries_should_return_created_list():
#     # Arrange
#     fake_repo = FakeCountryRepository({})
#     uow = FakeUnitOfWork(fake_repo)
#     use_case = CreateManyCountriesUseCase(uow)

#     input_data = [
#         CountryCreateRequest(name="Brazil", iso_code="BR"),
#         CountryCreateRequest(name="Argentina", iso_code="AR"),
#     ]

#     # Act
#     result = await use_case.execute(input_data)

#     # Assert
#     assert len(result) == 2
#     assert result[0].name == "Brazil"
#     assert result[1].iso_code == "AR"


# @pytest.mark.asyncio
# async def test_create_many_countries_should_return_empty_list():
#     # Arrange
#     fake_repo = FakeCountryRepository({})
#     uow = FakeUnitOfWork(fake_repo)
#     use_case = CreateManyCountriesUseCase(uow)

#     # Act
#     result = await use_case.execute([])

#     # Assert
#     assert result == []
