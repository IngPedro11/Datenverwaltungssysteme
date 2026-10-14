from fastapi import FastAPI
import psycopg2
from psycopg2.extras import RealDictCursor
import os

app = FastAPI(
    title="AirSense API",
    description="API des AirSense ÖPNV-Quellsystems",
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
        "system": "AirSense",
        "status": "running"
    }

@app.get("/get_data")
def get_data(
    station_id: int,
    sensor_id: int,
    messung_id: int
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
            stations_typ,
            installationsdatum,
            status
        FROM airsense.Station
        WHERE id > %s   
        ORDER BY id;
    """, (station_id,))

    station = cursor.fetchall()

    cursor.execute("""
        SELECT
            id,
            id_station,
            sensortyp,
            einheit,
            installationsdatum
        FROM airsense.Sensor
        WHERE id > %s   
        ORDER BY id;
    """, (sensor_id,))

    sensor = cursor.fetchall()

    cursor.execute("""
        SELECT
            id,
            id_sensor,
            messzeitpunkt,
            messwert
        FROM airsense.Messung
        WHERE id > %s   
        ORDER BY id;
    """, (messung_id,))

    messung = cursor.fetchall()

    cursor.close()
    conn.close()

    return {
        "station": station,
        "sensor": sensor,
        "messung": messung
    }