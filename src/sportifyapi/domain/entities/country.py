from dataclasses import dataclass
from typing import Optional


@dataclass
class Country:
    """
    Domain entity representing a country.
    This class contains only domain-related attributes and no ORM or infrastructure concerns.
    """
    id: int
    name: str
    iso_code: str
    region: Optional[str] = None
