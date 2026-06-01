import pandas as pd
from pathlib import Path

# pyrefly: ignore [missing-import]
from config import LOCAL_DATA_PATH, PARQUET_DIR


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


def convert_all_to_parquet() -> None:
    # Fix: ensure both config values are Path objects
    base_dir = Path(LOCAL_DATA_PATH)
    parquet_dir = Path(PARQUET_DIR)

    parquet_dir.mkdir(parents=True, exist_ok=True)

    files = get_all_csvs(base_dir)

    if not files:
        print(f"No CSV files found under: {base_dir}")
        return

    print(f"Found {len(files)} CSV file(s). Converting...\n")

    success, failed = 0, 0

    for csv_path in files:
        out_path = parquet_dir / csv_path.with_suffix(".parquet").name
        try:
            df = read_csv(csv_path)
            df.to_parquet(out_path, index=False, engine="pyarrow")
            print(f"  ✔ {csv_path.name} → {out_path.name} ({len(df):,} rows)")
            success += 1
        except Exception as e:
            print(f"  ✘ Failed to convert '{csv_path.name}': {e}")
            failed += 1
            continue

    print(f"\nDone. {success} succeeded, {failed} failed.")


if __name__ == "__main__":
    convert_all_to_parquet()