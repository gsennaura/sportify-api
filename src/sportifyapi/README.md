# 🏆 Sportify API – Clean Architecture + DDD + SOLID

> **A sports management API built the right way** – using industry best practices that make code maintainable, testable, and scalable.
>
> 📖 **Learning Resources:**
> - 🛠️ [Implementation Examples & Code Patterns](./docs/IMPLEMENTATION_EXAMPLES.md)
> - 🗃️ [Database Migrations with Alembic - Step by Step Guide](./docs/ALEMBIC_GUIDE.md)
> - 🏗️ [Country Entity - Complete Implementation Walkthrough](./docs/COUNTRY_IMPLEMENTATION.md)

## 🎯 What Are We Building?

A **sports management API** that handles federations, clubs, and people. But more importantly, we're building it **the right way** – using Clean Architecture, Domain-Driven Design, and SOLID principles.

## 🤔 Why This Architecture?

### The Problem with "Quick & Dirty" Code
Most projects start simple but become nightmares:
- Business logic mixed with database code
- Cannot test without spinning up the entire system
- Changing one thing breaks three others
- Adding new features becomes increasingly difficult

### Our Solution: Clean Architecture + DDD + SOLID

**Think of it like building a house:**
- **Domain** = The foundation (your business rules)
- **Application** = The rooms (your use cases)
- **API** = The front door (how users interact)
- **Infrastructure** = The plumbing (databases, external services)

**Key Benefits:**
- ✅ **Testable**: Test business logic without databases
- ✅ **Flexible**: Swap PostgreSQL for MongoDB tomorrow
- ✅ **Maintainable**: Changes are isolated and predictable
- ✅ **Scalable**: Add new features without breaking existing ones

## 📚 Core Principles

### 🏗️ Clean Architecture: The Dependency Rule
> **"Dependencies point inward, never outward"**

This means your business rules don't know about databases or web frameworks. They just know about... business.

### 🎭 Domain-Driven Design (DDD): Speaking Business Language
> **"The code should reflect how business people think and talk"**

Instead of "UserTable" we have "Person". Instead of "CRUD operations" we have "RegisterAthlete" or "TransferPlayer".

### 🧱 SOLID Principles: Building Blocks of Good Code
> **"Each piece has one job and does it well"**

- **S**ingle Responsibility: One class, one purpose
- **O**pen/Closed: Easy to extend, hard to break
- **L**iskov Substitution: Interfaces work as expected
- **I**nterface Segregation: Small, focused contracts
- **D**ependency Inversion: Depend on abstractions, not details

## 🏛️ Architecture Layers

```
🌐 API Layer (FastAPI)
    ↓ depends on
🎯 Application Layer (Use Cases)
    ↓ depends on
💎 Domain Layer (Business Rules)
    ↑ implemented by
🔧 Infrastructure Layer (Database, External Services)
```

### 💎 Domain Layer - The Heart of Your Business
**What lives here:**
- **Entities**: Things with identity (Country, Club, Person)
- **Value Objects**: Things defined by their value (Email, CPF, ISOCode)
- **Repository Interfaces**: What we need from storage (without knowing how)
- **Business Rules**: The "invariants" that must always be true

**Key Rule:** This layer knows NOTHING about databases, web frameworks, or external services.

### 🎯 Application Layer - Orchestrating Business Operations
**What lives here:**
- **Use Cases**: Business scenarios (CreateCountry, TransferPlayer, RegisterClub)
- **Application Services**: Complex workflows that coordinate multiple entities
- **DTOs**: Data contracts between layers

**Key Rule:** Only depends on Domain abstractions. Doesn't know about HTTP requests or SQL queries.

### 🌐 API Layer - The Outside World Interface
**What lives here:**
- **Controllers**: Handle HTTP requests/responses
- **Schemas**: Pydantic models for validation
- **Exception Handlers**: Convert domain errors to HTTP status codes

**Key Rule:** Translates between HTTP world and business world.

### 🔧 Infrastructure Layer - The Technical Details
**What lives here:**
- **Database Models**: SQLAlchemy ORM definitions
- **Repository Implementations**: How we actually store data
- **External Service Clients**: APIs, email services, etc.

**Key Rule:** Implements the contracts defined by Domain layer.

## 📁 Project Structure

