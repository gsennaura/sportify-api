from typing import List, Optional

from sqlalchemy import Boolean, CHAR, CheckConstraint, Column, Date, DateTime, Enum, ForeignKeyConstraint, Index, Integer, PrimaryKeyConstraint, String, Table, Text, UniqueConstraint, text
from sqlalchemy.dialects.postgresql import CITEXT
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship
import datetime

class Base(DeclarativeBase):
    pass


class AthletePositions(Base):
    __tablename__ = 'athlete_positions'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='athlete_positions_pkey'),
        UniqueConstraint('name', name='athlete_positions_name_key')
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    description: Mapped[Optional[str]] = mapped_column(Text)

    athlete: Mapped[List['Athletes']] = relationship('Athletes', secondary='athlete_position_tags', back_populates='position')
    club_athlete_assignments: Mapped[List['ClubAthleteAssignments']] = relationship('ClubAthleteAssignments', back_populates='position')


class Countries(Base):
    __tablename__ = 'countries'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='countries_pkey'),
        UniqueConstraint('iso_code', name='countries_iso_code_key'),
        {'comment': 'List of countries (ISO-3166-1 alpha-2).'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(CITEXT, comment='Official country name.')
    iso_code: Mapped[str] = mapped_column(CHAR(2), comment='Two-letter ISO country code.')
    active: Mapped[bool] = mapped_column(Boolean, server_default=text('true'), comment='Defines if the country is active for federation management.')
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))

    states: Mapped[List['States']] = relationship('States', back_populates='country')
    people: Mapped[List['People']] = relationship('People', back_populates='nationality')


class RefereeRoles(Base):
    __tablename__ = 'referee_roles'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='referee_roles_pkey'),
        UniqueConstraint('name', name='referee_roles_name_key')
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    description: Mapped[Optional[str]] = mapped_column(Text)

    referee: Mapped[List['Referees']] = relationship('Referees', secondary='referee_role_tags', back_populates='role')


