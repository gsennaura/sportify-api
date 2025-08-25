"""Country API Controller."""

from fastapi import APIRouter, Depends, HTTPException, status
from typing import List

from ...application.use_cases.country.create_country import (
    CreateCountryUseCase, 
    CreateCountryRequest
)
from ...application.use_cases.country.get_all_countries import (
    GetAllCountriesUseCase, 
    GetAllCountriesRequest
)
from ...application.use_cases.country.get_country_by_id import (
    GetCountryByIdUseCase, 
    GetCountryByIdRequest
)
from ..schemas.country import (
    CountryCreateRequest,
    CountryCreateResponse,
    CountryResponse,
    CountryListResponse,
    ErrorResponse
)
from ..deps import get_country_repository

router = APIRouter(prefix="/countries", tags=["Countries"])


@router.post(
    "/",
    response_model=CountryCreateResponse,
    status_code=status.HTTP_201_CREATED,
    responses={
        400: {"model": ErrorResponse, "description": "Bad Request"},
        409: {"model": ErrorResponse, "description": "Country already exists"}
    },
    summary="Create a new country",
    description="Create a new country with name and ISO code. ISO code must be unique."
)
async def create_country(
    request: CountryCreateRequest,
    country_repository=Depends(get_country_repository)
) -> CountryCreateResponse:
    """
    Create a new country.
    
    - **name**: Country name (2-100 characters)
    - **iso_code**: ISO-3166-1 alpha-2 code (2 letters, e.g., BR, US)
    
    Returns the created country with assigned ID.
    """
    try:
        # Create use case
        use_case = CreateCountryUseCase(country_repository)
        
        # Convert API request to use case request
        use_case_request = CreateCountryRequest(
            name=request.name,
            iso_code=request.iso_code
        )
        
        # Execute use case
        response = await use_case.execute(use_case_request)
        
        # Convert use case response to API response
        return CountryCreateResponse(
            id=response.id,
            name=response.name,
            iso_code=response.iso_code,
            is_active=response.is_active,
            message=response.message
        )
        
    except ValueError as e:
        # Business rule violation
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        # Unexpected error
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get(
    "/",
    response_model=CountryListResponse,
    responses={
        200: {"model": CountryListResponse, "description": "Countries retrieved successfully"}
    },
    summary="Get all countries",
    description="Retrieve all countries. Optionally filter by active status."
)
async def get_all_countries(
    active_only: bool = False,
    country_repository=Depends(get_country_repository)
) -> CountryListResponse:
    """
    Get all countries.
    
    - **active_only**: If true, return only active countries
    
    Returns list of countries with total count.
    """
    try:
        # Create use case
        use_case = GetAllCountriesUseCase(country_repository)
        
        # Create request
        use_case_request = GetAllCountriesRequest(active_only=active_only)
        
        # Execute use case
        response = await use_case.execute(use_case_request)
        
        # Convert use case response to API response
        countries = [
            CountryResponse(
                id=country.id,
                name=country.name,
                iso_code=country.iso_code,
                is_active=country.is_active
            )
            for country in response.countries
        ]
        
        return CountryListResponse(
            countries=countries,
            total=response.total,
            message=response.message
        )
        
    except Exception as e:
        # Unexpected error
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )


@router.get(
    "/{country_id}",
    response_model=CountryResponse,
    responses={
        200: {"model": CountryResponse, "description": "Country retrieved successfully"},
        404: {"model": ErrorResponse, "description": "Country not found"}
    },
    summary="Get country by ID",
    description="Retrieve a specific country by its ID."
)
async def get_country_by_id(
    country_id: int,
    country_repository=Depends(get_country_repository)
) -> CountryResponse:
    """
    Get country by ID.
    
    - **country_id**: ID of the country to retrieve
    
    Returns the country data.
    """
    try:
        # Create use case
        use_case = GetCountryByIdUseCase(country_repository)
        
        # Create request
        use_case_request = GetCountryByIdRequest(country_id=country_id)
        
        # Execute use case
        response = await use_case.execute(use_case_request)
        
        # Convert use case response to API response
        return CountryResponse(
            id=response.id,
            name=response.name,
            iso_code=response.iso_code,
            is_active=response.is_active
        )
        
    except ValueError as e:
        # Country not found
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e)
        )
    except Exception as e:
        # Unexpected error
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )
