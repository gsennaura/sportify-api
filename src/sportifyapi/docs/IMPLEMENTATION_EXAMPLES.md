# 📝 Implementation Examples - Sportify API

> **Complete code examples for implementing Clean Architecture + DDD + SOLID**
> 
> For the main concepts and theory, see [README.md](./README.md)

## 🏗️ Domain Layer Examples

### Domain Entity
```python
# domain/entities/country.py
from dataclasses import dataclass
from typing import Optional
from ..value_objects.iso_code import ISOCode

@dataclass
class Country:
    id: Optional[int]
    name: str
    iso_code: ISOCode
    is_active: bool = True
    
    def __post_init__(self):
        # 💎 Business invariants
        if len(self.name.strip()) == 0:
            raise ValueError("Country name cannot be empty")
        if not self.iso_code:
            raise ValueError("ISO code is required")
    
    def deactivate(self) -> None:
        """Business method to deactivate country"""
        if not self.is_active:
            raise ValueError("Country is already inactive")
        self.is_active = False
    
    def activate(self) -> None:
        """Business method to activate country"""
        if self.is_active:
            raise ValueError("Country is already active")
        self.is_active = True
```

### Value Object
```python
# domain/value_objects/iso_code.py
from dataclasses import dataclass
import re

@dataclass(frozen=True)
class ISOCode:
    value: str
    
    def __post_init__(self):
        # 💎 Value object validation
        if not isinstance(self.value, str):
            raise ValueError("ISO code must be a string")
        if not re.match(r'^[A-Z]{2}$', self.value):
            raise ValueError(f"Invalid ISO code: {self.value}. Must be 2 uppercase letters.")
    
    def __str__(self) -> str:
        return self.value
```

### Repository Interface
```python
# domain/repositories/country_repository.py
from abc import ABC, abstractmethod
from typing import Optional, List
from ..entities.country import Country
from ..value_objects.iso_code import ISOCode

class CountryRepository(ABC):
    """Business-focused interface - what the domain needs"""
    
    @abstractmethod
    async def get_by_id(self, id: int) -> Optional[Country]:
        """Get country by ID"""
        pass
    
    @abstractmethod
    async def get_by_iso_code(self, iso_code: ISOCode) -> Optional[Country]:
        """Get country by ISO code - business-specific query"""
        pass
    
    @abstractmethod
    async def find_active_countries(self) -> List[Country]:
        """Find all active countries - business logic"""
        pass
    
    @abstractmethod
    async def add(self, country: Country) -> Country:
        """Add new country"""
        pass
    
    @abstractmethod
    async def update(self, country: Country) -> Country:
        """Update existing country"""
        pass
    
    @abstractmethod
    async def remove(self, country: Country) -> None:
        """Remove country"""
        pass
```

### Unit of Work Interface
```python
# domain/uow.py
from typing import Protocol
from .repositories.country_repository import CountryRepository

class UnitOfWork(Protocol):
    """Transaction boundary interface"""
    countries: CountryRepository
    
    async def commit(self) -> None:
        """Commit all changes"""
        pass
    
    async def rollback(self) -> None:
        """Rollback all changes"""
        pass
    
    async def close(self) -> None:
        """Close the unit of work"""
        pass
```

## 🎯 Application Layer Examples

### Use Case
```python
# application/use_cases/country/create_country.py
from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.value_objects.iso_code import ISOCode
from sportifyapi.domain.uow import UnitOfWork

class CreateCountryUseCase:
    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self, name: str, iso_code: str) -> Country:
        # 🔍 Input validation & transformation
        iso = ISOCode(iso_code.upper())
        
        # 💎 Business rule enforcement
        existing = await self.uow.countries.get_by_iso_code(iso)
        if existing:
            raise ValueError(f"Country with ISO {iso_code} already exists")
        
        # 💎 Create domain entity
        country = Country(id=None, name=name.strip(), iso_code=iso)
        
        # 🔧 Save via repository abstraction
        saved_country = await self.uow.countries.add(country)
        await self.uow.commit()
        
        return saved_country
```

```python
# application/use_cases/country/get_countries.py
from typing import List
from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.uow import UnitOfWork

class GetActiveCountriesUseCase:
    def __init__(self, uow: UnitOfWork):
        self.uow = uow

    async def execute(self) -> List[Country]:
        """Get all active countries"""
        return await self.uow.countries.find_active_countries()
```

