# import pytest
# from sportifyapi.application.use_cases.country.delete_country import DeleteCountryUseCase
# from sportifyapi.domain.entities.country import Country
# from tests.unit.fakes.country.fake_country_repository import FakeCountryRepository
# from tests.unit.fakes.country.fake_unit_of_work import FakeUnitOfWork


# @pytest.mark.asyncio
# async def test_delete_country_should_return_deleted_country():
#     # Arrange
#     countries = {
#         1: Country(id=1, name="Brazil", iso_code="BR"),
#     }
#     fake_repo = FakeCountryRepository(countries)
#     uow = FakeUnitOfWork(fake_repo)
#     use_case = DeleteCountryUseCase(uow)

#     # Act
#     result = await use_case.execute(1)

#     # Assert
#     assert result is not None
#     assert result.id == 1
#     assert result.name == "Brazil"


# @pytest.mark.asyncio
# async def test_delete_country_should_return_none_for_nonexistent():
#     # Arrange
#     countries = {
#         1: Country(id=1, name="Brazil", iso_code="BR"),
#     }
#     fake_repo = FakeCountryRepository(countries)
#     uow = FakeUnitOfWork(fake_repo)
#     use_case = DeleteCountryUseCase(uow)

#     # Act
#     result = await use_case.execute(99)

#     # Assert
#     assert result is None
