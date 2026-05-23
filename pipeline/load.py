import pandas as pd
from sqlalchemy import create_engine, text
from pathlib import Path
from config import PARQUET_DIR, DATABASE_URL


def get_engine():
    return create_engine(DATABASE_URL)


def ensure_schema(engine, schema: str = "public"):
    with engine.connect() as conn:
        conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {schema}"))
        conn.commit()


def load_all_parquets(schema: str = "public"):
    engine = get_engine()
    ensure_schema(engine, schema)

    for parquet_file in PARQUET_DIR.glob("*.parquet"):
        df = pd.read_parquet(parquet_file, engine="pyarrow")

        table_name = parquet_file.stem.lower().replace(" ", "_")

        df.to_sql(
            name=table_name,
            con=engine,
            schema=schema,
            if_exists="replace",
            index=False,
            chunksize=5000,
        )

        print(f"✔ Loaded {table_name} into {schema}.{table_name}")


if __name__ == "__main__":
    load_all_parquets()