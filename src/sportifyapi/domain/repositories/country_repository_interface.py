from abc import ABC, abstractmethod
from typing import Optional, List
from sportifyapi.domain.entities.country import Country


class CountryRepositoryInterface(ABC):
    """
    Abstract repository interface for Country entity.
    Concrete implementations should inherit from this class.
    """

    @abstractmethod
    async def get_by_id(self, country_id: int) -> Optional[Country]:
        """Retrieve a Country by its ID."""
        pass

    @abstractmethod
    async def get_all(self) -> List[Country]:
        """Retrieve all countries."""
        pass

    @abstractmethod
    async def create(self, country: Country) -> Country:
        """Create and persist a new Country."""
        pass
