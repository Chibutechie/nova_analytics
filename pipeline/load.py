import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine
from pathlib import Path
from config import PARQUET_DIR, DATABASE_URL


def get_engine() -> Engine:
    return create_engine(DATABASE_URL)


def ensure_schema(engine: Engine, schema: str = "public") -> None:
    with engine.connect() as conn:
        conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {schema}"))
        conn.commit()


def load_all_parquets(schema: str = "raw") -> None:
    engine = get_engine()
    ensure_schema(engine, schema)

    for parquet_file in PARQUET_DIR.glob("*.parquet"):
        df = pd.read_parquet(parquet_file, engine="pyarrow")

        table_name = parquet_file.stem.lower().replace(" ", "_")

        # Truncate the table if it exists to avoid dropping dependent dbt views
        with engine.connect() as conn:
            try:
                conn.execute(text(f"TRUNCATE TABLE {schema}.{table_name}"))
                conn.commit()
            except Exception:
                conn.rollback()

        df.to_sql(
            name=table_name,
            con=engine,
            schema=schema,
            if_exists="append",
            index=False,
            chunksize=5000,
        )

        print(f"✔ Loaded {table_name} into {schema}.{table_name}")


if __name__ == "__main__":
    load_all_parquets()