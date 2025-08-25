"""ISO Country Code Value Object."""

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class ISOCode:
    """
    ISO-3166-1 alpha-2 country code value object.
    
    Examples: BR, US, DE, FR
    
    Business Rules:
    - Must be exactly 2 characters
    - Must be uppercase
    - Must be valid alphabetic characters
    """
    
    value: str
    
    def __post_init__(self) -> None:
        """Validate ISO code format."""
        if not isinstance(self.value, str):
            raise ValueError("ISO code must be a string")
        
        if len(self.value) != 2:
            raise ValueError("ISO code must be exactly 2 characters")
        
        if not self.value.isalpha():
            raise ValueError("ISO code must contain only alphabetic characters")
        
        # Ensure uppercase
        object.__setattr__(self, 'value', self.value.upper())
    
    @classmethod
    def from_string(cls, value: str) -> "ISOCode":
        """Create ISO code from string."""
        return cls(value.upper().strip())
    
    def __str__(self) -> str:
        return self.value
    
    def __eq__(self, other: Any) -> bool:
        if not isinstance(other, ISOCode):
            return False
        return self.value == other.value
    
    def __hash__(self) -> int:
        return hash(self.value)
