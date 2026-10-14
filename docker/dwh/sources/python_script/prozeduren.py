import os
import psycopg2


def transfer_all():
    conn = psycopg2.connect(
        host="localhost",
        port="5432",
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD")
    )

    try:
        with conn:
            with conn.cursor() as cur:
                procedures = [
                    # Dimensionen
                    "core.transfer_dim_fahrradstation",
                    "core.transfer_dim_wettersensor",
                    "core.transfer_dim_veranstaltung",
                    "core.transfer_dim_linie",

                    # Topics
                    "core.transfer_topic_wetter_und_fahrradnutzung",
                    "core.transfer_topic_veranstaltungen_und_oepnv",
                    "core.transfer_topic_veranstaltungen_und_fahrradnutzung",
                    "core.transfer_topic_wetter_und_oepnv",
                    "core.transfer_topic_luftqualitaet_und_mobilitaetsaufkommen",
                ]

                for procedure in procedures:
                    print(f"Starte {procedure} ...")
                    cur.execute(f"CALL {procedure}();")
                    print(f"{procedure} erfolgreich abgeschlossen.")

        print("Alle Dimension- und Topic-Transfers erfolgreich abgeschlossen.")

    except Exception as e:
        print(f"Fehler beim Transfer: {e}")
        raise

    finally:
        conn.close()


if __name__ == "__main__":
    transfer_all()