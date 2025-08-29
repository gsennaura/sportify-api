"""SQLAlchemy Base Configuration."""

# Import Base and all models from generated_models
from .generated_models import (
    Base,
    Countries,
    States,
    Cities,
    Sports,
    Federations,
    People,
    Athletes,
    Staff,
    Referees,
    Clubs,
    AthletePositions,
    RefereeRoles,
    StaffRoles,
    ClubAthleteAssignments,
    ClubStaffAssignments,
    FederationStaffAssignments,
)

# Re-export for convenience
__all__ = [
    "Base",
    "Countries",
    "States", 
    "Cities",
    "Sports",
    "Federations",
    "People",
    "Athletes",
    "Staff",
    "Referees",
    "Clubs",
    "AthletePositions",
    "RefereeRoles",
    "StaffRoles",
    "ClubAthleteAssignments",
    "ClubStaffAssignments",
    "FederationStaffAssignments",
]
