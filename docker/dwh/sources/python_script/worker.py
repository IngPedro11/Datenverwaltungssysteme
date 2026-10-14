import json
import os
import requests

from psycopg2 import sql
from database import get_target_connection


PROGRESS_FILE = os.getenv("PROGRESS_FILE", "/var/lib/postgresql/progress.json")


def load_progress():
    if not os.path.exists(PROGRESS_FILE):
        return {}

    with open(PROGRESS_FILE, "r", encoding="utf-8") as file:
        return json.load(file)


def save_progress(progress):
    directory = os.path.dirname(PROGRESS_FILE)
    os.makedirs(directory, exist_ok=True)

    temp_file = PROGRESS_FILE + ".tmp"

    with open(temp_file, "w", encoding="utf-8") as file:
        json.dump(progress, file, indent=4)

    os.replace(temp_file, PROGRESS_FILE)


def fetch_data(system_config, system_progress):
    params = {}

    for table_name, table_config in system_config["tables"].items():
        id_parameter = table_config["id_parameter"]

        params[id_parameter] = system_progress.get(table_name, 0)

    response = requests.get(
        system_config["api_url"],
        params=params,
        timeout=60
    )

    response.raise_for_status()

    return response.json()


def insert_rows(cursor, schema, table_config, rows):
    if not rows:
        return

    columns = table_config["columns"]

    # Sicherstellen, dass alle erwarteten Spalten vorhanden sind.
    for row in rows:
        missing = set(columns) - set(row.keys())

        if missing:
            raise ValueError(
                f"Fehlende Spalten in {table_config['target_table']}: "
                f"{sorted(missing)}"
            )

    query = sql.SQL("""
        INSERT INTO {}.{} ({})
        VALUES ({})
        ON CONFLICT ({}) DO NOTHING
    """).format(
        sql.Identifier(schema),
        sql.Identifier(table_config["target_table"]),
        sql.SQL(", ").join(
            sql.Identifier(column) for column in columns
        ),
        sql.SQL(", ").join(
            sql.Placeholder() for _ in columns
        ),
        sql.Identifier("id")
    )

    values = [
        tuple(row[column] for column in columns)
        for row in rows
    ]

    cursor.executemany(query, values)


def process_system(system_name, system_config, progress):
    print(f"Verarbeite System: {system_name}")

    system_progress = progress.setdefault(system_name, {})

    # 1. Daten abrufen
    data = fetch_data(system_config, system_progress)

    # 2. IDs zunächst nur lokal berechnen
    new_progress = dict(system_progress)

    for table_name, table_config in system_config["tables"].items():
        rows = data.get(table_name, [])

        print(
            f"Tabelle {table_name}: "
            f"{len(rows)} Datensätze"
        )

        if table_name == "fahrt":
            print(
                "Gelieferte Fahrt-IDs:",
                [row["id"] for row in rows]
            )

        if table_name == "fahrgastaufkommen":
            print(
                "Referenzierte Fahrt-IDs:",
                sorted({
                    row["id_fahrt"]
                    for row in rows
                    if row.get("id_fahrt") is not None
                })
            )

        if rows:
            highest_id = max(int(row["id"]) for row in rows)

            new_progress[table_name] = max(
                int(new_progress.get(table_name, 0)),
                highest_id
            )

    # 3. Alle Tabellen dieses Systems in einer Transaktion schreiben
    conn = get_target_connection()

    try:
        with conn:
            with conn.cursor() as cursor:
                for table_name, table_config in system_config["tables"].items():
                    rows = data.get(table_name, [])

                    insert_rows(
                        cursor,
                        system_config["schema"],
                        table_config,
                        rows
                    )

        # Die Datenbanktransaktion wurde erfolgreich abgeschlossen.
        progress[system_name] = new_progress
        save_progress(progress)

        print(f"System {system_name} erfolgreich verarbeitet.")

    finally:
        conn.close()