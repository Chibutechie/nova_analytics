# Pipeline Structure

The pipeline is responsible for extracting raw CSV data from a local source folder, converting it to Parquet, and loading it into PostgreSQL as the foundation for all downstream dbt transformations. It is built entirely in Python and runs as a single orchestrated process from `main.py`.

---

## Folder Structure

```
pipeline/
├── config.py       # Central configuration — paths and DB credentials
├── extract.py      # CSV discovery — scans source folder for CSV files
├── convert.py      # CSV → Parquet conversion
├── load.py         # Parquet → PostgreSQL loader
├── main.py         # Orchestrator — runs the full pipeline end to end
└── README.md
```

---

## How It Works

Each module has a single responsibility. They are chained together in `main.py` to run as one process:

```
Local CSV Folder
       │
       ▼
  [ config.py ]        Resolves source path, parquet output dir, DB connection
       │
       ▼
  [ extract.py ]       Scans the source folder and returns all CSV file paths
       │
       ▼
  [ convert.py ]       Reads each CSV into a DataFrame and writes it as Parquet
       │
       ▼
  [ load.py ]          Reads each Parquet file and loads it into PostgreSQL
```

---

## Source Data

CSV files are read directly from the local machine at:

```
C:\Users\LENOVO\OneDrive\Documents\novatrade
```

The pipeline recursively scans this folder for all `.csv` files on each run using `Path.rglob("*.csv")`. Any CSV file inside the folder or its subfolders is picked up automatically.

---

## Configuration — `config.py`

All pipeline settings are centralised here. This is the only file that needs updating if paths, credentials, or the database target changes.

```python
LOCAL_DATA_PATH
PARQUET_DIR
DB_URL
```

| Variable          | Description                                                         |
| ----------------- | ------------------------------------------------------------------- |
| `LOCAL_DATA_PATH` | Absolute path to the source CSV folder on the local machine         |
| `PARQUET_DIR`     | Output folder for intermediate Parquet files                        |
| `DB_CONFIG`       | Dictionary holding `host`, `port`, `dbname`, `user`, and `password` |
| `DB_URL`          | SQLAlchemy connection string assembled from `DB_CONFIG`             |

Credentials are loaded from a `.env` file using `python-dotenv`. A startup guard raises a clear `FileNotFoundError` if `LOCAL_DATA_PATH` does not exist, so the pipeline fails immediately with a readable message rather than a silent downstream error.

---

## Extraction — `extract.py`

Handles CSV discovery. Scans `LOCAL_DATA_PATH` recursively using `Path.rglob("*.csv")` and returns a list of all CSV file paths found. Logs a warning and exits cleanly if no files are found.

---

## Conversion — `convert.py`

Handles CSV to Parquet conversion. For each CSV path returned by `extract.py`:

- Reads the file into a Pandas DataFrame
- Writes it to `data/parquet/` as a `.parquet` file using PyArrow
- Creates the `data/parquet/` folder automatically if it does not exist
- Prints a confirmation with the row count per file

| Detail        | Value                                              |
| ------------- | -------------------------------------------------- |
| Read engine   | `pandas.read_csv`                                  |
| Write engine  | `pyarrow`                                          |
| Output folder | `data/parquet/`                                    |
| File naming   | Parquet file takes the same stem as the source CSV |

Parquet was chosen over loading CSV directly because it enforces column types on write, compresses well, and reads back significantly faster — especially as file sizes grow.

> `data/parquet/` is gitignored. It is a temporary intermediate regenerated on every pipeline run and should never be committed to version control.

---

## Loading — `load.py`

Handles loading Parquet files into PostgreSQL. Three responsibilities:

**1. Connection** — builds a SQLAlchemy engine from `DB_URL` in `config.py`.

**2. Schema creation** — runs `CREATE SCHEMA IF NOT EXISTS raw` before any load so the raw schema is always present without manual database setup.

**3. Loading** — reads each Parquet file into a DataFrame and writes it to the target PostgreSQL table using `DataFrame.to_sql()`.

| Detail        | Value                                                 |
| ------------- | ----------------------------------------------------- |
| Target schema | `raw`                                                 |
| Load strategy | `replace` — full reload on each run                   |
| Chunk size    | 5,000 rows per batch                                  |
| Table naming  | Filename lowercased, spaces replaced with underscores |
| Adapter       | `psycopg2-binary` via SQLAlchemy                      |

> The `replace` strategy drops and recreates each table on every run, guaranteeing the raw layer always reflects the source files exactly. Switch to `append` when moving to incremental loads.

---

## Raw Schema Tables

The following tables are produced in the `raw` schema after a full pipeline run:

| Table               | Source File     | Description                                                                        |
| ------------------- | --------------- | ---------------------------------------------------------------------------------- |
| `raw.ntg_sales`     | `sales.csv`     | Transaction-level records — quantity, unit price, discount, return flag, ship cost |
| `raw.ntg_customers` | `customers.csv` | Customer master — segment, loyalty tier, region, join date, channel                |
| `raw.ntg_products`  | `products.csv`  | Product catalogue — category, sub-category, tier, unit price, cost price           |
| `raw.ntg_stores`    | `stores.csv`    | Outlet data — store type, region, country                                          |

These tables are the only input to the dbt transformation layer. Nothing downstream reads from the source CSVs directly.

---

## Running the Pipeline

Full pipeline — extract, convert, load, then dbt:

```bash
python main.py
```

Console output per file:

```
Found 4 CSV file(s). Starting pipeline...

── Processing: sales.csv
  ✔ Converted: sales.csv → sales.parquet (50,000 rows)
  ✔ Loaded: ntg_sales → raw.ntg_sales (50,000 rows)

── Processing: customers.csv
  ✔ Converted: customers.csv → customers.parquet (8,200 rows)
  ✔ Loaded: ntg_customers → raw.ntg_customers (8,200 rows)

✅ Pipeline complete.
```

---

## Dependencies

| Package           | Purpose                                                                      |
| ----------------- | ---------------------------------------------------------------------------- |
| `pandas`          | Reading CSVs into DataFrames                                                 |
| `pyarrow`         | Parquet conversion and reading                                               |
| `sqlalchemy`      | Database engine and `to_sql` loading interface                               |
| `psycopg2-binary` | PostgreSQL adapter — binary version avoids C compiler requirement on Windows |
| `python-dotenv`   | Loading credentials from `.env` at runtime                                   |
