"""Get Country by ID Use Case."""

from dataclasses import dataclass
from typing import Optional

from ....domain.entities.country import Country
from ....domain.repositories.country_repository import CountryRepository


@dataclass
class GetCountryByIdRequest:
    """Request DTO for getting country by ID."""
    country_id: int


@dataclass
class GetCountryByIdResponse:
    """Response DTO for getting country by ID."""
    id: int
    name: str
    iso_code: str
    is_active: bool
    message: str = "Country retrieved successfully"


class GetCountryByIdUseCase:
    """
    Use Case: Get country by ID.
    
    Business Rules:
    - Country must exist
    - Returns country data if found
    """
    
    def __init__(self, country_repository: CountryRepository):
        self._country_repository = country_repository
    
    async def execute(self, request: GetCountryByIdRequest) -> GetCountryByIdResponse:
        """
        Execute the get country by ID use case.
        
        Args:
            request: Get country by ID request data
            
        Returns:
            GetCountryByIdResponse with country data
            
        Raises:
            ValueError: If country not found
        """
        # 1. Find country by ID
        country = await self._country_repository.find_by_id(request.country_id)
        
        # 2. Check if found
        if not country:
            raise ValueError(f"Country with ID {request.country_id} not found")
        
        # 3. Return response DTO
        return GetCountryByIdResponse(
            id=country.id,
            name=country.name,
            iso_code=str(country.iso_code),
            is_active=country.is_active
        )
