"""Create Country Use Case."""

from dataclasses import dataclass
from typing import Optional

from ...domain.entities.country import Country
from ...domain.repositories.country_repository import CountryRepository
from ...domain.value_objects.iso_code import ISOCode


@dataclass
class CreateCountryRequest:
    """Request DTO for creating a country."""
    name: str
    iso_code: str


@dataclass
class CreateCountryResponse:
    """Response DTO for country creation."""
    id: int
    name: str
    iso_code: str
    is_active: bool
    message: str = "Country created successfully"


class CreateCountryUseCase:
    """
    Use Case: Create a new country.
    
    Business Rules:
    - Country name must be valid (2-100 characters)
    - ISO code must be valid (2 uppercase letters)
    - ISO code must be unique
    - Country is created as active by default
    """
    
    def __init__(self, country_repository: CountryRepository):
        self._country_repository = country_repository
    
    async def execute(self, request: CreateCountryRequest) -> CreateCountryResponse:
        """
        Execute the create country use case.
        
        Args:
            request: Create country request data
            
        Returns:
            CreateCountryResponse with created country data
            
        Raises:
            ValueError: If business rules are violated
        """
        # 1. Create value objects (validates format)
        iso_code = ISOCode.from_string(request.iso_code)
        
        # 2. Check business rule: ISO code must be unique
        if await self._country_repository.exists_by_iso_code(iso_code):
            raise ValueError(f"Country with ISO code '{iso_code}' already exists")
        
        # 3. Create domain entity (validates business rules)
        country = Country(
            id=None,
            name=request.name,
            iso_code=iso_code,
            is_active=True
        )
        
        # 4. Save through repository
        saved_country = await self._country_repository.save(country)
        
        # 5. Return response DTO
        return CreateCountryResponse(
            id=saved_country.id,
            name=saved_country.name,
            iso_code=str(saved_country.iso_code),
            is_active=saved_country.is_active
        )
