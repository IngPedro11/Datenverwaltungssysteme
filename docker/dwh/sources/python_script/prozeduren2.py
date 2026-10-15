import psycopg2
import sys
import os

# --------------------------------------------------
# Transfer-Prozeduren
# --------------------------------------------------

PROCEDURES = [
    # 1–3: Fahrradstation
    "reporting.transfer_wetter_und_fahrradnutzung_fahradstation",#
    "reporting.transfer_veranstaltungen_und_fahrradnutzung_fahradstation",#
    "reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_fahradstation",#

    # 4–6: Sensor
    "reporting.transfer_wetter_und_fahrradnutzung_sensor",#
    "reporting.transfer_wetter_und_oepnv_sensor",#
    "reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_sensor",#

    # 7–10: Datum
    "reporting.transfer_veranstaltungen_und_fahrradnutzung_datum",#
    "reporting.transfer_veranstaltungen_und_oepnv_datum",#
    "reporting.transfer_wetter_und_oepnv_datum",#
    "reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_datum",#

    # 11–12: Veranstaltung
    "reporting.transfer_veranstaltungen_und_oepnv_versanstaltung",#
    "reporting.transfer_veranstaltungen_und_fahrradnutzung_versanstaltung",#

    # 13–15: Linie
    "reporting.transfer_veranstaltungen_und_oepnv_linie",#
    "reporting.transfer_wetter_und_oepnv_linie",#
    "reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_linie",#

    "reporting.transfer_wetter_und_fahrradnutzung",#
    "reporting.transfer_veranstaltungen_und_oepnv",#
    "reporting.transfer_veranstaltungen_und_fahrradnutzung",#
    "reporting.transfer_wetter_und_oepnv",#
    "reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen"#
]


def run_transfers():
    connection = None

    try:
        print("Verbindung zu PostgreSQL wird hergestellt ...")

        connection = psycopg2.connect(
            host="localhost",
            port="5432",
            database=os.getenv("POSTGRES_DB"),
            user=os.getenv("POSTGRES_USER"),
            password=os.getenv("POSTGRES_PASSWORD")
        )

        # Bei einem Fehler werden alle Änderungen zurückgerollt.
        connection.autocommit = False

        with connection.cursor() as cursor:
            total = len(PROCEDURES)

            for index, procedure in enumerate(PROCEDURES, start=1):
                print(f"[{index}/{total}] Starte {procedure} ...")

                cursor.execute(f"CALL {procedure}();")

                print(f"[{index}/{total}] Erfolgreich: {procedure}")

        connection.commit()

        print("\nAlle Transfer-Prozeduren wurden erfolgreich ausgeführt.")
        print("Die Transaktion wurde bestätigt.")

    except psycopg2.Error as error:
        if connection is not None:
            connection.rollback()

        print("\nFEHLER beim Datenbanktransfer!")
        print(f"Details: {error}")
        print("Die Transaktion wurde zurückgerollt.")
        sys.exit(1)

    except Exception as error:
        if connection is not None:
            connection.rollback()

        print(f"\nUnerwarteter Fehler: {error}")
        print("Die Transaktion wurde zurückgerollt.")
        sys.exit(1)

    finally:
        if connection is not None:
            connection.close()
            print("Datenbankverbindung geschlossen.")


if __name__ == "__main__":
    run_transfers()