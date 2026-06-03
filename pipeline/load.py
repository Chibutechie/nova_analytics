import pandas as pd
from sqlalchemy import create_engine, text
from pathlib import Path
from config import PARQUET_DIR, DATABASE_URL


def get_engine():
    return create_engine(DATABASE_URL)


def ensure_schema(engine, schema: str = "public"):
    with engine.connect() as conn:
        conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS "{schema}"'))
        conn.commit()


def load_all_parquets(schema: str = "public"):
    engine = get_engine()
    ensure_schema(engine, schema)

    # Fix: ensure PARQUET_DIR is a Path object, not a raw string
    parquet_dir = Path(PARQUET_DIR)

    if not parquet_dir.exists():
        raise FileNotFoundError(f"PARQUET_DIR does not exist: {parquet_dir}")

    parquet_files = list(parquet_dir.glob("*.parquet"))

    if not parquet_files:
        print(f"No .parquet files found in {parquet_dir}")
        return
    
    for parquet_file in parquet_files:
        table_name = parquet_file.stem.lower().replace(" ", "_")

        try:  # ← indented inside the for loop
            df = pd.read_parquet(parquet_file)
            df['loaded_at'] = pd.Timestamp.now()

            with engine.connect() as conn:
                conn.execute(text(f'DROP TABLE IF EXISTS "{schema}"."{table_name}" CASCADE'))
                conn.commit()

            df.to_sql(
                name=table_name,
                con=engine,
                schema=schema,
                if_exists="append",
                index=False,
                chunksize=5000,
            )

            print(f"Loaded '{table_name}' ({len(df):,} rows) → {schema}.{table_name}")

        except Exception as e:
            print(f"Failed to load '{table_name}': {e}")
    print("\n Done.")


if __name__ == "__main__":
    import sys
    schema = sys.argv[1] if len(sys.argv) > 1 else "public"
    load_all_parquets(schema)
    