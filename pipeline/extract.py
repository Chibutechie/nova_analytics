import pandas as pd
from pathlib import Path
import pyarrow as pa
from config import LOCAL_DATA_PATH, PARQUET_DIR


def get_all_csvs() -> list[Path]:
    """Return all CSV files found recursively under LOCAL_DATA_PATH."""
    return list(LOCAL_DATA_PATH.rglob("*.csv"))


def read_csv(filepath: Path) -> pd.DataFrame:
    """Read a CSV file and return it as a DataFrame."""
    return pd.read_csv(filepath)


def convert_all_to_parquet() -> None:
    PARQUET_DIR.mkdir(parents=True, exist_ok=True)    
    files = get_all_csvs()

    if not files:
        print("No CSV files found. Check your LOCAL_DATA_DIR.")
        return

    for csv_path in files:
        df = read_csv(csv_path)
        out_path = PARQUET_DIR / csv_path.with_suffix(".parquet").name
        df.to_parquet(out_path, index=False, engine="pyarrow")
        print(f"  ✔ {csv_path.name} → {out_path.name} ({len(df):,} rows)")


if __name__ == "__main__":
    convert_all_to_parquet()