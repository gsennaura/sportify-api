import os

from dotenv import load_dotenv

# Load environment variables from the .env file
load_dotenv()


class Config:
    """Base configuration class."""

    DATABASE_URL = os.getenv("DATABASE_URL", None)
    """URL for connecting to the PostgreSQL database."""

    SECRET_KEY = os.getenv("SECRET_KEY", "your_secret_key")
    """A secret key for security-related operations."""

    DEBUG = os.getenv("DEBUG", "False") == "True"
    """Enables debugging mode if set to 'True'."""

    ENV = os.getenv("ENV", "development")
    """Environment type, such as 'development', 'production', or 'testing'."""

    LOGGING_LEVEL = os.getenv("LOGGING_LEVEL", "INFO")
    """Defines the level of logging (e.g., DEBUG, INFO, WARNING)."""


# Configuration class instance
config = Config()
