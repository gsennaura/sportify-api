# Use official Python image
FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Install Poetry
RUN pip install poetry

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Configure Poetry and install dependencies without creating a virtualenv
RUN poetry config virtualenvs.create false \
    && poetry install --no-root --no-interaction --no-ansi

# Copy the source code into the container
COPY ./src ./src

# Set PYTHONPATH to allow absolute imports from 'src/'
ENV PYTHONPATH="/app/src"

# Start the FastAPI application using Uvicorn with hot-reload
CMD ["uvicorn", "sportifyapi.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]