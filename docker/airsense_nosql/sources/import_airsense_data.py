#!/usr/bin/env python3

import json
import os
import sys
from pathlib import Path

from pymongo import ASCENDING, MongoClient
from pymongo.errors import PyMongoError


MONGO_URI = os.getenv(
    "MONGO_URI",
    "mongodb://127.0.0.1:27017"
)

MONGO_DATABASE = os.getenv(
    "MONGO_DATABASE",
    "airsense"
)

JSON_PATH = Path(
    os.getenv(
        "AIRSENSE_JSON_PATH",
        "/app/seed/airsense_mongodb.json"
    )
)

IMPORT_MARKER_ID = "initial_airsense_import"


def load_payload(path: Path) -> dict:
    """Lädt und prüft die vorbereitete JSON-Datei."""

    if not path.is_file():
        raise FileNotFoundError(
            f"Datendatei nicht gefunden: {path}"
        )

    with path.open("r", encoding="utf-8") as file:
        payload = json.load(file)

    if not isinstance(payload, dict):
        raise ValueError(
            "Die JSON-Wurzel muss ein Objekt sein."
        )

    for collection_name in (
        "stations",
        "messungen",
        "sensorwartungen"
    ):
        if (
            collection_name not in payload
            or not isinstance(payload[collection_name], list)
        ):
            raise ValueError(
                f"'{collection_name}' muss eine Liste sein."
            )

    return payload


def validate_ids(payload: dict) -> None:
    """Prüft, ob alle Dokumente eindeutige IDs besitzen."""

    for collection_name in (
        "stations",
        "messungen",
        "sensorwartungen"
    ):
        seen = set()

        for index, document in enumerate(payload[collection_name]):
            if not isinstance(document, dict):
                raise ValueError(
                    f"{collection_name}[{index}] muss ein Objekt sein."
                )

            if "_id" not in document:
                raise ValueError(
                    f"{collection_name}[{index}] besitzt keine _id."
                )

            document_id = document["_id"]

            try:
                if document_id in seen:
                    raise ValueError(
                        f"Doppelte ID {document_id!r} "
                        f"in '{collection_name}'."
                    )

                seen.add(document_id)

            except TypeError as error:
                raise ValueError(
                    f"Ungültige ID in '{collection_name}[{index}]'."
                ) from error


def main() -> int:
    client = None

    try:
        # 1. Daten laden und validieren
        payload = load_payload(JSON_PATH)
        validate_ids(payload)

        # 2. Verbindung zu MongoDB herstellen
        client = MongoClient(
            MONGO_URI,
            serverSelectionTimeoutMS=5000
        )

        client.admin.command("ping")

        db = client[MONGO_DATABASE]

        # 3. Prüfen, ob der Initialimport bereits abgeschlossen ist
        marker = db["metadata"].find_one(
            {"_id": IMPORT_MARKER_ID}
        )

        if marker and marker.get("completed") is True:
            print(
                "Initialimport bereits abgeschlossen. "
                "Import wird übersprungen."
            )
            return 0

        # 4. Dokumente importieren
        # replace_one + upsert verhindert doppelte Dokumente
        # bei einem erneuten Versuch nach einem Abbruch.
        counts = {}

        for collection_name in (
            "stations",
            "messungen",
            "sensorwartungen"
        ):
            collection = db[collection_name]
            documents = payload[collection_name]

            for document in documents:
                collection.replace_one(
                    {"_id": document["_id"]},
                    document,
                    upsert=True
                )

            counts[collection_name] = len(documents)

        # 5. Indizes für häufige Abfragen über Sensorreferenzen
        db["messungen"].create_index(
            [("sensor_id", ASCENDING)]
        )

        db["sensorwartungen"].create_index(
            [("sensor_id", ASCENDING)]
        )

        # 6. Importstatus erst nach erfolgreichem Import markieren
        db["metadata"].replace_one(
            {"_id": IMPORT_MARKER_ID},
            {
                "_id": IMPORT_MARKER_ID,
                "completed": True,
                "source_file": JSON_PATH.name,
                "document_counts": counts
            },
            upsert=True
        )

        print(
            f"Initialimport in '{MONGO_DATABASE}' erfolgreich."
        )

        for collection_name, count in counts.items():
            print(f"  {collection_name}: {count} Dokumente")

        return 0

    except (
        FileNotFoundError,
        json.JSONDecodeError,
        ValueError
    ) as error:
        print(
            f"Fehler bei den Importdaten: {error}",
            file=sys.stderr
        )
        return 1

    except PyMongoError as error:
        print(
            f"MongoDB-Fehler: {error}",
            file=sys.stderr
        )
        return 1

    finally:
        if client is not None:
            client.close()


if __name__ == "__main__":
    sys.exit(main())