```
src/sportifyapi/
├── 🌐 api/                    # HTTP interface
│   ├── controllers/           # Route handlers
│   ├── schemas/              # Request/response models
│   └── deps.py               # Dependency injection
├── 🎯 application/           # Business workflows
│   ├── use_cases/            # Business scenarios
│   └── services/             # Complex orchestrations
├── 💎 domain/               # Pure business logic
│   ├── entities/             # Business objects with identity
│   ├── value_objects/        # Immutable values
│   ├── repositories/         # Storage contracts
│   └── services/             # Domain business logic
├── 🔧 infrastructure/        # Technical implementations
│   ├── database/             # SQLAlchemy models & repos
│   │   ├── models/           # ORM models (SQLAlchemy)
│   │   ├── repositories/     # Repository implementations
│   │   ├── migrations/       # 🆕 Alembic migrations
│   │   └── unit_of_work.py   # UoW implementation
│   ├── external_services/    # Third-party integrations
│   └── cache/               # Caching implementations
└── ⚙️ core/                 # Configuration & setup
    ├── config.py             # Settings management
    └── database.py           # DB connection setup
```

## 🔄 **Data Flow: From HTTP Request to Database and Back**

### **The Complete Journey (Step by Step)**

Let's trace what happens when someone calls `POST /countries` to create a new country:

```
🌐 HTTP Request comes in
    ↓
🎯 API Controller receives it
    ↓
🔍 Pydantic validates the data
    ↓
🏭 Use Case orchestrates business logic
    ↓
💎 Domain Entity enforces business rules
    ↓
🔧 Repository saves to database
    ↓
✅ Response flows back up the chain
```

### **Detailed Data Flow Example**

#### **1. 🌐 API Layer - The Entry Point**
```python
# Someone calls: POST /countries {"name": "Brazil", "iso_code": "br"}

@router.post("/countries", response_model=CountryResponse)
async def create_country(
    request: CountryCreateRequest,  # 🔍 Pydantic validates JSON
    uow=Depends(get_unit_of_work)   # 🔧 Dependency injection
):
    # 🎯 Controller's job: Translate HTTP → Use Case
    try:
        use_case = CreateCountryUseCase(uow)
        country = await use_case.execute(request.name, request.iso_code)
        return CountryResponse.from_entity(country)  # Entity → JSON
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
```

#### **2. 🎯 Application Layer - Business Orchestration**
```python
# application/use_cases/country/create_country.py
class CreateCountryUseCase:
    def __init__(self, uow: UnitOfWork):
        self.uow = uow  # 🔧 Abstraction, not concrete implementation

    async def execute(self, name: str, iso_code: str) -> Country:
        # 🔍 Input validation & transformation
        iso = ISOCode(iso_code.upper())  # Throws if invalid
        
        # 💎 Business rule enforcement
        existing = await self.uow.countries.get_by_iso_code(iso)
        if existing:
            raise ValueError(f"Country with ISO {iso_code} already exists")
        
        # 💎 Create domain entity
        country = Country(id=None, name=name, iso_code=iso)
        
        # 🔧 Save via repository abstraction
        saved_country = await self.uow.countries.add(country)
        await self.uow.commit()  # Transaction boundary
        
        return saved_country
```

#### **3. 💎 Domain Layer - Business Rules**
```python
# domain/entities/country.py
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

# domain/value_objects/iso_code.py
@dataclass(frozen=True)
class ISOCode:
    value: str
    
    def __post_init__(self):
        # 💎 Value object validation
        if not re.match(r'^[A-Z]{2}$', self.value):
            raise ValueError(f"Invalid ISO code: {self.value}")
```

#### **4. 🔧 Infrastructure Layer - Technical Implementation**
```python
# infrastructure/database/repositories/country_repository.py
class SQLAlchemyCountryRepository(CountryRepository):
    def __init__(self, session: AsyncSession):
        self.session = session

    async def add(self, country: Country) -> Country:
        # 🔄 Entity → Model conversion
        model = CountryModel(
            name=country.name,
            iso_code=country.iso_code.value,
            is_active=country.is_active
        )
        
        # 🔧 Database operation
        self.session.add(model)
        await self.session.flush()  # Get ID but don't commit yet
        
        # 🔄 Model → Entity conversion
        return Country(
            id=model.id,
            name=model.name,
            iso_code=ISOCode(model.iso_code),
            is_active=model.is_active
        )
```

