"""Country SQLAlchemy Model."""

from sqlalchemy import Boolean, DateTime, Integer, String
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.sql import func

from . import Base


class CountryModel(Base):
    """
    SQLAlchemy model for countries table.
    
    This is the INFRASTRUCTURE representation of a Country.
    It knows about databases, SQL, and persistence details.
    """
    
    __tablename__ = "countries"
    
    # Primary key
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    
    # Business fields (matching the SQL schema)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    iso_code: Mapped[str] = mapped_column(String(2), unique=True, nullable=False)
    active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    
    # Audit fields
    created_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True), 
        server_default=func.now(), 
        nullable=False
    )
    updated_at: Mapped[DateTime] = mapped_column(
        DateTime(timezone=True), 
        server_default=func.now(), 
        onupdate=func.now(),
        nullable=False
    )
    
    def __repr__(self) -> str:
        """String representation for debugging."""
        return f"<CountryModel(id={self.id}, name='{self.name}', iso_code='{self.iso_code}')>"
