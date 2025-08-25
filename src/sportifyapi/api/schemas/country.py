"""Country API Schemas."""

from pydantic import BaseModel, Field, validator
from typing import List


class CountryCreateRequest(BaseModel):
    """Schema for creating a country."""
    
    name: str = Field(
        ..., 
        min_length=2, 
        max_length=100,
        description="Country name (2-100 characters)",
        example="Brazil"
    )
    iso_code: str = Field(
        ..., 
        min_length=2, 
        max_length=2,
        description="ISO-3166-1 alpha-2 country code",
        example="BR"
    )
    
    @validator('name')
    def validate_name(cls, v):
        """Validate country name."""
        if not v.strip():
            raise ValueError("Country name cannot be empty")
        return v.strip()
    
    @validator('iso_code')
    def validate_iso_code(cls, v):
        """Validate ISO code format."""
        v = v.upper().strip()
        if not v.isalpha():
            raise ValueError("ISO code must contain only alphabetic characters")
        return v


class CountryResponse(BaseModel):
    """Schema for country response."""
    
    id: int = Field(..., description="Country ID")
    name: str = Field(..., description="Country name")
    iso_code: str = Field(..., description="ISO country code")
    is_active: bool = Field(..., description="Whether country is active")
    
    class Config:
        """Pydantic configuration."""
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 1,
                "name": "Brazil",
                "iso_code": "BR",
                "is_active": True
            }
        }


class CountryListResponse(BaseModel):
    """Schema for country list response."""
    
    countries: List[CountryResponse] = Field(..., description="List of countries")
    total: int = Field(..., description="Total number of countries")
    message: str = Field(default="Countries retrieved successfully")
    
    class Config:
        """Pydantic configuration."""
        json_schema_extra = {
            "example": {
                "countries": [
                    {
                        "id": 1,
                        "name": "Brazil",
                        "iso_code": "BR",
                        "is_active": True
                    },
                    {
                        "id": 2,
                        "name": "United States",
                        "iso_code": "US",
                        "is_active": True
                    }
                ],
                "total": 2,
                "message": "Countries retrieved successfully"
            }
        }


class CountryCreateResponse(BaseModel):
    """Schema for country creation response."""
    
    id: int = Field(..., description="Created country ID")
    name: str = Field(..., description="Country name")
    iso_code: str = Field(..., description="ISO country code")
    is_active: bool = Field(..., description="Whether country is active")
    message: str = Field(default="Country created successfully")
    
    class Config:
        """Pydantic configuration."""
        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": 1,
                "name": "Brazil",
                "iso_code": "BR",
                "is_active": True,
                "message": "Country created successfully"
            }
        }


class ErrorResponse(BaseModel):
    """Schema for error responses."""
    
    error: str = Field(..., description="Error message")
    detail: str = Field(None, description="Detailed error information")
    
    class Config:
        """Pydantic configuration."""
        json_schema_extra = {
            "example": {
                "error": "Validation error",
                "detail": "Country name cannot be empty"
            }
        }
