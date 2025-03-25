from pydantic import BaseModel, Field, constr
from typing import Optional, List


class CountryCreateRequest(BaseModel):
    name: constr(min_length=2, max_length=100)
    iso_code: constr(min_length=2, max_length=2)


class CountryUpdateRequest(BaseModel):
    name: Optional[constr(min_length=2, max_length=100)] = None
    iso_code: Optional[constr(min_length=2, max_length=2)] = None


class CountryBulkCreateRequest(BaseModel):
    """Schema for bulk creating countries."""

    countries: List[CountryCreateRequest]


class CountryResponse(BaseModel):
    id: int = Field(..., example=1)
    name: str = Field(..., example="Brazil")
    iso_code: str = Field(..., example="BR")

    class Config:
        from_attributes = True
