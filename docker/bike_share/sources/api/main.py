from fastapi import FastAPI
import psycopg2
from psycopg2.extras import RealDictCursor
import os

app = FastAPI(
    title="BikeShare API",
    description="API des BikeShare ÖPNV-Quellsystems",
    version="1.0.0"
)


def get_connection():
    return psycopg2.connect(
        host="localhost",
        port=5432,
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD")
    )


@app.get("/")
def root():
    return {
        "system": "BikeShare",
        "status": "running"
    }

@app.get("/get_data")
def get_data(
    station_id: int,
    fahrt_id: int
):
    conn = get_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    cursor.execute("""
        SELECT
            id,
            name,
            stadtteil,
            latitude,
            longitude,
            kapazitaet
        FROM bikeshare.Station
        WHERE id > %s
        ORDER BY id;
    """, (station_id,))

    station = cursor.fetchall()

    cursor.execute("""
        SELECT
            id,
            id_startstation,
            id_zielstation,
            startzeit,
            endzeit,
            status
        FROM bikeshare.Fahrt
        WHERE id > %s
        ORDER BY id;
    """, (fahrt_id,))

    fahrt = cursor.fetchall()

    cursor.close()
    conn.close()

    return {
        "station": station,
        "fahrt": fahrt
    }

