# src/sportifyapi/infrastructure/database/repositories/base_repository.py

from typing import Generic, TypeVar, Type, Optional, List, Sequence
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import update as sqlalchemy_update, delete as sqlalchemy_delete
from sqlalchemy.orm import DeclarativeMeta

T = TypeVar("T", bound=DeclarativeMeta)


class BaseRepository(Generic[T]):
    """
    Generic base repository providing common CRUD operations.
    Should be inherited by specific repositories.
    """

    def __init__(self, model: Type[T], session: AsyncSession):
        self.model = model
        self.session = session

    async def get_by_id(self, id_: int) -> Optional[T]:
        """Retrieve a record by its primary key."""
        stmt = select(self.model).where(self.model.id == id_)
        result = await self.session.execute(stmt)
        return result.scalar_one_or_none()

    async def get_all(self) -> List[T]:
        """Retrieve all records."""
        stmt = select(self.model)
        result = await self.session.execute(stmt)
        return result.scalars().all()

    async def create(self, obj_in: T) -> T:
        """Insert a new record and commit immediately."""
        self.session.add(obj_in)
        await self.session.commit()
        await self.session.refresh(obj_in)
        return obj_in

    async def create_many(self, objs: Sequence[T]) -> List[T]:
        """Insert multiple records and commit immediately."""
        self.session.add_all(objs)
        await self.session.commit()
        for obj in objs:
            await self.session.refresh(obj)
        return list(objs)

    async def create_deferred(self, obj_in: T) -> T:
        """Insert a new record without committing (deferred commit)."""
        self.session.add(obj_in)
        return obj_in

    async def create_many_deferred(self, objs: Sequence[T]) -> List[T]:
        """Insert multiple records without committing (deferred commit)."""
        self.session.add_all(objs)
        return list(objs)

    async def update(self, id_: int, update_data: dict) -> Optional[T]:
        """
        Update a record with provided data.
        Returns the updated record or None if not found.
        """
        await self.session.execute(
            sqlalchemy_update(self.model).where(self.model.id == id_).values(**update_data)
        )
        await self.session.commit()
        return await self.get_by_id(id_)

    async def delete(self, id_: int) -> None:
        """Delete a record by its ID."""
        await self.session.execute(
            sqlalchemy_delete(self.model).where(self.model.id == id_)
        )
        await self.session.commit()

    # TODO: Add additional helper methods as needed, like filter, exists, count, etc.
    # Consider transaction manager or Unit of Work pattern for advanced use cases.