class Sports(Base):
    __tablename__ = 'sports'
    __table_args__ = (
        PrimaryKeyConstraint('id', name='sports_pkey'),
        UniqueConstraint('name', name='sports_name_key'),
        {'comment': 'List of sports disciplines managed by federations.'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(CITEXT)
    team_based: Mapped[bool] = mapped_column(Boolean, server_default=text('true'))
    active: Mapped[bool] = mapped_column(Boolean, server_default=text('true'))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    description: Mapped[Optional[str]] = mapped_column(Text)

    federations: Mapped[List['Federations']] = relationship('Federations', back_populates='sport')
    athletes: Mapped[List['Athletes']] = relationship('Athletes', back_populates='primary_sport')


class StaffRoles(Base):
    __tablename__ = 'staff_roles'
    __table_args__ = (
        CheckConstraint("category::text = ANY (ARRAY['technical'::character varying, 'medical'::character varying, 'management'::character varying, 'administrative'::character varying]::text[])", name='staff_roles_category_check'),
        PrimaryKeyConstraint('id', name='staff_roles_pkey'),
        UniqueConstraint('name', name='staff_roles_name_key')
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    description: Mapped[Optional[str]] = mapped_column(Text)
    category: Mapped[Optional[str]] = mapped_column(String(30))

    staff: Mapped[List['Staff']] = relationship('Staff', secondary='staff_role_tags', back_populates='role')
    club_staff_assignments: Mapped[List['ClubStaffAssignments']] = relationship('ClubStaffAssignments', back_populates='role')
    federation_staff_assignments: Mapped[List['FederationStaffAssignments']] = relationship('FederationStaffAssignments', back_populates='role')


class States(Base):
    __tablename__ = 'states'
    __table_args__ = (
        ForeignKeyConstraint(['country_id'], ['countries.id'], ondelete='CASCADE', name='states_country_id_fkey'),
        PrimaryKeyConstraint('id', name='states_pkey'),
        {'comment': 'States or provinces within a country.'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(CITEXT)
    abbreviation: Mapped[str] = mapped_column(String(5), comment='State/province abbreviation (ISO-3166-2-like).')
    country_id: Mapped[int] = mapped_column(Integer)
    active: Mapped[bool] = mapped_column(Boolean, server_default=text('true'))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))

    country: Mapped['Countries'] = relationship('Countries', back_populates='states')
    cities: Mapped[List['Cities']] = relationship('Cities', back_populates='state')


class Cities(Base):
    __tablename__ = 'cities'
    __table_args__ = (
        ForeignKeyConstraint(['state_id'], ['states.id'], ondelete='SET NULL', name='cities_state_id_fkey'),
        PrimaryKeyConstraint('id', name='cities_pkey'),
        {'comment': 'Cities associated with states/provinces.'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(CITEXT)
    active: Mapped[bool] = mapped_column(Boolean, server_default=text('true'))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    state_id: Mapped[Optional[int]] = mapped_column(Integer, comment='Reference to the state this city belongs to.')

    state: Mapped[Optional['States']] = relationship('States', back_populates='cities')
    federations: Mapped[List['Federations']] = relationship('Federations', back_populates='city')
    people: Mapped[List['People']] = relationship('People', back_populates='birth_city')
    clubs: Mapped[List['Clubs']] = relationship('Clubs', back_populates='city')


class Federations(Base):
    __tablename__ = 'federations'
    __table_args__ = (
        CheckConstraint("logo_url IS NULL OR logo_url ~* '^(https?://)'::text", name='federations_logo_format_chk'),
        CheckConstraint("website IS NULL OR website ~* '^(https?://)'::text", name='federations_website_format_chk'),
        ForeignKeyConstraint(['city_id'], ['cities.id'], ondelete='SET NULL', name='federations_city_id_fkey'),
        ForeignKeyConstraint(['parent_federation_id'], ['federations.id'], ondelete='SET NULL', name='federations_parent_federation_id_fkey'),
        ForeignKeyConstraint(['sport_id'], ['sports.id'], ondelete='CASCADE', name='federations_sport_id_fkey'),
        PrimaryKeyConstraint('id', name='federations_pkey'),
        Index('idx_federations_city_id', 'city_id'),
        Index('idx_federations_parent', 'parent_federation_id'),
        Index('idx_federations_sport_id', 'sport_id'),
        {'comment': 'Sports governing bodies (federations, confederations, '
                'associations).'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(CITEXT)
    sport_id: Mapped[int] = mapped_column(Integer)
    geographic_scope: Mapped[str] = mapped_column(Enum('global', 'continental', 'national', 'regional', 'state', 'local', name='geographic_scope'), comment='Level of federation: global, continental, national, regional, state or local.')
    active: Mapped[bool] = mapped_column(Boolean, server_default=text('true'))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    acronym: Mapped[Optional[str]] = mapped_column(CITEXT, comment='Short acronym of the federation (e.g., FIFA).')
    parent_federation_id: Mapped[Optional[int]] = mapped_column(Integer, comment='Optional parent federation (e.g., FIFA is parent of CBF).')
    city_id: Mapped[Optional[int]] = mapped_column(Integer, comment='City where the headquarters is located.')
    foundation_date: Mapped[Optional[datetime.date]] = mapped_column(Date, comment='Date when the federation was founded.')
    logo_url: Mapped[Optional[str]] = mapped_column(Text, comment='Link to federation logo image.')
    website: Mapped[Optional[str]] = mapped_column(Text, comment='Official website of the federation.')

    city: Mapped[Optional['Cities']] = relationship('Cities', back_populates='federations')
    parent_federation: Mapped[Optional['Federations']] = relationship('Federations', remote_side=[id], back_populates='parent_federation_reverse')
    parent_federation_reverse: Mapped[List['Federations']] = relationship('Federations', remote_side=[parent_federation_id], back_populates='parent_federation')
    sport: Mapped['Sports'] = relationship('Sports', back_populates='federations')
    clubs: Mapped[List['Clubs']] = relationship('Clubs', back_populates='federation')
    federation_staff_assignments: Mapped[List['FederationStaffAssignments']] = relationship('FederationStaffAssignments', back_populates='federation')


class People(Base):
    __tablename__ = 'people'
    __table_args__ = (
        CheckConstraint("gender::text = ANY (ARRAY['male'::character varying, 'female'::character varying, 'other'::character varying]::text[])", name='people_gender_check'),
        ForeignKeyConstraint(['birth_city_id'], ['cities.id'], ondelete='SET NULL', name='people_birth_city_id_fkey'),
        ForeignKeyConstraint(['nationality_id'], ['countries.id'], ondelete='SET NULL', name='people_nationality_id_fkey'),
        PrimaryKeyConstraint('id', name='people_pkey'),
        UniqueConstraint('document', name='people_document_key'),
        {'comment': 'Registry of all individuals (athletes, referees, staff, etc.).'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    first_name: Mapped[str] = mapped_column(String(50))
    last_name: Mapped[str] = mapped_column(String(100))
    document: Mapped[str] = mapped_column(String(20), comment='Main identification document (CPF for Brazil, Passport elsewhere).')
    active: Mapped[bool] = mapped_column(Boolean, server_default=text('true'))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    birth_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    gender: Mapped[Optional[str]] = mapped_column(String(10))
    nationality_id: Mapped[Optional[int]] = mapped_column(Integer)
    birth_city_id: Mapped[Optional[int]] = mapped_column(Integer)
    photo_url: Mapped[Optional[str]] = mapped_column(String(255))

    birth_city: Mapped[Optional['Cities']] = relationship('Cities', back_populates='people')
    nationality: Mapped[Optional['Countries']] = relationship('Countries', back_populates='people')


class Athletes(People):
    __tablename__ = 'athletes'
    __table_args__ = (
        CheckConstraint("status::text = ANY (ARRAY['active'::character varying, 'free_agent'::character varying, 'suspended'::character varying, 'retired'::character varying]::text[])", name='athletes_status_check'),
        ForeignKeyConstraint(['person_id'], ['people.id'], ondelete='CASCADE', name='athletes_person_id_fkey'),
        ForeignKeyConstraint(['primary_sport_id'], ['sports.id'], ondelete='SET NULL', name='athletes_primary_sport_id_fkey'),
        PrimaryKeyConstraint('person_id', name='athletes_pkey'),
        UniqueConstraint('athlete_number', name='athletes_athlete_number_key'),
        {'comment': 'Athlete profile extending a person (independent from club '
                'assignments).'}
    )

    person_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    status: Mapped[str] = mapped_column(String(20), server_default=text("'active'::character varying"))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    athlete_number: Mapped[Optional[str]] = mapped_column(String(40))
    primary_sport_id: Mapped[Optional[int]] = mapped_column(Integer)

    primary_sport: Mapped[Optional['Sports']] = relationship('Sports', back_populates='athletes')
    position: Mapped[List['AthletePositions']] = relationship('AthletePositions', secondary='athlete_position_tags', back_populates='athlete')
    club_athlete_assignments: Mapped[List['ClubAthleteAssignments']] = relationship('ClubAthleteAssignments', back_populates='athlete')


class Clubs(Base):
    __tablename__ = 'clubs'
    __table_args__ = (
        CheckConstraint("crest_url IS NULL OR crest_url ~* '^(https?://)'::text", name='clubs_crest_format_chk'),
        CheckConstraint("website IS NULL OR website ~* '^(https?://)'::text", name='clubs_website_format_chk'),
        ForeignKeyConstraint(['city_id'], ['cities.id'], ondelete='SET NULL', name='clubs_city_id_fkey'),
        ForeignKeyConstraint(['federation_id'], ['federations.id'], ondelete='CASCADE', name='clubs_federation_id_fkey'),
        PrimaryKeyConstraint('id', name='clubs_pkey'),
        UniqueConstraint('federation_id', 'acronym', name='clubs_unique_acronym_per_fed'),
        UniqueConstraint('federation_id', 'name', name='clubs_unique_name_per_fed'),
        Index('idx_clubs_city_id', 'city_id'),
        Index('idx_clubs_federation_id', 'federation_id'),
        {'comment': 'Sports clubs registered under a federation.'}
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(CITEXT)
    federation_id: Mapped[int] = mapped_column(Integer, comment='Federation the club belongs to (mandatory).')
    active: Mapped[bool] = mapped_column(Boolean, server_default=text('true'))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    short_name: Mapped[Optional[str]] = mapped_column(CITEXT)
    acronym: Mapped[Optional[str]] = mapped_column(CITEXT)
    city_id: Mapped[Optional[int]] = mapped_column(Integer)
    foundation_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    crest_url: Mapped[Optional[str]] = mapped_column(Text)
    website: Mapped[Optional[str]] = mapped_column(Text)

    city: Mapped[Optional['Cities']] = relationship('Cities', back_populates='clubs')
    federation: Mapped['Federations'] = relationship('Federations', back_populates='clubs')
    club_athlete_assignments: Mapped[List['ClubAthleteAssignments']] = relationship('ClubAthleteAssignments', back_populates='club')
    club_staff_assignments: Mapped[List['ClubStaffAssignments']] = relationship('ClubStaffAssignments', back_populates='club')


class Referees(People):
    __tablename__ = 'referees'
    __table_args__ = (
        CheckConstraint("status::text = ANY (ARRAY['active'::character varying, 'available'::character varying, 'suspended'::character varying, 'retired'::character varying]::text[])", name='referees_status_check'),
        ForeignKeyConstraint(['person_id'], ['people.id'], ondelete='CASCADE', name='referees_person_id_fkey'),
        PrimaryKeyConstraint('person_id', name='referees_pkey'),
        UniqueConstraint('referee_registry_number', name='referees_referee_registry_number_key'),
        {'comment': 'Referee profile extending a person (independent from federation '
                'assignments).'}
    )

    person_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    status: Mapped[str] = mapped_column(String(20), server_default=text("'active'::character varying"))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    referee_registry_number: Mapped[Optional[str]] = mapped_column(String(40))
    grade: Mapped[Optional[str]] = mapped_column(String(30))

    role: Mapped[List['RefereeRoles']] = relationship('RefereeRoles', secondary='referee_role_tags', back_populates='referee')


class Staff(People):
    __tablename__ = 'staff'
    __table_args__ = (
        CheckConstraint("status::text = ANY (ARRAY['active'::character varying, 'available'::character varying, 'suspended'::character varying, 'retired'::character varying]::text[])", name='staff_status_check'),
        ForeignKeyConstraint(['person_id'], ['people.id'], ondelete='CASCADE', name='staff_person_id_fkey'),
        PrimaryKeyConstraint('person_id', name='staff_pkey'),
        UniqueConstraint('staff_registry_number', name='staff_staff_registry_number_key'),
        {'comment': 'Staff profile extending a person (independent from club '
                'assignments).'}
    )

    person_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    status: Mapped[str] = mapped_column(String(20), server_default=text("'active'::character varying"))
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    staff_registry_number: Mapped[Optional[str]] = mapped_column(String(40))

    role: Mapped[List['StaffRoles']] = relationship('StaffRoles', secondary='staff_role_tags', back_populates='staff')
    club_staff_assignments: Mapped[List['ClubStaffAssignments']] = relationship('ClubStaffAssignments', back_populates='staff')
    federation_staff_assignments: Mapped[List['FederationStaffAssignments']] = relationship('FederationStaffAssignments', back_populates='staff')


t_athlete_position_tags = Table(
    'athlete_position_tags', Base.metadata,
    Column('athlete_id', Integer, primary_key=True, nullable=False),
    Column('position_id', Integer, primary_key=True, nullable=False),
    ForeignKeyConstraint(['athlete_id'], ['athletes.person_id'], ondelete='CASCADE', name='athlete_position_tags_athlete_id_fkey'),
    ForeignKeyConstraint(['position_id'], ['athlete_positions.id'], ondelete='CASCADE', name='athlete_position_tags_position_id_fkey'),
    PrimaryKeyConstraint('athlete_id', 'position_id', name='athlete_position_tags_pkey')
)


class ClubAthleteAssignments(Base):
    __tablename__ = 'club_athlete_assignments'
    __table_args__ = (
        CheckConstraint('end_date IS NULL OR start_date IS NULL OR end_date >= start_date', name='club_athlete_dates_chk'),
        CheckConstraint("status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'loaned'::character varying, 'suspended'::character varying]::text[])", name='club_athlete_assignments_status_check'),
        ForeignKeyConstraint(['athlete_id'], ['athletes.person_id'], ondelete='CASCADE', name='club_athlete_assignments_athlete_id_fkey'),
        ForeignKeyConstraint(['club_id'], ['clubs.id'], ondelete='CASCADE', name='club_athlete_assignments_club_id_fkey'),
        ForeignKeyConstraint(['position_id'], ['athlete_positions.id'], ondelete='SET NULL', name='club_athlete_assignments_position_id_fkey'),
        PrimaryKeyConstraint('club_id', 'athlete_id', 'start_date', name='club_athlete_assignments_pkey'),
        Index('idx_caa_athlete', 'athlete_id'),
        Index('idx_caa_club', 'club_id'),
        Index('idx_caa_current', 'club_id', 'athlete_id'),
        {'comment': 'Athlete memberships in a club (historical, with status).'}
    )

    club_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    athlete_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    status: Mapped[str] = mapped_column(String(20), server_default=text("'active'::character varying"), comment='Membership status: active, inactive, loaned, or suspended.')
    start_date: Mapped[datetime.date] = mapped_column(Date, primary_key=True)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    position_id: Mapped[Optional[int]] = mapped_column(Integer)
    shirt_number: Mapped[Optional[int]] = mapped_column(Integer)
    end_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    notes: Mapped[Optional[str]] = mapped_column(Text)

    athlete: Mapped['Athletes'] = relationship('Athletes', back_populates='club_athlete_assignments')
    club: Mapped['Clubs'] = relationship('Clubs', back_populates='club_athlete_assignments')
    position: Mapped[Optional['AthletePositions']] = relationship('AthletePositions', back_populates='club_athlete_assignments')


class ClubStaffAssignments(Base):
    __tablename__ = 'club_staff_assignments'
    __table_args__ = (
        CheckConstraint('end_date IS NULL OR start_date IS NULL OR end_date >= start_date', name='club_staff_dates_chk'),
        CheckConstraint("status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'suspended'::character varying]::text[])", name='club_staff_assignments_status_check'),
        ForeignKeyConstraint(['club_id'], ['clubs.id'], ondelete='CASCADE', name='club_staff_assignments_club_id_fkey'),
        ForeignKeyConstraint(['role_id'], ['staff_roles.id'], ondelete='SET NULL', name='club_staff_assignments_role_id_fkey'),
        ForeignKeyConstraint(['staff_id'], ['staff.person_id'], ondelete='CASCADE', name='club_staff_assignments_staff_id_fkey'),
        PrimaryKeyConstraint('club_id', 'staff_id', 'start_date', name='club_staff_assignments_pkey'),
        Index('idx_csa_club', 'club_id'),
        Index('idx_csa_current', 'club_id', 'staff_id'),
        Index('idx_csa_staff', 'staff_id'),
        {'comment': 'Staff memberships and specific roles within a club (historical).'}
    )

    club_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    staff_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    status: Mapped[str] = mapped_column(String(20), server_default=text("'active'::character varying"))
    start_date: Mapped[datetime.date] = mapped_column(Date, primary_key=True)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    role_id: Mapped[Optional[int]] = mapped_column(Integer, comment='Optional concrete role inside the club (from staff_roles).')
    end_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    notes: Mapped[Optional[str]] = mapped_column(Text)

    club: Mapped['Clubs'] = relationship('Clubs', back_populates='club_staff_assignments')
    role: Mapped[Optional['StaffRoles']] = relationship('StaffRoles', back_populates='club_staff_assignments')
    staff: Mapped['Staff'] = relationship('Staff', back_populates='club_staff_assignments')


class FederationStaffAssignments(Base):
    __tablename__ = 'federation_staff_assignments'
    __table_args__ = (
        CheckConstraint('end_date IS NULL OR start_date IS NULL OR end_date >= start_date', name='fed_staff_dates_chk'),
        CheckConstraint("status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'suspended'::character varying]::text[])", name='federation_staff_assignments_status_check'),
        ForeignKeyConstraint(['federation_id'], ['federations.id'], ondelete='CASCADE', name='federation_staff_assignments_federation_id_fkey'),
        ForeignKeyConstraint(['role_id'], ['staff_roles.id'], ondelete='SET NULL', name='federation_staff_assignments_role_id_fkey'),
        ForeignKeyConstraint(['staff_id'], ['staff.person_id'], ondelete='CASCADE', name='federation_staff_assignments_staff_id_fkey'),
        PrimaryKeyConstraint('federation_id', 'staff_id', 'start_date', name='federation_staff_assignments_pkey'),
        Index('idx_fsa_current', 'federation_id', 'staff_id'),
        Index('idx_fsa_fed', 'federation_id'),
        Index('idx_fsa_staff', 'staff_id'),
        {'comment': 'Staff roles and memberships within a federation (historical).'}
    )

    federation_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    staff_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    status: Mapped[str] = mapped_column(String(20), server_default=text("'active'::character varying"))
    start_date: Mapped[datetime.date] = mapped_column(Date, primary_key=True)
    created_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    updated_at: Mapped[datetime.datetime] = mapped_column(DateTime(True), server_default=text('now()'))
    role_id: Mapped[Optional[int]] = mapped_column(Integer)
    end_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    notes: Mapped[Optional[str]] = mapped_column(Text)

    federation: Mapped['Federations'] = relationship('Federations', back_populates='federation_staff_assignments')
    role: Mapped[Optional['StaffRoles']] = relationship('StaffRoles', back_populates='federation_staff_assignments')
    staff: Mapped['Staff'] = relationship('Staff', back_populates='federation_staff_assignments')


t_referee_role_tags = Table(
    'referee_role_tags', Base.metadata,
    Column('referee_id', Integer, primary_key=True, nullable=False),
    Column('role_id', Integer, primary_key=True, nullable=False),
    ForeignKeyConstraint(['referee_id'], ['referees.person_id'], ondelete='CASCADE', name='referee_role_tags_referee_id_fkey'),
    ForeignKeyConstraint(['role_id'], ['referee_roles.id'], ondelete='CASCADE', name='referee_role_tags_role_id_fkey'),
    PrimaryKeyConstraint('referee_id', 'role_id', name='referee_role_tags_pkey')
)


t_staff_role_tags = Table(
    'staff_role_tags', Base.metadata,
    Column('staff_id', Integer, primary_key=True, nullable=False),
    Column('role_id', Integer, primary_key=True, nullable=False),
    ForeignKeyConstraint(['role_id'], ['staff_roles.id'], ondelete='CASCADE', name='staff_role_tags_role_id_fkey'),
    ForeignKeyConstraint(['staff_id'], ['staff.person_id'], ondelete='CASCADE', name='staff_role_tags_staff_id_fkey'),
    PrimaryKeyConstraint('staff_id', 'role_id', name='staff_role_tags_pkey')
)
