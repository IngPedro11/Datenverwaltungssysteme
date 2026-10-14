from fastapi import FastAPI
import psycopg2
from psycopg2.extras import RealDictCursor
import os

app = FastAPI(
    title="CityMove API",
    description="API des CityMove ÖPNV-Quellsystems",
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
        "system": "CityMove",
        "status": "running"
    }

@app.get("/test")
def get_data(
    linie_id: int,
    haltestelle_id: int,
    fahrzeug_id: int,
    fahrt_id: int,
    fahrplan_id: int,
    fahrt_haltestelle_id: int,
    fahrgastaufkommen_id: int
):
    conn = get_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    cursor.execute("""
        SELECT
            id,
            liniennummer,
            bezeichnung,
            verkehrsmittel,
            gueltig_ab,
            gueltig_bis
        FROM citymove.Linie
        WHERE id > %s   
        ORDER BY id;
    """, (linie_id,))

    linien = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            name,
            stadtteil,
            latitude,
            longitude
        FROM citymove.Haltestelle
        WHERE id > %s 
        ORDER BY id;
    """, (haltestelle_id,))

    haltestellen = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id, 
            kapazitaet
        FROM citymove.Fahrzeug
        WHERE id > %s
        ORDER BY id;
    """, (fahrzeug_id,))

    fahrzeug = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            id_linie,
            id_fahrzeug,
            datum,
            fahrtrichtung
        FROM citymove.Fahrt
        WHERE id > %s
        ORDER BY id;
    """, (fahrt_id,))

    fahrt = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id, 
            id_fahrt,
            id_haltestelle,
            ankunft_geplant,
            abfahrt_geplant
        FROM citymove.Fahrplan
        WHERE id > %s
        ORDER BY id;
    """, (fahrplan_id,))

    fahrplan = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            id_fahrt,
            id_haltestelle,
            ankunft_tatsaechlich,
            abfahrt_tatsaechlich
        FROM citymove.Fahrt_Haltestelle
        WHERE id > %s
        ORDER BY id;
    """, (fahrt_haltestelle_id,))

    fahrt_haltestelle = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            id_fahrt,
            id_haltestelle,
            einsteiger,
            aussteiger
        FROM citymove.Fahrgastaufkommen
        WHERE id > %s 
        ORDER BY id;
    """, (fahrgastaufkommen_id,))
    
    fahrgastaufkommen = cursor.fetchall()

    cursor.close()
    conn.close()

    return {
        "linien": linien,
        "haltestellen": haltestellen,
        "fahrzeuge": fahrzeug,
        "fahrten": fahrt,
        "fahrplaene": fahrplan,
        "fahrt_haltestellen": fahrt_haltestelle,
        "fahrgastaufkommen": fahrgastaufkommen
    }