from fastapi import FastAPI
from pymongo import MongoClient, ASCENDING
import os


app = FastAPI(
    title="AirSense API",
    description="API des AirSense ÖPNV-Quellsystems",
    version="1.0.0"
)


# MongoDB-Verbindung
MONGO_URI = os.getenv(
    "MONGO_URI",
    "mongodb://127.0.0.1:27017"
)

MONGO_DATABASE = os.getenv(
    "MONGO_DATABASE",
    "airsense"
)

client = MongoClient(
    MONGO_URI,
    serverSelectionTimeoutMS=5000
)

db = client[MONGO_DATABASE]


@app.get("/")
def root():
    return {
        "system": "AirSense",
        "status": "running"
    }


@app.get("/get_data")
def get_data(
    station_id: int,
    sensor_id: int,
    messung_id: int
):
    # --------------------------------------------------
    # 1. Stationen abfragen
    # Entspricht: WHERE id > station_id ORDER BY id
    # --------------------------------------------------

    station_documents = db["stations"].find(
        {
            "_id": {
                "$gt": station_id
            }
        },
        {
            "_id": 1,
            "name": 1,
            "stadtteil": 1,
            "latitude": 1,
            "longitude": 1,
            "stations_typ": 1,
            "installationsdatum": 1,
            "status": 1
        }
    ).sort("_id", ASCENDING)

    station = []

    for document in station_documents:
        station.append({
            "id": document["_id"],
            "name": document.get("name"),
            "stadtteil": document.get("stadtteil"),
            "latitude": document.get("latitude"),
            "longitude": document.get("longitude"),
            "stations_typ": document.get("stations_typ"),
            "installationsdatum": document.get("installationsdatum"),
            "status": document.get("status")
        })

    # --------------------------------------------------
    # 2. Sensoren abfragen
    # Sensoren sind in den Stationen eingebettet.
    # Die Sensoren werden für die API wieder einzeln
    # ausgegeben.
    # --------------------------------------------------

    sensor_pipeline = [
        {
            "$unwind": "$sensoren"
        },
        {
            "$match": {
                "sensoren.sensor_id": {
                    "$gt": sensor_id
                }
            }
        },
        {
            "$sort": {
                "sensoren.sensor_id": 1
            }
        },
        {
            "$project": {
                "_id": 0,
                "id": "$sensoren.sensor_id",
                "id_station": "$_id",
                "sensortyp": "$sensoren.sensortyp",
                "einheit": "$sensoren.einheit",
                "installationsdatum": (
                    "$sensoren.installationsdatum"
                )
            }
        }
    ]

    sensor = list(
        db["stations"].aggregate(sensor_pipeline)
    )

    # --------------------------------------------------
    # 3. Messungen abfragen
    # Messungen liegen in einer eigenen Collection.
    # --------------------------------------------------

    measurement_documents = db["messungen"].find(
        {
            "_id": {
                "$gt": messung_id
            }
        },
        {
            "_id": 1,
            "sensor_id": 1,
            "messzeitpunkt": 1,
            "messwert": 1
        }
    ).sort("_id", ASCENDING)

    messung = []

    for document in measurement_documents:
        messung.append({
            "id": document["_id"],
            "id_sensor": document.get("sensor_id"),
            "messzeitpunkt": document.get("messzeitpunkt"),
            "messwert": document.get("messwert")
        })

    # --------------------------------------------------
    # 4. Antwortformat wie bei der bisherigen API
    # --------------------------------------------------

    return {
        "station": station,
        "sensor": sensor,
        "messung": messung
    }