import datetime
import decimal
from typing import List, Optional

from sqlalchemy import (CHAR, Boolean, CheckConstraint, Column, Date, DateTime,
                        ForeignKeyConstraint, Integer, Numeric,
                        PrimaryKeyConstraint, String, Table, Text,
                        UniqueConstraint, text)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, relationship


class Base(DeclarativeBase):
    pass


class Categories(Base):
    __tablename__ = "categories"
    __table_args__ = (
        PrimaryKeyConstraint("id", name="categories_pkey"),
        UniqueConstraint("name", name="categories_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(50))

    league_editions: Mapped[List["LeagueEditions"]] = relationship(
        "LeagueEditions", back_populates="category"
    )
    teams: Mapped[List["Teams"]] = relationship("Teams", back_populates="category")


class CharacteristicTypes(Base):
    __tablename__ = "characteristic_types"
    __table_args__ = (
        PrimaryKeyConstraint("id", name="characteristic_types_pkey"),
        UniqueConstraint("name", name="characteristic_types_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))

    characteristics: Mapped[List["Characteristics"]] = relationship(
        "Characteristics", back_populates="type"
    )


class Countries(Base):
    __tablename__ = "countries"
    __table_args__ = (
        PrimaryKeyConstraint("id", name="countries_pkey"),
        UniqueConstraint("iso_code", name="countries_iso_code_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    iso_code: Mapped[str] = mapped_column(CHAR(2))

    person: Mapped[List["People"]] = relationship(
        "People", secondary="person_country", back_populates="country"
    )
    federations: Mapped[List["Federations"]] = relationship(
        "Federations", back_populates="country"
    )
    states: Mapped[List["States"]] = relationship("States", back_populates="country")


class Roles(Base):
    __tablename__ = "roles"
    __table_args__ = (
        PrimaryKeyConstraint("id", name="roles_pkey"),
        UniqueConstraint("name", name="roles_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))

    person_entity: Mapped[List["PersonEntity"]] = relationship(
        "PersonEntity", back_populates="role"
    )
    person_federation: Mapped[List["PersonFederation"]] = relationship(
        "PersonFederation", back_populates="role"
    )
    team_players: Mapped[List["TeamPlayers"]] = relationship(
        "TeamPlayers", back_populates="role"
    )


class Sponsors(Base):
    __tablename__ = "sponsors"
    __table_args__ = (
        PrimaryKeyConstraint("id", name="sponsors_pkey"),
        UniqueConstraint("name", name="sponsors_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(150))

    entity_sponsor: Mapped[List["EntitySponsor"]] = relationship(
        "EntitySponsor", back_populates="sponsor"
    )


class Sports(Base):
    __tablename__ = "sports"
    __table_args__ = (
        PrimaryKeyConstraint("id", name="sports_pkey"),
        UniqueConstraint("name", name="sports_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))

    federation: Mapped[List["Federations"]] = relationship(
        "Federations", secondary="federation_sport", back_populates="sport"
    )
    league_editions: Mapped[List["LeagueEditions"]] = relationship(
        "LeagueEditions", back_populates="sport"
    )
    teams: Mapped[List["Teams"]] = relationship("Teams", back_populates="sport")


class UniformBrands(Base):
    __tablename__ = "uniform_brands"
    __table_args__ = (
        PrimaryKeyConstraint("id", name="uniform_brands_pkey"),
        UniqueConstraint("name", name="uniform_brands_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))

    entity_brand: Mapped[List["EntityBrand"]] = relationship(
        "EntityBrand", back_populates="brand"
    )


class Characteristics(Base):
    __tablename__ = "characteristics"
    __table_args__ = (
        ForeignKeyConstraint(
            ["type_id"],
            ["characteristic_types.id"],
            ondelete="CASCADE",
            name="characteristics_type_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="characteristics_pkey"),
        UniqueConstraint("name", name="characteristics_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    type_id: Mapped[int] = mapped_column(Integer)
    name: Mapped[str] = mapped_column(String(100))

    type: Mapped["CharacteristicTypes"] = relationship(
        "CharacteristicTypes", back_populates="characteristics"
    )
    person: Mapped[List["People"]] = relationship(
        "People", secondary="person_characteristic", back_populates="characteristic"
    )


class Federations(Base):
    __tablename__ = "federations"
    __table_args__ = (
        CheckConstraint(
            "level::text = ANY (ARRAY['municipal'::character varying, 'regional'::character varying, 'state'::character varying, 'national'::character varying, 'continental'::character varying, 'world'::character varying]::text[])",
            name="federations_level_check",
        ),
        ForeignKeyConstraint(
            ["country_id"],
            ["countries.id"],
            ondelete="SET NULL",
            name="federations_country_id_fkey",
        ),
        ForeignKeyConstraint(
            ["parent_federation_id"],
            ["federations.id"],
            ondelete="SET NULL",
            name="federations_parent_federation_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="federations_pkey"),
        UniqueConstraint("name", name="federations_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(150))
    level: Mapped[str] = mapped_column(String(50))
    parent_federation_id: Mapped[Optional[int]] = mapped_column(Integer)
    founded_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    country_id: Mapped[Optional[int]] = mapped_column(Integer)

    country: Mapped[Optional["Countries"]] = relationship(
        "Countries", back_populates="federations"
    )
    parent_federation: Mapped[Optional["Federations"]] = relationship(
        "Federations", remote_side=[id], back_populates="parent_federation_reverse"
    )
    parent_federation_reverse: Mapped[List["Federations"]] = relationship(
        "Federations",
        remote_side=[parent_federation_id],
        back_populates="parent_federation",
    )
    sport: Mapped[List["Sports"]] = relationship(
        "Sports", secondary="federation_sport", back_populates="federation"
    )
    leagues: Mapped[List["Leagues"]] = relationship(
        "Leagues", back_populates="federation"
    )
    entity: Mapped[List["Entities"]] = relationship(
        "Entities", secondary="entity_federation", back_populates="federation"
    )
    person_federation: Mapped[List["PersonFederation"]] = relationship(
        "PersonFederation", back_populates="federation"
    )


class States(Base):
    __tablename__ = "states"
    __table_args__ = (
        ForeignKeyConstraint(
            ["country_id"],
            ["countries.id"],
            ondelete="CASCADE",
            name="states_country_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="states_pkey"),
        UniqueConstraint("abbreviation", name="states_abbreviation_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    abbreviation: Mapped[str] = mapped_column(CHAR(2))
    country_id: Mapped[int] = mapped_column(Integer)

    country: Mapped["Countries"] = relationship("Countries", back_populates="states")
    cities: Mapped[List["Cities"]] = relationship("Cities", back_populates="state")


class Cities(Base):
    __tablename__ = "cities"
    __table_args__ = (
        ForeignKeyConstraint(
            ["state_id"],
            ["states.id"],
            ondelete="SET NULL",
            name="cities_state_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="cities_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    state_id: Mapped[Optional[int]] = mapped_column(Integer)

    state: Mapped[Optional["States"]] = relationship("States", back_populates="cities")
    entities: Mapped[List["Entities"]] = relationship("Entities", back_populates="city")
    locations: Mapped[List["Locations"]] = relationship(
        "Locations", back_populates="city"
    )
    people: Mapped[List["People"]] = relationship("People", back_populates="city")


t_federation_sport = Table(
    "federation_sport",
    Base.metadata,
    Column("federation_id", Integer, primary_key=True, nullable=False),
    Column("sport_id", Integer, primary_key=True, nullable=False),
    ForeignKeyConstraint(
        ["federation_id"],
        ["federations.id"],
        ondelete="CASCADE",
        name="federation_sport_federation_id_fkey",
    ),
    ForeignKeyConstraint(
        ["sport_id"],
        ["sports.id"],
        ondelete="CASCADE",
        name="federation_sport_sport_id_fkey",
    ),
    PrimaryKeyConstraint("federation_id", "sport_id", name="federation_sport_pkey"),
)


class Leagues(Base):
    __tablename__ = "leagues"
    __table_args__ = (
        ForeignKeyConstraint(
            ["federation_id"],
            ["federations.id"],
            ondelete="SET NULL",
            name="leagues_federation_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="leagues_pkey"),
        UniqueConstraint("name", name="leagues_name_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(150))
    federation_id: Mapped[Optional[int]] = mapped_column(Integer)
    founded_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    official_website: Mapped[Optional[str]] = mapped_column(String(255))
    description: Mapped[Optional[str]] = mapped_column(Text)

    federation: Mapped[Optional["Federations"]] = relationship(
        "Federations", back_populates="leagues"
    )
    league_editions: Mapped[List["LeagueEditions"]] = relationship(
        "LeagueEditions", back_populates="league"
    )


class Entities(Base):
    __tablename__ = "entities"
    __table_args__ = (
        ForeignKeyConstraint(
            ["city_id"],
            ["cities.id"],
            ondelete="SET NULL",
            name="entities_city_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="entities_pkey"),
        UniqueConstraint("name", name="entities_name_key"),
        UniqueConstraint("tax_id", name="entities_tax_id_key"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(150))
    nickname: Mapped[Optional[str]] = mapped_column(String(100))
    foundation_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    city_id: Mapped[Optional[int]] = mapped_column(Integer)
    tax_id: Mapped[Optional[str]] = mapped_column(String(18))
    address: Mapped[Optional[str]] = mapped_column(Text)
    president: Mapped[Optional[str]] = mapped_column(String(150))
    official_website: Mapped[Optional[str]] = mapped_column(String(255))
    email: Mapped[Optional[str]] = mapped_column(String(150))
    historical_names: Mapped[Optional[str]] = mapped_column(Text)

    city: Mapped[Optional["Cities"]] = relationship("Cities", back_populates="entities")
    federation: Mapped[List["Federations"]] = relationship(
        "Federations", secondary="entity_federation", back_populates="entity"
    )
    entity_brand: Mapped[List["EntityBrand"]] = relationship(
        "EntityBrand", back_populates="entity"
    )
    entity_sponsor: Mapped[List["EntitySponsor"]] = relationship(
        "EntitySponsor", back_populates="entity"
    )
    person_entity: Mapped[List["PersonEntity"]] = relationship(
        "PersonEntity", back_populates="entity"
    )
    teams: Mapped[List["Teams"]] = relationship("Teams", back_populates="entity")


class LeagueEditions(Base):
    __tablename__ = "league_editions"
    __table_args__ = (
        CheckConstraint(
            "competition_type::text = ANY (ARRAY['team'::character varying, 'individual'::character varying]::text[])",
            name="league_editions_competition_type_check",
        ),
        CheckConstraint(
            "format::text = ANY (ARRAY['elimination'::character varying, 'round_robin'::character varying, 'mixed'::character varying, 'group_stage'::character varying]::text[])",
            name="league_editions_format_check",
        ),
        CheckConstraint(
            "gender::text = ANY (ARRAY['male'::character varying, 'female'::character varying, 'mixed'::character varying]::text[])",
            name="league_editions_gender_check",
        ),
        CheckConstraint(
            "status::text = ANY (ARRAY['planned'::character varying, 'ongoing'::character varying, 'completed'::character varying, 'cancelled'::character varying]::text[])",
            name="league_editions_status_check",
        ),
        ForeignKeyConstraint(
            ["category_id"],
            ["categories.id"],
            ondelete="CASCADE",
            name="league_editions_category_id_fkey",
        ),
        ForeignKeyConstraint(
            ["league_id"],
            ["leagues.id"],
            ondelete="CASCADE",
            name="league_editions_league_id_fkey",
        ),
        ForeignKeyConstraint(
            ["sport_id"],
            ["sports.id"],
            ondelete="CASCADE",
            name="league_editions_sport_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="league_editions_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    league_id: Mapped[int] = mapped_column(Integer)
    sport_id: Mapped[int] = mapped_column(Integer)
    category_id: Mapped[int] = mapped_column(Integer)
    season: Mapped[str] = mapped_column(String(20))
    start_date: Mapped[datetime.date] = mapped_column(Date)
    end_date: Mapped[datetime.date] = mapped_column(Date)
    gender: Mapped[str] = mapped_column(String(10))
    format: Mapped[str] = mapped_column(String(50))
    competition_type: Mapped[str] = mapped_column(
        String(20), server_default=text("'team'::character varying")
    )
    status: Mapped[str] = mapped_column(String(20))
    official_website: Mapped[Optional[str]] = mapped_column(String(255))

    category: Mapped["Categories"] = relationship(
        "Categories", back_populates="league_editions"
    )
    league: Mapped["Leagues"] = relationship(
        "Leagues", back_populates="league_editions"
    )
    sport: Mapped["Sports"] = relationship("Sports", back_populates="league_editions")
    league_committee: Mapped[List["LeagueCommittee"]] = relationship(
        "LeagueCommittee", back_populates="league_edition"
    )
    league_edition_groupings: Mapped[List["LeagueEditionGroupings"]] = relationship(
        "LeagueEditionGroupings", back_populates="league_edition"
    )
    league_edition_standings: Mapped[List["LeagueEditionStandings"]] = relationship(
        "LeagueEditionStandings", back_populates="league_edition"
    )
    league_edition_teams: Mapped[List["LeagueEditionTeams"]] = relationship(
        "LeagueEditionTeams", back_populates="league_edition"
    )


class Locations(Base):
    __tablename__ = "locations"
    __table_args__ = (
        ForeignKeyConstraint(
            ["city_id"],
            ["cities.id"],
            ondelete="SET NULL",
            name="locations_city_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="locations_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(255))
    city_id: Mapped[Optional[int]] = mapped_column(Integer)
    address: Mapped[Optional[str]] = mapped_column(Text)
    latitude: Mapped[Optional[decimal.Decimal]] = mapped_column(Numeric(10, 8))
    longitude: Mapped[Optional[decimal.Decimal]] = mapped_column(Numeric(10, 8))

    city: Mapped[Optional["Cities"]] = relationship(
        "Cities", back_populates="locations"
    )
    matches: Mapped[List["Matches"]] = relationship(
        "Matches", back_populates="location"
    )


class People(Base):
    __tablename__ = "people"
    __table_args__ = (
        CheckConstraint("height > 0::numeric", name="people_height_check"),
        CheckConstraint("weight > 0::numeric", name="people_weight_check"),
        ForeignKeyConstraint(
            ["city_id"], ["cities.id"], ondelete="SET NULL", name="people_city_id_fkey"
        ),
        PrimaryKeyConstraint("id", name="people_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    full_name: Mapped[str] = mapped_column(String(150))
    birth_date: Mapped[datetime.date] = mapped_column(Date)
    city_id: Mapped[Optional[int]] = mapped_column(Integer)
    height: Mapped[Optional[decimal.Decimal]] = mapped_column(Numeric(4, 2))
    weight: Mapped[Optional[decimal.Decimal]] = mapped_column(Numeric(5, 2))
    official_website: Mapped[Optional[str]] = mapped_column(String(255))

    country: Mapped[List["Countries"]] = relationship(
        "Countries", secondary="person_country", back_populates="person"
    )
    characteristic: Mapped[List["Characteristics"]] = relationship(
        "Characteristics", secondary="person_characteristic", back_populates="person"
    )
    city: Mapped[Optional["Cities"]] = relationship("Cities", back_populates="people")
    league_committee: Mapped[List["LeagueCommittee"]] = relationship(
        "LeagueCommittee", back_populates="person"
    )
    person_entity: Mapped[List["PersonEntity"]] = relationship(
        "PersonEntity", back_populates="person"
    )
    person_federation: Mapped[List["PersonFederation"]] = relationship(
        "PersonFederation", back_populates="person"
    )
    person_social_links: Mapped[List["PersonSocialLinks"]] = relationship(
        "PersonSocialLinks", back_populates="person"
    )
    league_edition_group_participants: Mapped[
        List["LeagueEditionGroupParticipants"]
    ] = relationship("LeagueEditionGroupParticipants", back_populates="person")
    league_edition_standings: Mapped[List["LeagueEditionStandings"]] = relationship(
        "LeagueEditionStandings", back_populates="person"
    )
    team_players: Mapped[List["TeamPlayers"]] = relationship(
        "TeamPlayers", back_populates="person"
    )
    match_events: Mapped[List["MatchEvents"]] = relationship(
        "MatchEvents", back_populates="player"
    )
    match_participants: Mapped[List["MatchParticipants"]] = relationship(
        "MatchParticipants", back_populates="player"
    )
    match_player_statistics: Mapped[List["MatchPlayerStatistics"]] = relationship(
        "MatchPlayerStatistics", back_populates="player"
    )
    match_results: Mapped[List["MatchResults"]] = relationship(
        "MatchResults", back_populates="winner_player"
    )
    match_scores: Mapped[List["MatchScores"]] = relationship(
        "MatchScores", back_populates="player"
    )


class EntityBrand(Base):
    __tablename__ = "entity_brand"
    __table_args__ = (
        ForeignKeyConstraint(
            ["brand_id"],
            ["uniform_brands.id"],
            ondelete="CASCADE",
            name="entity_brand_brand_id_fkey",
        ),
        ForeignKeyConstraint(
            ["entity_id"],
            ["entities.id"],
            ondelete="CASCADE",
            name="entity_brand_entity_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="entity_brand_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    entity_id: Mapped[int] = mapped_column(Integer)
    brand_id: Mapped[int] = mapped_column(Integer)
    start_date: Mapped[datetime.date] = mapped_column(Date)
    end_date: Mapped[Optional[datetime.date]] = mapped_column(Date)

    brand: Mapped["UniformBrands"] = relationship(
        "UniformBrands", back_populates="entity_brand"
    )
    entity: Mapped["Entities"] = relationship("Entities", back_populates="entity_brand")


t_entity_federation = Table(
    "entity_federation",
    Base.metadata,
    Column("entity_id", Integer, primary_key=True, nullable=False),
    Column("federation_id", Integer, primary_key=True, nullable=False),
    ForeignKeyConstraint(
        ["entity_id"],
        ["entities.id"],
        ondelete="CASCADE",
        name="entity_federation_entity_id_fkey",
    ),
    ForeignKeyConstraint(
        ["federation_id"],
        ["federations.id"],
        ondelete="CASCADE",
        name="entity_federation_federation_id_fkey",
    ),
    PrimaryKeyConstraint("entity_id", "federation_id", name="entity_federation_pkey"),
)


class EntitySponsor(Base):
    __tablename__ = "entity_sponsor"
    __table_args__ = (
        ForeignKeyConstraint(
            ["entity_id"],
            ["entities.id"],
            ondelete="CASCADE",
            name="entity_sponsor_entity_id_fkey",
        ),
        ForeignKeyConstraint(
            ["sponsor_id"],
            ["sponsors.id"],
            ondelete="CASCADE",
            name="entity_sponsor_sponsor_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="entity_sponsor_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    entity_id: Mapped[int] = mapped_column(Integer)
    sponsor_id: Mapped[int] = mapped_column(Integer)
    start_date: Mapped[datetime.date] = mapped_column(Date)
    end_date: Mapped[Optional[datetime.date]] = mapped_column(Date)

    entity: Mapped["Entities"] = relationship(
        "Entities", back_populates="entity_sponsor"
    )
    sponsor: Mapped["Sponsors"] = relationship(
        "Sponsors", back_populates="entity_sponsor"
    )


class LeagueCommittee(Base):
    __tablename__ = "league_committee"
    __table_args__ = (
        CheckConstraint(
            "role::text = ANY (ARRAY['director'::character varying, 'referee_manager'::character varying, 'disciplinary_manager'::character varying, 'marketing_manager'::character varying, 'operations_manager'::character varying]::text[])",
            name="league_committee_role_check",
        ),
        ForeignKeyConstraint(
            ["league_edition_id"],
            ["league_editions.id"],
            ondelete="CASCADE",
            name="league_committee_league_edition_id_fkey",
        ),
        ForeignKeyConstraint(
            ["person_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="league_committee_person_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="league_committee_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    league_edition_id: Mapped[int] = mapped_column(Integer)
    person_id: Mapped[int] = mapped_column(Integer)
    role: Mapped[str] = mapped_column(String(100))
    start_date: Mapped[datetime.date] = mapped_column(Date)
    end_date: Mapped[Optional[datetime.date]] = mapped_column(Date)

    league_edition: Mapped["LeagueEditions"] = relationship(
        "LeagueEditions", back_populates="league_committee"
    )
    person: Mapped["People"] = relationship("People", back_populates="league_committee")


class LeagueEditionGroupings(Base):
    __tablename__ = "league_edition_groupings"
    __table_args__ = (
        CheckConstraint("level > 0", name="league_edition_groupings_level_check"),
        CheckConstraint(
            "phase::text = ANY (ARRAY['group_stage'::character varying, 'knockout'::character varying, 'final'::character varying]::text[])",
            name="league_edition_groupings_phase_check",
        ),
        ForeignKeyConstraint(
            ["league_edition_id"],
            ["league_editions.id"],
            ondelete="CASCADE",
            name="league_edition_groupings_league_edition_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="league_edition_groupings_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    league_edition_id: Mapped[int] = mapped_column(Integer)
    phase: Mapped[str] = mapped_column(String(50))
    level: Mapped[int] = mapped_column(Integer)
    classification_rule: Mapped[dict] = mapped_column(JSONB)

    league_edition: Mapped["LeagueEditions"] = relationship(
        "LeagueEditions", back_populates="league_edition_groupings"
    )
    league_edition_group_participants: Mapped[
        List["LeagueEditionGroupParticipants"]
    ] = relationship(
        "LeagueEditionGroupParticipants", back_populates="league_edition_grouping"
    )
    matches: Mapped[List["Matches"]] = relationship(
        "Matches", back_populates="league_edition_grouping"
    )


t_person_characteristic = Table(
    "person_characteristic",
    Base.metadata,
    Column("person_id", Integer, primary_key=True, nullable=False),
    Column("characteristic_id", Integer, primary_key=True, nullable=False),
    ForeignKeyConstraint(
        ["characteristic_id"],
        ["characteristics.id"],
        ondelete="CASCADE",
        name="person_characteristic_characteristic_id_fkey",
    ),
    ForeignKeyConstraint(
        ["person_id"],
        ["people.id"],
        ondelete="CASCADE",
        name="person_characteristic_person_id_fkey",
    ),
    PrimaryKeyConstraint(
        "person_id", "characteristic_id", name="person_characteristic_pkey"
    ),
)


t_person_country = Table(
    "person_country",
    Base.metadata,
    Column("person_id", Integer, primary_key=True, nullable=False),
    Column("country_id", Integer, primary_key=True, nullable=False),
    ForeignKeyConstraint(
        ["country_id"],
        ["countries.id"],
        ondelete="SET NULL",
        name="person_country_country_id_fkey",
    ),
    ForeignKeyConstraint(
        ["person_id"],
        ["people.id"],
        ondelete="CASCADE",
        name="person_country_person_id_fkey",
    ),
    PrimaryKeyConstraint("person_id", "country_id", name="person_country_pkey"),
)


class PersonEntity(Base):
    __tablename__ = "person_entity"
    __table_args__ = (
        ForeignKeyConstraint(
            ["entity_id"],
            ["entities.id"],
            ondelete="CASCADE",
            name="person_entity_entity_id_fkey",
        ),
        ForeignKeyConstraint(
            ["person_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="person_entity_person_id_fkey",
        ),
        ForeignKeyConstraint(
            ["role_id"],
            ["roles.id"],
            ondelete="SET NULL",
            name="person_entity_role_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="person_entity_pkey"),
        UniqueConstraint(
            "person_id",
            "entity_id",
            "role_id",
            "start_date",
            name="unique_person_entity",
        ),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    person_id: Mapped[int] = mapped_column(Integer)
    entity_id: Mapped[int] = mapped_column(Integer)
    start_date: Mapped[datetime.date] = mapped_column(Date)
    is_active: Mapped[bool] = mapped_column(Boolean, server_default=text("true"))
    role_id: Mapped[Optional[int]] = mapped_column(Integer)
    end_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    salary: Mapped[Optional[decimal.Decimal]] = mapped_column(Numeric(10, 2))
    notes: Mapped[Optional[str]] = mapped_column(Text)

    entity: Mapped["Entities"] = relationship(
        "Entities", back_populates="person_entity"
    )
    person: Mapped["People"] = relationship("People", back_populates="person_entity")
    role: Mapped[Optional["Roles"]] = relationship(
        "Roles", back_populates="person_entity"
    )


class PersonFederation(Base):
    __tablename__ = "person_federation"
    __table_args__ = (
        ForeignKeyConstraint(
            ["federation_id"],
            ["federations.id"],
            ondelete="CASCADE",
            name="person_federation_federation_id_fkey",
        ),
        ForeignKeyConstraint(
            ["person_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="person_federation_person_id_fkey",
        ),
        ForeignKeyConstraint(
            ["role_id"],
            ["roles.id"],
            ondelete="SET NULL",
            name="person_federation_role_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="person_federation_pkey"),
        UniqueConstraint(
            "person_id",
            "federation_id",
            "role_id",
            "start_date",
            name="unique_person_federation",
        ),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    person_id: Mapped[int] = mapped_column(Integer)
    federation_id: Mapped[int] = mapped_column(Integer)
    start_date: Mapped[datetime.date] = mapped_column(Date)
    is_active: Mapped[bool] = mapped_column(Boolean, server_default=text("true"))
    role_id: Mapped[Optional[int]] = mapped_column(Integer)
    end_date: Mapped[Optional[datetime.date]] = mapped_column(Date)
    department: Mapped[Optional[str]] = mapped_column(String(100))
    responsibilities: Mapped[Optional[str]] = mapped_column(Text)

    federation: Mapped["Federations"] = relationship(
        "Federations", back_populates="person_federation"
    )
    person: Mapped["People"] = relationship(
        "People", back_populates="person_federation"
    )
    role: Mapped[Optional["Roles"]] = relationship(
        "Roles", back_populates="person_federation"
    )


class PersonSocialLinks(Base):
    __tablename__ = "person_social_links"
    __table_args__ = (
        ForeignKeyConstraint(
            ["person_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="person_social_links_person_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="person_social_links_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    person_id: Mapped[int] = mapped_column(Integer)
    platform: Mapped[str] = mapped_column(String(50))
    url: Mapped[str] = mapped_column(String(255))

    person: Mapped["People"] = relationship(
        "People", back_populates="person_social_links"
    )


class Teams(Base):
    __tablename__ = "teams"
    __table_args__ = (
        ForeignKeyConstraint(
            ["category_id"],
            ["categories.id"],
            ondelete="CASCADE",
            name="teams_category_id_fkey",
        ),
        ForeignKeyConstraint(
            ["entity_id"],
            ["entities.id"],
            ondelete="CASCADE",
            name="teams_entity_id_fkey",
        ),
        ForeignKeyConstraint(
            ["sport_id"], ["sports.id"], ondelete="CASCADE", name="teams_sport_id_fkey"
        ),
        PrimaryKeyConstraint("id", name="teams_pkey"),
        UniqueConstraint("entity_id", "name", "sport_id", name="unique_team_name"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    entity_id: Mapped[int] = mapped_column(Integer)
    name: Mapped[str] = mapped_column(String(100))
    category_id: Mapped[int] = mapped_column(Integer)
    sport_id: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[Optional[datetime.datetime]] = mapped_column(
        DateTime, server_default=text("CURRENT_TIMESTAMP")
    )

    category: Mapped["Categories"] = relationship("Categories", back_populates="teams")
    entity: Mapped["Entities"] = relationship("Entities", back_populates="teams")
    sport: Mapped["Sports"] = relationship("Sports", back_populates="teams")
    league_edition_group_participants: Mapped[
        List["LeagueEditionGroupParticipants"]
    ] = relationship("LeagueEditionGroupParticipants", back_populates="team")
    league_edition_standings: Mapped[List["LeagueEditionStandings"]] = relationship(
        "LeagueEditionStandings", back_populates="team"
    )
    league_edition_teams: Mapped[List["LeagueEditionTeams"]] = relationship(
        "LeagueEditionTeams", back_populates="team"
    )
    team_players: Mapped[List["TeamPlayers"]] = relationship(
        "TeamPlayers", back_populates="team"
    )
    match_events: Mapped[List["MatchEvents"]] = relationship(
        "MatchEvents", back_populates="team"
    )
    match_participants: Mapped[List["MatchParticipants"]] = relationship(
        "MatchParticipants", back_populates="team"
    )
    match_player_statistics: Mapped[List["MatchPlayerStatistics"]] = relationship(
        "MatchPlayerStatistics", back_populates="team"
    )
    match_results: Mapped[List["MatchResults"]] = relationship(
        "MatchResults", back_populates="winner_team"
    )
    match_scores: Mapped[List["MatchScores"]] = relationship(
        "MatchScores", back_populates="team"
    )


class LeagueEditionGroupParticipants(Base):
    __tablename__ = "league_edition_group_participants"
    __table_args__ = (
        ForeignKeyConstraint(
            ["league_edition_grouping_id"],
            ["league_edition_groupings.id"],
            ondelete="CASCADE",
            name="league_edition_group_participan_league_edition_grouping_id_fkey",
        ),
        ForeignKeyConstraint(
            ["person_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="league_edition_group_participants_person_id_fkey",
        ),
        ForeignKeyConstraint(
            ["team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="league_edition_group_participants_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="league_edition_group_participants_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    league_edition_grouping_id: Mapped[int] = mapped_column(Integer)
    matches_played: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    wins: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    draws: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    losses: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    goals_for: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    goals_against: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    goal_difference: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    points: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    team_id: Mapped[Optional[int]] = mapped_column(Integer)
    person_id: Mapped[Optional[int]] = mapped_column(Integer)
    total_time: Mapped[Optional[decimal.Decimal]] = mapped_column(
        Numeric(10, 2), server_default=text("0")
    )
    total_score: Mapped[Optional[decimal.Decimal]] = mapped_column(
        Numeric(10, 2), server_default=text("0")
    )
    ranking: Mapped[Optional[int]] = mapped_column(Integer)

    league_edition_grouping: Mapped["LeagueEditionGroupings"] = relationship(
        "LeagueEditionGroupings", back_populates="league_edition_group_participants"
    )
    person: Mapped[Optional["People"]] = relationship(
        "People", back_populates="league_edition_group_participants"
    )
    team: Mapped[Optional["Teams"]] = relationship(
        "Teams", back_populates="league_edition_group_participants"
    )


class LeagueEditionStandings(Base):
    __tablename__ = "league_edition_standings"
    __table_args__ = (
        ForeignKeyConstraint(
            ["league_edition_id"],
            ["league_editions.id"],
            ondelete="CASCADE",
            name="league_edition_standings_league_edition_id_fkey",
        ),
        ForeignKeyConstraint(
            ["person_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="league_edition_standings_person_id_fkey",
        ),
        ForeignKeyConstraint(
            ["team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="league_edition_standings_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="league_edition_standings_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    league_edition_id: Mapped[int] = mapped_column(Integer)
    matches_played: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    wins: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    draws: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    losses: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    goals_for: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    goals_against: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    goal_difference: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    points: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    team_id: Mapped[Optional[int]] = mapped_column(Integer)
    person_id: Mapped[Optional[int]] = mapped_column(Integer)
    total_time: Mapped[Optional[decimal.Decimal]] = mapped_column(
        Numeric(10, 2), server_default=text("0")
    )
    total_score: Mapped[Optional[decimal.Decimal]] = mapped_column(
        Numeric(10, 2), server_default=text("0")
    )
    ranking: Mapped[Optional[int]] = mapped_column(Integer)

    league_edition: Mapped["LeagueEditions"] = relationship(
        "LeagueEditions", back_populates="league_edition_standings"
    )
    person: Mapped[Optional["People"]] = relationship(
        "People", back_populates="league_edition_standings"
    )
    team: Mapped[Optional["Teams"]] = relationship(
        "Teams", back_populates="league_edition_standings"
    )


class LeagueEditionTeams(Base):
    __tablename__ = "league_edition_teams"
    __table_args__ = (
        ForeignKeyConstraint(
            ["league_edition_id"],
            ["league_editions.id"],
            ondelete="CASCADE",
            name="league_edition_teams_league_edition_id_fkey",
        ),
        ForeignKeyConstraint(
            ["team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="league_edition_teams_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="league_edition_teams_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    league_edition_id: Mapped[int] = mapped_column(Integer)
    team_id: Mapped[int] = mapped_column(Integer)
    max_registered_players: Mapped[int] = mapped_column(
        Integer, server_default=text("30")
    )
    registration_date: Mapped[Optional[datetime.datetime]] = mapped_column(
        DateTime, server_default=text("CURRENT_TIMESTAMP")
    )

    league_edition: Mapped["LeagueEditions"] = relationship(
        "LeagueEditions", back_populates="league_edition_teams"
    )
    team: Mapped["Teams"] = relationship("Teams", back_populates="league_edition_teams")


class Matches(Base):
    __tablename__ = "matches"
    __table_args__ = (
        CheckConstraint("leg >= 1", name="matches_leg_check"),
        CheckConstraint(
            "status::text = ANY (ARRAY['scheduled'::character varying, 'ongoing'::character varying, 'completed'::character varying, 'cancelled'::character varying]::text[])",
            name="matches_status_check",
        ),
        ForeignKeyConstraint(
            ["league_edition_grouping_id"],
            ["league_edition_groupings.id"],
            ondelete="CASCADE",
            name="matches_league_edition_grouping_id_fkey",
        ),
        ForeignKeyConstraint(
            ["location_id"],
            ["locations.id"],
            ondelete="CASCADE",
            name="matches_location_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="matches_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    league_edition_grouping_id: Mapped[int] = mapped_column(Integer)
    date: Mapped[datetime.datetime] = mapped_column(DateTime)
    location_id: Mapped[int] = mapped_column(Integer)
    status: Mapped[str] = mapped_column(String(20))
    match_number: Mapped[Optional[int]] = mapped_column(Integer)
    leg: Mapped[Optional[int]] = mapped_column(Integer, server_default=text("1"))

    league_edition_grouping: Mapped["LeagueEditionGroupings"] = relationship(
        "LeagueEditionGroupings", back_populates="matches"
    )
    location: Mapped["Locations"] = relationship("Locations", back_populates="matches")
    match_events: Mapped[List["MatchEvents"]] = relationship(
        "MatchEvents", back_populates="match"
    )
    match_participants: Mapped[List["MatchParticipants"]] = relationship(
        "MatchParticipants", back_populates="match"
    )
    match_player_statistics: Mapped[List["MatchPlayerStatistics"]] = relationship(
        "MatchPlayerStatistics", back_populates="match"
    )
    match_reports: Mapped[List["MatchReports"]] = relationship(
        "MatchReports", back_populates="match"
    )
    match_results: Mapped[List["MatchResults"]] = relationship(
        "MatchResults", back_populates="match"
    )
    match_scores: Mapped[List["MatchScores"]] = relationship(
        "MatchScores", back_populates="match"
    )


class TeamPlayers(Base):
    __tablename__ = "team_players"
    __table_args__ = (
        CheckConstraint(
            "shirt_number > 0 AND shirt_number <= 99",
            name="team_players_shirt_number_check",
        ),
        CheckConstraint(
            "status::text = ANY (ARRAY['active'::character varying, 'inactive'::character varying, 'loaned'::character varying, 'injured'::character varying, 'suspended'::character varying, 'staff'::character varying, 'released'::character varying]::text[])",
            name="team_players_status_check",
        ),
        ForeignKeyConstraint(
            ["person_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="team_players_person_id_fkey",
        ),
        ForeignKeyConstraint(
            ["role_id"],
            ["roles.id"],
            ondelete="SET NULL",
            name="team_players_role_id_fkey",
        ),
        ForeignKeyConstraint(
            ["team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="team_players_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="team_players_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    team_id: Mapped[int] = mapped_column(Integer)
    person_id: Mapped[int] = mapped_column(Integer)
    status: Mapped[str] = mapped_column(String(20))
    role_id: Mapped[Optional[int]] = mapped_column(Integer)
    shirt_number: Mapped[Optional[int]] = mapped_column(Integer)
    created_at: Mapped[Optional[datetime.datetime]] = mapped_column(
        DateTime, server_default=text("CURRENT_TIMESTAMP")
    )

    person: Mapped["People"] = relationship("People", back_populates="team_players")
    role: Mapped[Optional["Roles"]] = relationship(
        "Roles", back_populates="team_players"
    )
    team: Mapped["Teams"] = relationship("Teams", back_populates="team_players")


class MatchEvents(Base):
    __tablename__ = "match_events"
    __table_args__ = (
        CheckConstraint(
            "event_type::text = ANY (ARRAY['goal'::character varying, 'assist'::character varying, 'yellow_card'::character varying, 'red_card'::character varying, 'substitution'::character varying, 'foul'::character varying]::text[])",
            name="match_events_event_type_check",
        ),
        ForeignKeyConstraint(
            ["match_id"],
            ["matches.id"],
            ondelete="CASCADE",
            name="match_events_match_id_fkey",
        ),
        ForeignKeyConstraint(
            ["player_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="match_events_player_id_fkey",
        ),
        ForeignKeyConstraint(
            ["team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="match_events_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="match_events_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    match_id: Mapped[int] = mapped_column(Integer)
    player_id: Mapped[int] = mapped_column(Integer)
    event_type: Mapped[str] = mapped_column(String(20))
    event_time: Mapped[int] = mapped_column(Integer)
    team_id: Mapped[Optional[int]] = mapped_column(Integer)
    extra_info: Mapped[Optional[str]] = mapped_column(Text)

    match: Mapped["Matches"] = relationship("Matches", back_populates="match_events")
    player: Mapped["People"] = relationship("People", back_populates="match_events")
    team: Mapped[Optional["Teams"]] = relationship(
        "Teams", back_populates="match_events"
    )


class MatchParticipants(Base):
    __tablename__ = "match_participants"
    __table_args__ = (
        CheckConstraint(
            '"position" IS NULL OR player_id IS NOT NULL AND team_id IS NULL',
            name="match_participants_check",
        ),
        CheckConstraint(
            "score_type::text = ANY (ARRAY['none'::character varying, 'goals'::character varying, 'points'::character varying, 'time'::character varying, 'sets'::character varying, 'distance'::character varying]::text[])",
            name="match_participants_score_type_check",
        ),
        ForeignKeyConstraint(
            ["match_id"],
            ["matches.id"],
            ondelete="CASCADE",
            name="match_participants_match_id_fkey",
        ),
        ForeignKeyConstraint(
            ["player_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="match_participants_player_id_fkey",
        ),
        ForeignKeyConstraint(
            ["team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="match_participants_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="match_participants_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    match_id: Mapped[int] = mapped_column(Integer)
    score_type: Mapped[str] = mapped_column(String(20))
    team_id: Mapped[Optional[int]] = mapped_column(Integer)
    player_id: Mapped[Optional[int]] = mapped_column(Integer)
    position: Mapped[Optional[int]] = mapped_column(Integer)
    score: Mapped[Optional[decimal.Decimal]] = mapped_column(
        Numeric(10, 2), server_default=text("NULL::numeric")
    )
    is_winner: Mapped[Optional[bool]] = mapped_column(
        Boolean, server_default=text("false")
    )

    match: Mapped["Matches"] = relationship(
        "Matches", back_populates="match_participants"
    )
    player: Mapped[Optional["People"]] = relationship(
        "People", back_populates="match_participants"
    )
    team: Mapped[Optional["Teams"]] = relationship(
        "Teams", back_populates="match_participants"
    )


class MatchPlayerStatistics(Base):
    __tablename__ = "match_player_statistics"
    __table_args__ = (
        ForeignKeyConstraint(
            ["match_id"],
            ["matches.id"],
            ondelete="CASCADE",
            name="match_player_statistics_match_id_fkey",
        ),
        ForeignKeyConstraint(
            ["player_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="match_player_statistics_player_id_fkey",
        ),
        ForeignKeyConstraint(
            ["team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="match_player_statistics_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="match_player_statistics_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    match_id: Mapped[int] = mapped_column(Integer)
    player_id: Mapped[int] = mapped_column(Integer)
    minutes_played: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    goals: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    assists: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    shots: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    passes: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    fouls_committed: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    yellow_cards: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    red_cards: Mapped[int] = mapped_column(Integer, server_default=text("0"))
    team_id: Mapped[Optional[int]] = mapped_column(Integer)

    match: Mapped["Matches"] = relationship(
        "Matches", back_populates="match_player_statistics"
    )
    player: Mapped["People"] = relationship(
        "People", back_populates="match_player_statistics"
    )
    team: Mapped[Optional["Teams"]] = relationship(
        "Teams", back_populates="match_player_statistics"
    )


class MatchReports(Base):
    __tablename__ = "match_reports"
    __table_args__ = (
        ForeignKeyConstraint(
            ["match_id"],
            ["matches.id"],
            ondelete="CASCADE",
            name="match_reports_match_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="match_reports_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    match_id: Mapped[int] = mapped_column(Integer)
    report: Mapped[str] = mapped_column(Text)
    created_at: Mapped[Optional[datetime.datetime]] = mapped_column(
        DateTime, server_default=text("CURRENT_TIMESTAMP")
    )

    match: Mapped["Matches"] = relationship("Matches", back_populates="match_reports")


class MatchResults(Base):
    __tablename__ = "match_results"
    __table_args__ = (
        ForeignKeyConstraint(
            ["match_id"],
            ["matches.id"],
            ondelete="CASCADE",
            name="match_results_match_id_fkey",
        ),
        ForeignKeyConstraint(
            ["winner_player_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="match_results_winner_player_id_fkey",
        ),
        ForeignKeyConstraint(
            ["winner_team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="match_results_winner_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="match_results_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    match_id: Mapped[int] = mapped_column(Integer)
    winner_team_id: Mapped[Optional[int]] = mapped_column(Integer)
    winner_player_id: Mapped[Optional[int]] = mapped_column(Integer)
    is_draw: Mapped[Optional[bool]] = mapped_column(
        Boolean, server_default=text("false")
    )
    details: Mapped[Optional[dict]] = mapped_column(JSONB)

    match: Mapped["Matches"] = relationship("Matches", back_populates="match_results")
    winner_player: Mapped[Optional["People"]] = relationship(
        "People", back_populates="match_results"
    )
    winner_team: Mapped[Optional["Teams"]] = relationship(
        "Teams", back_populates="match_results"
    )


class MatchScores(Base):
    __tablename__ = "match_scores"
    __table_args__ = (
        ForeignKeyConstraint(
            ["match_id"],
            ["matches.id"],
            ondelete="CASCADE",
            name="match_scores_match_id_fkey",
        ),
        ForeignKeyConstraint(
            ["player_id"],
            ["people.id"],
            ondelete="CASCADE",
            name="match_scores_player_id_fkey",
        ),
        ForeignKeyConstraint(
            ["team_id"],
            ["teams.id"],
            ondelete="CASCADE",
            name="match_scores_team_id_fkey",
        ),
        PrimaryKeyConstraint("id", name="match_scores_pkey"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    match_id: Mapped[int] = mapped_column(Integer)
    period: Mapped[int] = mapped_column(Integer)
    score: Mapped[int] = mapped_column(Integer)
    team_id: Mapped[Optional[int]] = mapped_column(Integer)
    player_id: Mapped[Optional[int]] = mapped_column(Integer)

    match: Mapped["Matches"] = relationship("Matches", back_populates="match_scores")
    player: Mapped[Optional["People"]] = relationship(
        "People", back_populates="match_scores"
    )
    team: Mapped[Optional["Teams"]] = relationship(
        "Teams", back_populates="match_scores"
    )