### **🎯 Visual Data Flow**

```
📱 Client Request
    │ POST /countries {"name": "Brazil", "iso_code": "br"}
    │
    ▼
🌐 API Controller (FastAPI)
    │ • Validates JSON with Pydantic
    │ • Extracts data from request
    │ • Calls use case
    │
    ▼
🎯 Use Case (Application)
    │ • Creates ISOCode("BR") value object
    │ • Checks business rules (no duplicates)
    │ • Creates Country entity
    │ • Calls repository
    │
    ▼
💎 Domain Entity
    │ • Validates business invariants
    │ • Ensures data consistency
    │
    ▼
🔧 Repository (Infrastructure)
    │ • Converts Entity → SQLAlchemy Model
    │ • Saves to PostgreSQL
    │ • Converts Model → Entity
    │
    ▼
🎯 Use Case (Application)
    │ • Commits transaction
    │ • Returns saved entity
    │
    ▼
🌐 API Controller (FastAPI)
    │ • Converts Entity → Pydantic Response
    │ • Returns HTTP 201 with JSON
    │
    ▼
📱 Client Response
    {"id": 1, "name": "Brazil", "iso_code": "BR", "is_active": true}
```

## 🗂️ **Repository Strategy: Specific vs Generic**

### **🤔 The Eternal Question: One Repository Per Entity or Generic Base?**

**Short Answer:** Use **BOTH** - Generic base for common operations, specific interfaces for business operations.

### **📊 Comparison Table**

| Approach | Pros | Cons | When to Use |
|----------|------|------|-------------|
| **One Repository Per Entity** | • Business-focused methods<br>• Clear interfaces<br>• Easy to test | • More boilerplate<br>• Code duplication | Always for domain interfaces |
| **Generic Repository** | • Less code<br>• Consistent behavior<br>• Easy maintenance | • Not business-focused<br>• Can become "God object" | Only in infrastructure layer |
| **Hybrid (Our Choice)** | • Best of both worlds<br>• Clean domain<br>• DRY infrastructure | • Slightly more complex | Production applications |

### **🏆 Our Recommended Approach: Hybrid Strategy**

#### **✅ DO: Business-Focused Domain Interfaces**
```python
# domain/repositories/country_repository.py
class CountryRepository(ABC):
    """Business-focused interface - what the domain needs"""
    
    @abstractmethod
    async def get_by_id(self, id: int) -> Optional[Country]: ...
    
    @abstractmethod
    async def get_by_iso_code(self, iso_code: ISOCode) -> Optional[Country]: ...
    
    @abstractmethod
    async def find_active_countries(self) -> List[Country]: ...
    
    @abstractmethod
    async def add(self, country: Country) -> Country: ...
    
    @abstractmethod
    async def update(self, country: Country) -> Country: ...

# domain/repositories/player_repository.py
class PlayerRepository(ABC):
    """Different entity, different business needs"""
    
    @abstractmethod
    async def get_by_id(self, id: int) -> Optional[Player]: ...
    
    @abstractmethod
    async def find_by_club(self, club_id: int) -> List[Player]: ...
    
    @abstractmethod
    async def find_free_agents(self) -> List[Player]: ...  # Business-specific!
    
    @abstractmethod
    async def add(self, player: Player) -> Player: ...
```

#### **✅ DO: Generic Base in Infrastructure**
```python
# infrastructure/database/repositories/base_repository.py
from typing import Generic, TypeVar, Optional, List, Type
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

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

    async def _list_all(self) -> List[TEntity]:
        """Protected method - only for inheritance"""
        stmt = select(self.model_class)
        result = await self.session.execute(stmt)
        models = result.scalars().all()
        return [self.mapper.to_entity(model) for model in models]
```

#### **✅ DO: Compose Generic + Business Logic**
```python
# infrastructure/database/repositories/country_repository.py
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

    # 💎 Custom business operations
    async def get_by_iso_code(self, iso_code: ISOCode) -> Optional[Country]:
        stmt = select(CountryModel).where(CountryModel.iso_code == iso_code.value)
        result = await self.session.execute(stmt)
        model = result.scalar_one_or_none()
        return self.mapper.to_entity(model) if model else None

    async def find_active_countries(self) -> List[Country]:
        stmt = select(CountryModel).where(CountryModel.is_active == True)
        result = await self.session.execute(stmt)
        models = result.scalars().all()
        return [self.mapper.to_entity(model) for model in models]
```

