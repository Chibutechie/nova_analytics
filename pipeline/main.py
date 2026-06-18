from convert import convert_all_to_parquet
from load import load_all_parquets


def main():
    print("Starting pipeline...")

    convert_all_to_parquet()
    print("Conversion complete.")

    load_all_parquets(schema="raw")
    print("Load complete.")

    print("Pipeline finished successfully.")


if __name__ == "__main__":
    main()