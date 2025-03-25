from contextlib import asynccontextmanager
from typing import AsyncGenerator, Type

from sqlalchemy.ext.asyncio import AsyncSession
from sportifyapi.core.database import get_session
from sportifyapi.infrastructure.database.repositories.base_repository import BaseRepository


class UnitOfWork:
    """
    Unit of Work pattern implementation.
    Manages a single database transaction across multiple repositories.
    """

    def __init__(self, session: AsyncSession):
        self.session = session
        self._repos = {}

    def get_repository(self, repo_type: Type[BaseRepository]) -> BaseRepository:
        """
        Lazily initialize and retrieve repository instances.
        Repositories must inherit from BaseRepository.
        """
        if repo_type not in self._repos:
            self._repos[repo_type] = repo_type(session=self.session)
        return self._repos[repo_type]

    async def commit(self) -> None:
        await self.session.commit()

    async def rollback(self) -> None:
        await self.session.rollback()

    async def close(self) -> None:
        await self.session.close()


@asynccontextmanager
async def get_unit_of_work() -> AsyncGenerator[UnitOfWork, None]:
    async for session in get_session():
        uow = UnitOfWork(session=session)
        try:
            yield uow
            await uow.commit()
        except Exception:
            await uow.rollback()
            raise
        finally:
            await uow.close()