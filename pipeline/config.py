import os
from dotenv import load_dotenv
from pathlib import Path

load_dotenv()

# base path directory
BASE_DIR=Path(__file__).resolve().parent.parent

# call local data source path from .env
data_dir = os.getenv("DATA_DIR")

if not data_dir:
    raise ValueError("DATA_DIR environment variable is required")

LOCAL_DATA_PATH = Path(data_dir)

if not LOCAL_DATA_PATH.exists():
    raise FileNotFoundError(
        f"DATA_DIR does not exist:{LOCAL_DATA_PATH}"
    )


# internal project diretories
PARQUET_DIR = BASE_DIR / "data" / "parquet"

PARQUET_DIR.mkdir(parents=True, exist_ok=True)


# database crendtials
DB_CONFIG = {
    "host":os.getenv("DB_HOST"),
    "user":os.getenv("DB_USER"),
    "dbname":os.getenv("DB_NAME"),
    "port":os.getenv("DB_PORT"),
    "password":os.getenv("DB_PASSWORD")
}


missing_vars = [key for key, value in DB_CONFIG.items() if value is None]

if missing_vars:
    raise ValueError(
        f"Missing Database Enviroment Variables: {missing_vars}"
    )

# database connection url
DATABASE_URL=f"postgresql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['dbname']}"

if __name__ == "__main__":
    print("Configuration loaded successfully")
    print(f"Local Data Path : {LOCAL_DATA_PATH}")
    print(f"Parquet Directory: {PARQUET_DIR}")
    print(f"Database Host   : {DB_CONFIG['host']}")
    print(f"Database Name   : {DB_CONFIG['dbname']}")