from pydantic import BaseModel, Field


class CountryResponse(BaseModel):
    """Schema for returning country data via API."""
    id: int = Field(..., example=1)
    name: str = Field(..., example="Brazil")
    iso_code: str = Field(..., example="BR")

    class Config:
        from_attributes = True  # Required to work with ORM objects