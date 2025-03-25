from typing import Type


class FakeUnitOfWork:
    """
    Fake Unit of Work for testing purposes.
    Allows injection of mock repositories.
    """

    def __init__(self, repo):
        self._repo = repo

    def get_repository(self, repo_type: Type):
        return self._repo
