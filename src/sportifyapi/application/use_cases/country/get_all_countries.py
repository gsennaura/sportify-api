"""Get All Countries Use Case."""

from dataclasses import dataclass
from typing import List

from ...domain.entities.country import Country
from ...domain.repositories.country_repository import CountryRepository


@dataclass
class GetAllCountriesRequest:
    """Request DTO for getting all countries."""
    active_only: bool = False


@dataclass
class CountryDTO:
    """Country data transfer object."""
    id: int
    name: str
    iso_code: str
    is_active: bool


@dataclass
class GetAllCountriesResponse:
    """Response DTO for getting all countries."""
    countries: List[CountryDTO]
    total: int
    message: str = "Countries retrieved successfully"


class GetAllCountriesUseCase:
    """
    Use Case: Get all countries.
    
    Business Rules:
    - Can filter by active status
    - Returns all countries if no filter applied
    """
    
    def __init__(self, country_repository: CountryRepository):
        self._country_repository = country_repository
    
    async def execute(self, request: GetAllCountriesRequest) -> GetAllCountriesResponse:
        """
        Execute the get all countries use case.
        
        Args:
            request: Get all countries request data
            
        Returns:
            GetAllCountriesResponse with list of countries
        """
        # 1. Get countries from repository
        countries = await self._country_repository.find_all(active_only=request.active_only)
        
        # 2. Convert to DTOs
        country_dtos = [
            CountryDTO(
                id=country.id,
                name=country.name,
                iso_code=str(country.iso_code),
                is_active=country.is_active
            )
            for country in countries
        ]
        
        # 3. Return response
        return GetAllCountriesResponse(
            countries=country_dtos,
            total=len(country_dtos)
        )