### Application Service
```python
# application/services/country_service.py
from typing import List
from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.value_objects.iso_code import ISOCode
from sportifyapi.domain.uow import UnitOfWork

class CountryService:
    """Complex business workflows"""
    
    def __init__(self, uow: UnitOfWork):
        self.uow = uow
    
    async def bulk_create_countries(self, countries_data: List[dict]) -> List[Country]:
        """Create multiple countries in a single transaction"""
        created_countries = []
        
        for data in countries_data:
            iso = ISOCode(data['iso_code'].upper())
            
            # Check if already exists
            existing = await self.uow.countries.get_by_iso_code(iso)
            if existing:
                continue  # Skip existing
            
            country = Country(
                id=None,
                name=data['name'].strip(),
                iso_code=iso
            )
            
            saved = await self.uow.countries.add(country)
            created_countries.append(saved)
        
        await self.uow.commit()
        return created_countries
```

## 🌐 API Layer Examples

### Pydantic Schemas
```python
# api/schemas/country.py
from pydantic import BaseModel, Field, validator
from typing import Optional

class CountryCreateRequest(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    iso_code: str = Field(..., min_length=2, max_length=2)
    
    @validator('name')
    def name_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()
    
    @validator('iso_code')
    def iso_code_must_be_uppercase(cls, v):
        return v.upper()

class CountryResponse(BaseModel):
    id: int
    name: str
    iso_code: str
    is_active: bool
    
    @classmethod
    def from_entity(cls, country) -> 'CountryResponse':
        """Convert domain entity to response"""
        return cls(
            id=country.id,
            name=country.name,
            iso_code=country.iso_code.value,
            is_active=country.is_active
        )

class CountryUpdateRequest(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    is_active: Optional[bool] = None
```

### API Controller
```python
# api/controllers/countries.py
from fastapi import APIRouter, Depends, HTTPException, status
from typing import List

from ..schemas.country import CountryCreateRequest, CountryResponse
from ..deps import get_unit_of_work
from ...application.use_cases.country.create_country import CreateCountryUseCase
from ...application.use_cases.country.get_countries import GetActiveCountriesUseCase

router = APIRouter(prefix="/countries", tags=["countries"])

@router.post("/", response_model=CountryResponse, status_code=status.HTTP_201_CREATED)
async def create_country(
    request: CountryCreateRequest,
    uow=Depends(get_unit_of_work)
):
    """Create a new country"""
    try:
        use_case = CreateCountryUseCase(uow)
        country = await use_case.execute(request.name, request.iso_code)
        return CountryResponse.from_entity(country)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

@router.get("/", response_model=List[CountryResponse])
async def get_active_countries(uow=Depends(get_unit_of_work)):
    """Get all active countries"""
    use_case = GetActiveCountriesUseCase(uow)
    countries = await use_case.execute()
    return [CountryResponse.from_entity(country) for country in countries]

@router.get("/{country_id}", response_model=CountryResponse)
async def get_country_by_id(
    country_id: int,
    uow=Depends(get_unit_of_work)
):
    """Get country by ID"""
    country = await uow.countries.get_by_id(country_id)
    if not country:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Country with ID {country_id} not found"
        )
    return CountryResponse.from_entity(country)
```

## 🔧 Infrastructure Layer Examples

### SQLAlchemy Models
```python
# infrastructure/database/models/__init__.py
from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
    pass
```

```python
# infrastructure/database/models/country.py
from sqlalchemy import Integer, String, Boolean, DateTime
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func
from . import Base

class CountryModel(Base):
    __tablename__ = "countries"
    
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    iso_code: Mapped[str] = mapped_column(String(2), unique=True, nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    created_at: Mapped[DateTime] = mapped_column(DateTime, server_default=func.now())
    updated_at: Mapped[DateTime] = mapped_column(DateTime, server_default=func.now(), onupdate=func.now())
```

### Entity Mapper
```python
# infrastructure/database/mappers/country_mapper.py
from typing import Optional
from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.value_objects.iso_code import ISOCode
from ..models.country import CountryModel

class CountryMapper:
    """Converts between domain entities and database models"""
    
    def to_entity(self, model: Optional[CountryModel]) -> Optional[Country]:
        """Convert database model to domain entity"""
        if not model:
            return None
        
        return Country(
            id=model.id,
            name=model.name,
            iso_code=ISOCode(model.iso_code),
            is_active=model.is_active
        )

    def to_model(self, entity: Country) -> CountryModel:
        """Convert domain entity to database model"""
        return CountryModel(
            id=entity.id,
            name=entity.name,
            iso_code=entity.iso_code.value,
            is_active=entity.is_active
        )
```

