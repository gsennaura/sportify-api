"""Country Domain Entity."""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional

from ..value_objects.iso_code import ISOCode


@dataclass
class Country:
    """
    Country Domain Entity.
    
    Represents a country in the sports management system.
    Contains business rules and invariants that must always be true.
    """
    
    id: Optional[int]
    name: str
    iso_code: ISOCode
    is_active: bool = True
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    
    def __post_init__(self) -> None:
        """Validate country business rules."""
        self._validate_name()
    
    def _validate_name(self) -> None:
        """Validate country name business rules."""
        if not self.name or not self.name.strip():
            raise ValueError("Country name cannot be empty")
        
        if len(self.name.strip()) < 2:
            raise ValueError("Country name must be at least 2 characters")
        
        if len(self.name.strip()) > 100:
            raise ValueError("Country name cannot exceed 100 characters")
        
        # Clean the name
        self.name = self.name.strip()
    
    def activate(self) -> None:
        """Activate the country."""
        self.is_active = True
    
    def deactivate(self) -> None:
        """Deactivate the country."""
        self.is_active = False
    
    def update_name(self, new_name: str) -> None:
        """Update country name with validation."""
        old_name = self.name
        self.name = new_name
        try:
            self._validate_name()
        except ValueError:
            # Rollback on validation error
            self.name = old_name
            raise
    
    def is_same_country(self, other: "Country") -> bool:
        """Check if this is the same country (by ISO code)."""
        if not isinstance(other, Country):
            return False
        return self.iso_code == other.iso_code
    
    def __eq__(self, other) -> bool:
        """Countries are equal if they have the same ISO code."""
        if not isinstance(other, Country):
            return False
        return self.iso_code == other.iso_code
    
    def __hash__(self) -> int:
        """Hash based on ISO code for use in sets/dicts."""
        return hash(self.iso_code)
    
    def __str__(self) -> str:
        """String representation."""
        return f"{self.name} ({self.iso_code})"
    
    def __repr__(self) -> str:
        """Detailed representation."""
        return (
            f"Country(id={self.id}, name='{self.name}', "
            f"iso_code={self.iso_code}, is_active={self.is_active})"
        )
