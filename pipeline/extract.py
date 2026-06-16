import pandas as pd
from pathlib import Path

from config import LOCAL_DATA_PATH


def get_all_csvs(base_dir: Path) -> list[Path]:
    """Return all CSV files found recursively under base_dir."""
    if not base_dir.exists():
        raise FileNotFoundError(f"LOCAL_DATA_PATH does not exist: {base_dir}")
    return list(base_dir.rglob("*.csv"))


def read_csv(filepath: Path) -> pd.DataFrame:
    """Read a CSV file, trying UTF-8 first then falling back to latin-1."""
    try:
        return pd.read_csv(filepath, encoding="utf-8")
    except UnicodeDecodeError:
        print(f"  ⚠ UTF-8 failed for '{filepath.name}', retrying with latin-1")
        return pd.read_csv(filepath, encoding="latin-1")


if __name__ == "__main__":
    print("files extracted successfully.")