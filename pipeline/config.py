import os
from dotenv import load_dotenv
from pathlib import Path
from sqlalchemy.engine import URL

load_dotenv()

BASE_DIR = Path(__file__).resolve().parent.parent

# --- Local data source ---
data_dir = os.getenv("DATA_DIR")

if not data_dir:
    raise ValueError("DATA_DIR environment variable is required")

LOCAL_DATA_PATH = Path(data_dir)

if not LOCAL_DATA_PATH.exists():
    raise FileNotFoundError(f"DATA_DIR does not exist: {LOCAL_DATA_PATH}")

# --- Internal project directories ---
PARQUET_DIR = BASE_DIR / "data" / "parquet"

if not PARQUET_DIR.exists():
    raise FileNotFoundError(f"PARQUET_DIR does not exist: {PARQUET_DIR}")

# --- Database credentials ---
DB_CONFIG = {
    "host": os.getenv("DB_HOST"),
    "username": os.getenv("DB_USER"),
    "database": os.getenv("DB_NAME"),
    "port": os.getenv("DB_PORT"),
    "password": os.getenv("DB_PASSWORD"),
}

missing_vars = [key for key, value in DB_CONFIG.items() if not value]

if missing_vars:
    raise ValueError(f"Missing database environment variables: {missing_vars}")

try:
    db_port = int(DB_CONFIG["port"])
except (TypeError, ValueError):
    raise ValueError(f"DB_PORT must be a valid integer, got: {DB_CONFIG['port']!r}")

DATABASE_URL = URL.create(
    drivername="postgresql+psycopg2",
    host=DB_CONFIG["host"],
    username=DB_CONFIG["username"],
    database=DB_CONFIG["database"],
    port=db_port,
    password=DB_CONFIG["password"],
)


if __name__ == "__main__":
    print("Configuration loaded successfully")
    print(f"Local Data Path  : {LOCAL_DATA_PATH}")
    print(f"Parquet Directory: {PARQUET_DIR}")
    print(f"Database Host    : {DB_CONFIG['host']}")
    print(f"Database Name    : {DB_CONFIG['database']}")