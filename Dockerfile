FROM python:3.12-slim

WORKDIR /app

RUN pip install poetry

COPY pyproject.toml poetry.lock ./
RUN poetry config virtualenvs.create false && poetry install --no-root --no-interaction --no-ansi

COPY ./src ./src

CMD ["uvicorn", "src.sportifyapi.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]