### **🎯 Why This Hybrid Approach Rocks**

#### **1. 💎 Domain Stays Business-Focused**
```python
# Use case sees business operations, not CRUD
class TransferPlayerUseCase:
    async def execute(self, player_id: int, new_club_id: int):
        # 💎 Business language, not technical
        free_agents = await self.uow.players.find_free_agents()
        current_club_players = await self.uow.players.find_by_club(new_club_id)
        
        # Not: generic_repo.find_where("club_id IS NULL")
```

#### **2. 🔧 Infrastructure Stays DRY**
```python
# No code duplication for common operations
class PlayerRepository(SQLAlchemyPlayerRepository):
    def __init__(self, session: AsyncSession):
        self._base = BaseRepository(session, PlayerModel, PlayerMapper())
    
    # ✅ Reuse for standard operations
    async def get_by_id(self, id: int): 
        return await self._base._get_by_id(id)
    
    async def add(self, player: Player): 
        return await self._base._add(player)
    
    # ✅ Custom for business operations
    async def find_free_agents(self) -> List[Player]:
        # Custom SQL here
        pass
```

#### **3. 🧪 Testing Stays Simple**
```python
# Easy to fake business-focused interfaces
class FakeCountryRepository(CountryRepository):
    def __init__(self):
        self._countries: Dict[int, Country] = {}
    
    async def find_active_countries(self) -> List[Country]:
        return [c for c in self._countries.values() if c.is_active]
    
    # No need to fake generic CRUD - just business methods
```

### **📏 Guidelines for Repository Design**

#### **✅ Create Specific Repository When:**
- Entity has unique business operations
- Complex queries that make business sense
- Special validation or business rules
- Different transaction patterns

```python
# PlayerRepository - has unique business needs
async def find_free_agents(self) -> List[Player]: ...
async def find_by_position(self, position: Position) -> List[Player]: ...
async def transfer_player(self, player: Player, new_club: Club): ...
```

#### **✅ Use Generic Base When:**
- Standard CRUD operations (get, add, update, delete)
- Common patterns across entities
- Infrastructure concerns (caching, logging)

```python
# All repositories can reuse these
async def _get_by_id(self, id: int): ...
async def _add(self, entity: TEntity): ...
async def _list_all(self): ...
```

### **🎯 Practical Example: Countries vs Players**

```python
# Countries are simple - mostly CRUD
class CountryRepository(ABC):
    async def get_by_id(self, id: int): ...           # Generic
    async def get_by_iso_code(self, iso: ISOCode): ... # Business-specific
    async def add(self, country: Country): ...         # Generic
    async def find_active_countries(self): ...         # Business-specific

# Players are complex - lots of business operations  
class PlayerRepository(ABC):
    async def get_by_id(self, id: int): ...              # Generic
    async def add(self, player: Player): ...             # Generic
    async def find_free_agents(self): ...                # Business-specific
    async def find_by_position(self, pos: Position): ... # Business-specific
    async def find_by_club(self, club_id: int): ...      # Business-specific
    async def transfer_history(self, player_id: int): ... # Business-specific
```

**The Rule:** Start with business needs (domain interfaces), then implement efficiently (generic base when possible).

Don't ask "Should I use generic repositories?" Ask "What does my business domain need?" 🎯

---

## 🎯 **Summary: Data Flow + Repository Strategy**

### **🔄 Key Takeaways About Data Flow:**

1. **🌐 API Layer**: Translates HTTP ↔ Domain (thin, just translation)
2. **🎯 Application Layer**: Orchestrates business logic (no technical details)
3. **💎 Domain Layer**: Enforces business rules (pure business logic)
4. **🔧 Infrastructure Layer**: Handles technical concerns (databases, external services)

**Data flows in one direction:** API → Application → Domain → Infrastructure
**Dependencies point inward:** Each layer only knows about inner layers

### **🗂️ Key Takeaways About Repositories:**