### Base Repository
```python
# infrastructure/database/repositories/base_repository.py
from typing import Generic, TypeVar, Optional, List, Type
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete

TModel = TypeVar("TModel")
TEntity = TypeVar("TEntity")

class BaseRepository(Generic[TModel, TEntity]):
    """Generic CRUD operations - infrastructure detail"""
    
    def __init__(
        self,
        session: AsyncSession,
        model_class: Type[TModel],
        mapper: 'EntityMapper[TModel, TEntity]'
    ):
        self.session = session
        self.model_class = model_class
        self.mapper = mapper

    async def _get_by_id(self, id: int) -> Optional[TEntity]:
        """Protected method - only for inheritance"""
        stmt = select(self.model_class).where(self.model_class.id == id)
        result = await self.session.execute(stmt)
        model = result.scalar_one_or_none()
        return self.mapper.to_entity(model) if model else None

    async def _add(self, entity: TEntity) -> TEntity:
        """Protected method - only for inheritance"""
        model = self.mapper.to_model(entity)
        self.session.add(model)
        await self.session.flush()
        await self.session.refresh(model)
        return self.mapper.to_entity(model)

    async def _update(self, entity: TEntity) -> TEntity:
        """Protected method - only for inheritance"""
        model = self.mapper.to_model(entity)
        await self.session.merge(model)
        await self.session.flush()
        await self.session.refresh(model)
        return self.mapper.to_entity(model)

    async def _list_all(self) -> List[TEntity]:
        """Protected method - only for inheritance"""
        stmt = select(self.model_class)
        result = await self.session.execute(stmt)
        models = result.scalars().all()
        return [self.mapper.to_entity(model) for model in models]
```

### Repository Implementation
```python
# infrastructure/database/repositories/country_repository.py
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from sportifyapi.domain.repositories.country_repository import CountryRepository
from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.value_objects.iso_code import ISOCode

from .base_repository import BaseRepository
from ..models.country import CountryModel
from ..mappers.country_mapper import CountryMapper

class SQLAlchemyCountryRepository(CountryRepository):
    """Implements business interface using generic base"""
    
    def __init__(self, session: AsyncSession):
        self.session = session
        self.mapper = CountryMapper()
        # 🔧 Composition, not inheritance
        self._base = BaseRepository(session, CountryModel, self.mapper)

    # 🔄 Delegate common operations to base
    async def get_by_id(self, id: int) -> Optional[Country]:
        return await self._base._get_by_id(id)

    async def add(self, country: Country) -> Country:
        return await self._base._add(country)

    async def update(self, country: Country) -> Country:
        return await self._base._update(country)

    async def remove(self, country: Country) -> None:
        if not country.id:
            raise ValueError("Cannot remove country without ID")
        
        stmt = delete(CountryModel).where(CountryModel.id == country.id)
        await self.session.execute(stmt)

    # 💎 Custom business operations
    async def get_by_iso_code(self, iso_code: ISOCode) -> Optional[Country]:
        stmt = select(CountryModel).where(CountryModel.iso_code == iso_code.value)
        result = await self.session.execute(stmt)
        model = result.scalar_one_or_none()
        return self.mapper.to_entity(model)

    async def find_active_countries(self) -> List[Country]:
        stmt = select(CountryModel).where(CountryModel.is_active == True)
        result = await self.session.execute(stmt)
        models = result.scalars().all()
        return [self.mapper.to_entity(model) for model in models]
```

### Unit of Work Implementation
```python
# infrastructure/database/unit_of_work.py
from contextlib import asynccontextmanager
from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession

from sportifyapi.domain.uow import UnitOfWork as UoWProtocol
from .repositories.country_repository import SQLAlchemyCountryRepository

class UnitOfWork(UoWProtocol):
    def __init__(self, session: AsyncSession):
        self.session = session
        self.countries = SQLAlchemyCountryRepository(session)

    async def commit(self):
        await self.session.commit()

    async def rollback(self):
        await self.session.rollback()

    async def close(self):
        await self.session.close()
```

## ⚙️ Configuration Examples

### Pydantic Settings
```python
# core/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    # Database
    database_url: str
    database_echo: bool = False
    
    # API
    api_title: str = "Sportify API"
    api_version: str = "0.1.0"
    api_prefix: str = "/api/v1"
    
    # Security
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Environment
    environment: str = "development"
    debug: bool = False
    
    class Config:
        env_file = ".env"
        case_sensitive = False

@lru_cache()
def get_settings() -> Settings:
    return Settings()
```

### Database Configuration
```python
# core/database.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from typing import AsyncGenerator
from .config import get_settings

settings = get_settings()

# Create async engine
engine = create_async_engine(
    settings.database_url,
    echo=settings.database_echo,
    future=True
)

# Create session maker
AsyncSessionLocal = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

async def get_session() -> AsyncGenerator[AsyncSession, None]:
    """Dependency to get database session"""
    async with AsyncSessionLocal() as session:
        try:
            yield session
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

### Dependency Injection
```python
# api/deps.py
from contextlib import asynccontextmanager
from typing import AsyncGenerator
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.database import get_session
from ..infrastructure.database.unit_of_work import UnitOfWork

