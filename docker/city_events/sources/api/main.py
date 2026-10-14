from fastapi import FastAPI
import psycopg2
from psycopg2.extras import RealDictCursor
import os

app = FastAPI(
    title="CityEvents API",
    description="API des CityEvents ÖPNV-Quellsystems",
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
        "system": "CityEvents",
        "status": "running"
    }

@app.get("/get_data")
def get_data(
    veranstaltungstyp_id: int,
    veranstalter_id: int,
    veranstaltungsort_id: int,
    veranstaltung_id: int,
    veranstaltungstermin_id: int,
    ticket_id: int,
    einlass_id: int
):
    conn = get_connection()
    cursor = conn.cursor(cursor_factory=RealDictCursor)

    cursor.execute("""
        SELECT 
            id,
            bezeichnung
        FROM cityevents.Veranstaltungstyp
        WHERE id > %s 
        ORDER BY id;
    """, (veranstaltungstyp_id,))

    veranstaltungstyp = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            name,
            organisationstyp
        FROM cityevents.Veranstalter
        WHERE id > %s 
        ORDER BY id;
    """, (veranstalter_id,))

    veranstalter = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            name,
            stadtteil,
            latitude,
            longitude,
            kapazitaet
        FROM cityevents.Veranstaltungsort
        WHERE id > %s 
        ORDER BY id;
    """, (veranstaltungsort_id,))

    veranstaltungsort = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            name,
            id_typ,
            id_veranstalter,
            beschreibung
        FROM cityevents.Veranstaltung
        WHERE id > %s 
        ORDER BY id;
    """, (veranstaltung_id,))

    veranstaltung = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            id_veranstaltung,
            id_veranstaltungsort,
            beginn_geplant,
            ende_geplant,
            beginn_tatsaechlich,
            ende_tatsaechlich,
            status
        FROM cityevents.Veranstaltungstermin
        WHERE id > %s 
        ORDER BY id;
    """, (veranstaltungstermin_id,))

    veranstaltungstermin = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            id_termin,
            tickettyp,
            status
        FROM cityevents.Ticket
        WHERE id > %s 
        ORDER BY id;
    """, (ticket_id,))

    ticket = cursor.fetchall()

    cursor.execute("""
        SELECT 
            id,
            id_ticket,
            einlasszeitpunkt,
            einlass_status
        FROM cityevents.Einlass
        WHERE id > %s 
        ORDER BY id;
    """, (einlass_id,))

    einlass = cursor.fetchall()

    cursor.close()
    conn.close()

    return {
        "veranstaltungstyp": veranstaltungstyp,
        "veranstalter": veranstalter,
        "veranstaltungsort": veranstaltungsort,
        "veranstaltung": veranstaltung,
        "veranstaltungstermin": veranstaltungstermin,
        "ticket": ticket,
        "einlass": einlass
    }