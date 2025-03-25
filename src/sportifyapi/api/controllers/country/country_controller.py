from fastapi import APIRouter, HTTPException, status
from typing import List
from sportifyapi.api.schemas.country.country_schema import (
    CountryResponse,
    CountryCreateRequest,
    CountryUpdateRequest,
    CountryBulkCreateRequest,
)
from sportifyapi.application.use_cases.country.get_country_by_id import (
    GetCountryByIdUseCase,
)
from sportifyapi.application.use_cases.country.get_all_countries import (
    GetAllCountriesUseCase,
)
from sportifyapi.application.use_cases.country.create_country import (
    CreateCountryUseCase,
)
from sportifyapi.application.use_cases.country.delete_country import (
    DeleteCountryUseCase,
)
from sportifyapi.application.use_cases.country.update_country import (
    UpdateCountryUseCase,
)
from sportifyapi.application.use_cases.country.create_many_countries import (
    CreateManyCountriesUseCase,
)


from sportifyapi.infrastructure.database.unit_of_work import get_unit_of_work


router = APIRouter(prefix="/countries", tags=["Countries"])


@router.get("/", response_model=List[CountryResponse])
async def get_all_countries():
    async with get_unit_of_work() as uow:
        use_case = GetAllCountriesUseCase(uow)
        return await use_case.execute()


@router.get("/{country_id}", response_model=CountryResponse)
async def get_country_by_id(country_id: int):
    async with get_unit_of_work() as uow:
        use_case = GetCountryByIdUseCase(uow)
        country = await use_case.execute(country_id)

        if not country:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Country not found",
            )

        return country


@router.post("/", response_model=CountryResponse, status_code=status.HTTP_201_CREATED)
async def create_country(payload: CountryCreateRequest):
    async with get_unit_of_work() as uow:
        use_case = CreateCountryUseCase(uow)
        country = await use_case.execute(name=payload.name, iso_code=payload.iso_code)

        if not country:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Country with this ISO code already exists",
            )

        return country


@router.delete("/{country_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_country(country_id: int):
    async with get_unit_of_work() as uow:
        use_case = DeleteCountryUseCase(uow)
        deleted = await use_case.execute(country_id)

        if not deleted:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND, detail="Country not found"
            )


@router.put("/{country_id}", response_model=CountryResponse)
async def update_country(
    country_id: int,
    data: CountryUpdateRequest,
):
    async with get_unit_of_work() as uow:
        use_case = UpdateCountryUseCase(uow)
        updated = await use_case.execute(country_id, data)

        if not updated:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Country not found",
            )

        return updated


@router.post("/bulk", response_model=List[CountryResponse])
async def create_countries_bulk(request: CountryBulkCreateRequest):
    async with get_unit_of_work() as uow:
        use_case = CreateManyCountriesUseCase(uow)
        return await use_case.execute(request.countries)
