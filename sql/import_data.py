"""
VISTARA — Mexican Premium Clothing E-Commerce
import_data.py  |  Bulk CSV import into PostgreSQL via psycopg2 COPY

Prerequisites:
    pip install psycopg2-binary   (or psycopg2 if you have the build tools)

Usage:
    1. Edit DB_CONFIG below with your credentials.
    2. Make sure the target database exists:
           CREATE DATABASE vistara_db;
    3. Make sure schema.sql has already been applied:
           psql -d vistara_db -f schema.sql
    4. Run:
           python import_data.py
"""

import io
import os
import sys
import time
import psycopg2

# =============================================================================
# CONFIGURATION — edit these values before running
# =============================================================================
DB_CONFIG = {
    "host":     "localhost",          # PostgreSQL host
    "port":     5432,                 # PostgreSQL port (default 5432)
    "dbname":   "vistara_db",         # Must exist before running this script
    "user":     "postgres",           # Change to your PostgreSQL username
    "password": "your_password",      # Change to your PostgreSQL password
}

# Absolute path to the folder that contains the CSV files.
# Change this if your datasets live elsewhere.
DATASETS_DIR = r"D:\DataScience\Sql and powerBI proyect\datasets"

# =============================================================================
# Import manifest — order respects FK dependencies (parents before children).
# Each entry:
#   (step, csv_filename, schema.table_name, [ordered column list])
# The column list must exactly match the CSV headers (after BOM strip).
# =============================================================================
IMPORT_PLAN = [
    (
        1,
        "Dates.csv",
        "vistara.dim_dates",
        [
            "transaction_date", "date_id", "week_id", "year_id",
            "month_id", "month_name", "quarter_id", "quarter_name",
        ],
    ),
    (
        2,
        "Sales_Outlet.csv",
        "vistara.dim_sales_outlet",
        [
            "sales_outlet_id", "sales_outlet_type",
            "store_city", "store_postal_code",
        ],
    ),
    (
        3,
        "Customers.csv",
        "vistara.dim_customers",
        [
            "customer_id", "home_store", "customer_first_name",
            "customer_since", "gender",
        ],
    ),
    (
        4,
        "Products.csv",
        "vistara.dim_products",
        [
            "product_id", "product_category", "product_type",
            "product_name", "color", "current_price",
        ],
    ),
    (
        5,
        "Sales_Receipts.csv",
        "vistara.fact_sales_receipts",
        [
            "transaction_id", "transaction_date", "transaction_time",
            "sales_outlet_id", "customer_id", "order_number", "product_id",
        ],
    ),
    (
        6,
        "Order_Details.csv",
        "vistara.fact_order_details",
        [
            "order_detail_id", "order_number", "transaction_id",
            "product_id", "quantity", "unit_price", "discount_pct", "line_total",
        ],
    ),
    (
        7,
        "Inventory.csv",
        "vistara.fact_inventory",
        [
            "sales_outlet_id", "transaction_date", "product_id",
            "start_of_day_qty", "quantity_sold", "waste", "waste_pct",
        ],
    ),
    (
        8,
        "Returns.csv",
        "vistara.fact_returns",
        [
            "return_id", "original_transaction_id", "original_order_number",
            "customer_id", "product_id", "return_date", "return_reason",
            "refund_amount", "return_type",
        ],
    ),
]

TOTAL_STEPS = len(IMPORT_PLAN)


# =============================================================================
# Helpers
# =============================================================================

def strip_bom(text: str) -> str:
    """Remove UTF-8 BOM character (U+FEFF) if present at the start of a string."""
    return text.lstrip("﻿")


def read_csv_as_buffer(filepath: str) -> io.StringIO:
    """
    Read a CSV file, strip the UTF-8-sig BOM from the header line, and return
    the content as an in-memory StringIO buffer ready for cursor.copy_expert().
    """
    with open(filepath, encoding="utf-8-sig", newline="") as fh:
        content = fh.read()
    # Ensure the first-line BOM is gone even if encoding='utf-8-sig' missed it
    content = strip_bom(content)
    return io.StringIO(content)


def count_rows(cursor, table: str) -> int:
    """Return the current row count for a fully-qualified table."""
    cursor.execute(f"SELECT COUNT(*) FROM {table};")
    return cursor.fetchone()[0]


def build_copy_sql(table: str, columns: list[str]) -> str:
    """
    Build a COPY ... FROM STDIN statement that skips the CSV header row.
    Example output:
        COPY vistara.dim_dates (transaction_date, ...) FROM STDIN
        WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', NULL '');
    """
    col_list = ", ".join(columns)
    return (
        f"COPY {table} ({col_list}) FROM STDIN "
        f"WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', NULL '');"
    )


# =============================================================================
# Main import routine
# =============================================================================

def main() -> None:
    print("=" * 60)
    print("VISTARA — PostgreSQL bulk data import")
    print("=" * 60)

    # Validate dataset directory
    if not os.path.isdir(DATASETS_DIR):
        print(f"\n[ERROR] Dataset directory not found:\n  {DATASETS_DIR}")
        sys.exit(1)

    # Establish connection
    try:
        conn = psycopg2.connect(**DB_CONFIG)
    except psycopg2.OperationalError as exc:
        print(f"\n[ERROR] Cannot connect to PostgreSQL:\n  {exc}")
        print("\nCheck DB_CONFIG at the top of this script and ensure the database exists.")
        sys.exit(1)

    conn.autocommit = False          # Wrap everything in a single transaction
    cursor = conn.cursor()

    total_start = time.perf_counter()
    rows_imported: list[tuple[str, int]] = []

    try:
        for step, csv_file, table, columns in IMPORT_PLAN:
            filepath = os.path.join(DATASETS_DIR, csv_file)

            # Check the file exists before attempting the COPY
            if not os.path.isfile(filepath):
                raise FileNotFoundError(
                    f"CSV file not found: {filepath}\n"
                    f"Ensure DATASETS_DIR points to the correct folder."
                )

            print(f"\n[{step}/{TOTAL_STEPS}] Importing {csv_file} → {table} ...", end=" ", flush=True)
            t0 = time.perf_counter()

            buffer = read_csv_as_buffer(filepath)
            sql    = build_copy_sql(table, columns)
            cursor.copy_expert(sql, buffer)

            elapsed = time.perf_counter() - t0
            row_count = count_rows(cursor, table)
            rows_imported.append((table, row_count))

            print(f"OK — {row_count:,} rows  ({elapsed:.2f}s)")

        # All tables loaded successfully — commit
        conn.commit()

        total_elapsed = time.perf_counter() - total_start
        print("\n" + "=" * 60)
        print("Import complete — all tables committed successfully.")
        print(f"Total time: {total_elapsed:.2f}s")
        print("\nRow counts:")
        for table, rows in rows_imported:
            print(f"  {table:<40} {rows:>10,}")
        print("=" * 60)

    except Exception as exc:
        conn.rollback()
        print(f"\n\n[FATAL] Import failed — transaction rolled back.")
        print(f"  Error: {exc}")
        print("\nNo data was written to the database. Fix the issue and re-run.")
        sys.exit(1)

    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    main()