1. **💎 Domain Interfaces**: Business-focused, one per entity with meaningful methods
2. **🔧 Infrastructure Implementation**: Use generic base for common operations
3. **🎯 Composition over Inheritance**: Compose generic base, don't expose it
4. **🧪 Testing**: Fake the business interfaces, not the generic base

**The Golden Rule:** Design for business needs first, optimize for code reuse second.

### **🚀 Your Next Steps:**

1. **Start Simple**: Create one entity (Country) with its repository
2. **Trace the Flow**: Follow data from API to database and back
3. **Test the Pattern**: Write unit tests with fake repositories
4. **Add Complexity**: Add more entities and see patterns emerge
5. **Refactor**: Extract common operations to generic base when it makes sense

**Remember:** Good architecture emerges from understanding your domain, not from following patterns blindly! 🏆

### **🔄 Common Data Flow Scenarios**

#### **Scenario 1: Simple CRUD (Country Creation)**
```
POST /countries → Controller → Use Case → Domain Entity → Repository → Database
                                    ↓
Response ← Controller ← Use Case ← Saved Entity ← Repository ← Database
```

#### **Scenario 2: Business Logic (Player Transfer)**
```
POST /players/123/transfer → Controller → TransferPlayerUseCase
                                            ↓
                                      Validates business rules
                                            ↓
                                   Updates multiple entities
                                            ↓
                                    Saves via repositories
                                            ↓
                                   Publishes domain events
```

#### **Scenario 3: Complex Query (Active Players by Position)**
```
GET /players?position=goalkeeper&status=active
    ↓
Controller → GetPlayersUseCase → PlayerRepository.find_by_position_and_status()
    ↓                                        ↓
Response ← Use Case ← Domain Entities ← Custom SQL Query
```

#### **Scenario 4: Error Handling**
```
Invalid Request → Controller → Use Case → Domain Validation Fails
                     ↓              ↓            ↓
Client ← HTTP 400 ← Controller ← ValueError ← Domain Exception
```

**Key Insight:** Data flows are predictable and testable when each layer has a clear responsibility! 🎯
**The Problem:** Business logic shouldn't care if data is in PostgreSQL, MongoDB, or a file.

**The Solution:** Define what you need (interface) separate from how you get it (implementation).

```python
# Domain defines WHAT we need
class CountryRepository(ABC):
    async def get_by_iso_code(self, iso: str) -> Optional[Country]: ...
    async def add(self, country: Country) -> Country: ...

# Infrastructure defines HOW we get it
class PostgreSQLCountryRepository(CountryRepository):
    # Implementation using SQLAlchemy
    pass
```

### Unit of Work: All or Nothing
**The Problem:** Business operations often touch multiple entities and should be atomic.

**The Solution:** Group related changes in a transaction boundary.

```python
# Use case doesn't know about database transactions
async def transfer_player(player_id: int, new_club_id: int):
    async with uow:  # Transaction starts
        player = await uow.players.get_by_id(player_id)
        # Business logic here
        player.transfer_to(new_club)
        await uow.commit()  # All changes saved together
```

### Dependency Injection: Loose Coupling
**The Problem:** Hard-coded dependencies make testing and changes difficult.

**The Solution:** Inject dependencies from the outside.

```python
# Good: Easy to test, easy to change
class CreateCountryUseCase:
    def __init__(self, uow: UnitOfWork):  # Interface, not implementation
        self.uow = uow
```

## 🎓 **Learning Resources for Unit of Work + Alembic**

### Understanding Unit of Work:
1. **Martin Fowler's Pattern**: [Patterns of Enterprise Application Architecture](https://martinfowler.com/eaaCatalog/unitOfWork.html)
2. **SQLAlchemy Session**: Think of it as a "workspace" for database changes
3. **Transaction Boundary**: All changes succeed together or fail together

### Alembic Deep Dive:
1. **Official Docs**: [Alembic Documentation](https://alembic.sqlalchemy.org/)
2. **Real Python Tutorial**: Practical examples
3. **SQLAlchemy + Alembic**: How they work together

**Remember:** Alembic is just a tool in your Infrastructure layer. Your business logic (Domain) doesn't care how the database schema is managed! 🚀

---

**Remember:** Good architecture is not about following rules perfectly. It's about making intentional decisions that serve your team and your users. Start simple, but design for growth.

*"Architecture is about the important stuff. Whatever that is." - Ralph Johnson*

Build something great! 🚀
