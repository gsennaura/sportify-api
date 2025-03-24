from fastapi import APIRouter, HTTPException, status
from typing import List
from sportifyapi.api.schemas.country_schema import CountryResponse
from sportifyapi.application.use_cases.country.get_country_by_id import GetCountryByIdUseCase
from sportifyapi.application.use_cases.country.get_all_countries import GetAllCountriesUseCase
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
