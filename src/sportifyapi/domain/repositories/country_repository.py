"""Country Repository Interface - Domain Contract."""

from abc import ABC, abstractmethod
from typing import List, Optional

from ..entities.country import Country
from ..value_objects.iso_code import ISOCode


class CountryRepository(ABC):
    """
    Repository interface for Country entity.
    
    This is a DOMAIN contract - it defines what we need from storage
    without knowing HOW it's implemented. The infrastructure layer
    will implement this interface.
    """
    
    @abstractmethod
    async def save(self, country: Country) -> Country:
        """
        Save a country entity.
        
        Args:
            country: Country entity to save
            
        Returns:
            Country: Saved country with populated ID
        """
        pass
    
    @abstractmethod
    async def find_by_id(self, country_id: int) -> Optional[Country]:
        """
        Find country by ID.
        
        Args:
            country_id: Country ID to search for
            
        Returns:
            Country entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    async def find_by_iso_code(self, iso_code: ISOCode) -> Optional[Country]:
        """
        Find country by ISO code.
        
        Args:
            iso_code: ISO code to search for
            
        Returns:
            Country entity if found, None otherwise
        """
        pass
    
    @abstractmethod
    async def find_all(self, active_only: bool = False) -> List[Country]:
        """
        Find all countries.
        
        Args:
            active_only: If True, return only active countries
            
        Returns:
            List of country entities
        """
        pass
    
    @abstractmethod
    async def update(self, country: Country) -> Country:
        """
        Update existing country.
        
        Args:
            country: Country entity to update
            
        Returns:
            Updated country entity
        """
        pass
    
    @abstractmethod
    async def delete(self, country_id: int) -> bool:
        """
        Delete country by ID.
        
        Args:
            country_id: ID of country to delete
            
        Returns:
            True if deleted, False if not found
        """
        pass
    
    @abstractmethod
    async def exists_by_iso_code(self, iso_code: ISOCode) -> bool:
        """
        Check if country exists by ISO code.
        
        Args:
            iso_code: ISO code to check
            
        Returns:
            True if exists, False otherwise
        """
        pass