@asynccontextmanager
async def get_unit_of_work() -> AsyncGenerator[UnitOfWork, None]:
    async for session in get_session():
        uow = UnitOfWork(session)
        try:
            yield uow
        except Exception:
            await uow.rollback()
            raise
        finally:
            await uow.close()
```

## 🧪 Testing Examples

### Fake Repository for Testing
```python
# tests/fakes/fake_country_repository.py
from typing import Dict, Optional, List
from sportifyapi.domain.repositories.country_repository import CountryRepository
from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.value_objects.iso_code import ISOCode

class FakeCountryRepository(CountryRepository):
    def __init__(self):
        self._countries: Dict[int, Country] = {}
        self._next_id = 1

    async def get_by_id(self, id: int) -> Optional[Country]:
        return self._countries.get(id)

    async def get_by_iso_code(self, iso_code: ISOCode) -> Optional[Country]:
        for country in self._countries.values():
            if country.iso_code.value == iso_code.value:
                return country
        return None

    async def find_active_countries(self) -> List[Country]:
        return [c for c in self._countries.values() if c.is_active]

    async def add(self, country: Country) -> Country:
        country.id = self._next_id
        self._countries[self._next_id] = country
        self._next_id += 1
        return country

    async def update(self, country: Country) -> Country:
        if country.id and country.id in self._countries:
            self._countries[country.id] = country
            return country
        raise ValueError("Country not found")

    async def remove(self, country: Country) -> None:
        if country.id and country.id in self._countries:
            del self._countries[country.id]
        else:
            raise ValueError("Country not found")
```

### Fake Unit of Work
```python
# tests/fakes/fake_unit_of_work.py
from sportifyapi.domain.uow import UnitOfWork
from .fake_country_repository import FakeCountryRepository

class FakeUnitOfWork(UnitOfWork):
    def __init__(self):
        self.countries = FakeCountryRepository()
        self._committed = False

    async def commit(self) -> None:
        self._committed = True

    async def rollback(self) -> None:
        pass

    async def close(self) -> None:
        pass

    @property
    def committed(self) -> bool:
        return self._committed
```

### Unit Tests
```python
# tests/unit/use_cases/test_create_country.py
import pytest
from sportifyapi.application.use_cases.country.create_country import CreateCountryUseCase
from sportifyapi.domain.value_objects.iso_code import ISOCode
from tests.fakes.fake_unit_of_work import FakeUnitOfWork

@pytest.mark.asyncio
async def test_create_country_success():
    # Given
    uow = FakeUnitOfWork()
    use_case = CreateCountryUseCase(uow)
    
    # When
    country = await use_case.execute("Brazil", "BR")
    
    # Then
    assert country.name == "Brazil"
    assert country.iso_code.value == "BR"
    assert country.is_active is True
    assert country.id is not None
    assert uow.committed

@pytest.mark.asyncio
async def test_create_country_duplicate_iso():
    # Given
    uow = FakeUnitOfWork()
    use_case = CreateCountryUseCase(uow)
    await use_case.execute("Brazil", "BR")  # First country
    
    # When/Then
    with pytest.raises(ValueError, match="already exists"):
        await use_case.execute("Brasil", "BR")  # Duplicate ISO

@pytest.mark.asyncio
async def test_create_country_invalid_iso():
    # Given
    uow = FakeUnitOfWork()
    use_case = CreateCountryUseCase(uow)
    
    # When/Then
    with pytest.raises(ValueError, match="Invalid ISO code"):
        await use_case.execute("Brazil", "BRA")  # 3 letters
```

### Integration Tests
```python
# tests/integration/test_country_repository.py
import pytest
from sqlalchemy.ext.asyncio import AsyncSession
from sportifyapi.infrastructure.database.repositories.country_repository import SQLAlchemyCountryRepository
from sportifyapi.domain.entities.country import Country
from sportifyapi.domain.value_objects.iso_code import ISOCode

@pytest.mark.asyncio
async def test_country_repository_add_and_get(db_session: AsyncSession):
    # Given
    repo = SQLAlchemyCountryRepository(db_session)
    country = Country(id=None, name="Brazil", iso_code=ISOCode("BR"))
    
    # When
    saved_country = await repo.add(country)
    await db_session.commit()
    
    retrieved_country = await repo.get_by_id(saved_country.id)
    
    # Then
    assert retrieved_country is not None
    assert retrieved_country.name == "Brazil"
    assert retrieved_country.iso_code.value == "BR"
    assert retrieved_country.is_active is True
```

---

**This file contains all the implementation patterns you need to build your Clean Architecture application. Each example shows the proper separation of concerns and follows the dependency rule.** 🚀
