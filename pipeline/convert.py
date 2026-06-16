import pandas as pd
from pathlib import Path

from config import LOCAL_DATA_PATH, PARQUET_DIR
from extract import get_all_csvs, read_csv


def convert_all_to_parquet(
    source_dir: Path | None = None,
    output_dir: Path | None = None,
) -> None:
    """Convert all CSV files in source_dir to Parquet files in output_dir."""
    base_dir = Path(source_dir or LOCAL_DATA_PATH)
    parquet_dir = Path(output_dir or PARQUET_DIR)

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
