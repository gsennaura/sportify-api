/*
Load Order for SportifyAPI Database Schema

This file provides guidance on the proper loading order for the database creation scripts.
Follow this sequence when setting up a new database to ensure all dependencies are satisfied.

LOADING ORDER:
1. 01_location.sql - Countries, states, cities and venues
2. 02_people.sql - People, players, and role types
3. 03_organizations.sql - Sports, entities, federations
4. 04_categories.sql - Age groups and competition levels
5. 05_teams.sql - Teams, team categories, and player affiliations
6. 06_leagues.sql - Leagues and eligibility rules
7. 07_matches.sql - Matches and match statistics

KEY BUSINESS RULES IMPLEMENTED:

TEAM STRUCTURE:
- Teams have a location and a main stadium/venue
- Multiple teams can share the same stadium
- Teams have staff (presidents, directors, coaches)
- Teams have players (athletes)
- Teams can have multiple categories (age groups/competition levels)

PLAYER AFFILIATIONS:
- A player can represent different categories within the same team
- A player can only play for one team per league
- Whether a player can play for different teams in different leagues is customizable
- Federation-level restrictions: a player can only represent one team across all leagues in the same federation
- Cross-federation rules are configurable

COMPETITION ORGANIZATION:
- Federations organize leagues
- Leagues contain teams competing in a specific category

DATABASE SCHEMA DIAGRAM:
For a visual representation of this database schema, use a tool like
pgAdmin, DBeaver or DbSchema to generate an ERD from the database.
*/
