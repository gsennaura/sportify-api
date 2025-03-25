class FakeCountryRepository:
    def __init__(self, countries):
        self._countries = countries

    async def get_by_id(self, country_id: int):
        return self._countries.get(country_id)

    async def get_all(self):
        return list(self._countries.values())

    async def create(self, country):
        new_id = max(self._countries.keys(), default=0) + 1
        country.id = new_id
        self._countries[new_id] = country
        return country

    async def delete(self, country_id: int):
        return self._countries.pop(country_id, None)

    async def update(self, country_id: int, update_data: dict):
        country = self._countries.get(country_id)
        if not country:
            return None
        for key, value in update_data.items():
            setattr(country, key, value)
        return country

    async def get_by_iso_code(self, iso_code: str):
        for country in self._countries.values():
            if country.iso_code == iso_code:
                return country
        return None

    async def create_many_deferred(self, countries):
        start_id = max(self._countries.keys(), default=0) + 1
        for i, country in enumerate(countries):
            country.id = start_id + i
            self._countries[country.id] = country
        return countries
