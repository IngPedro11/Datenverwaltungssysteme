-- ============================================================
-- Reporting-Ladestrategie
-- 1. Dimensions laden (eigene Reporting-Keys, core_id = Core-Key)
-- 2. Fakten laden (Reporting-Keys per JOIN über core_id)
-- Vor dem Aufruf müssen 02_core.sql, 03_reporting.sql und
-- die Core-Transferprozeduren erfolgreich ausgeführt worden sein.
-- ============================================================

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_fahrradnutzung_fahradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_Fahrradnutzung_Fahradstation (
        core_id,
        Fahrt_status,
        Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet
    )
    SELECT
        c.Fahrt_key,
        c.Fahrt_status,
        c.Fahrt_Station_Startstation_stadtteil,
        c.Fahrt_Station_Startstation_latitude,
        c.Fahrt_Station_Startstation_longitude,
        c.Fahrt_Station_Startstation_kapazitaet,
        c.Fahrt_Station_Endstation_stadtteil,
        c.Fahrt_Station_Endstation_latitude,
        c.Fahrt_Station_Endstation_longitude,
        c.Fahrt_Station_Endstation_kapazitaet
    FROM core.DIM_Fahrradstation AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_status = EXCLUDED.Fahrt_status,
        Fahrt_Station_Startstation_stadtteil = EXCLUDED.Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude = EXCLUDED.Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude = EXCLUDED.Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet = EXCLUDED.Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_stadtteil = EXCLUDED.Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude = EXCLUDED.Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude = EXCLUDED.Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet = EXCLUDED.Fahrt_Station_Endstation_kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_fahrradnutzung_sensor()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_Fahrradnutzung_Sensor (
        core_id,
        Sensor_name,
        Sensor_stadtteil,
        Sensor_latitude,
        Sensor_longitude,
        Sensor_stations_typ,
        Sensor_station_installationsdatum,
        Sensor_status,
        Sensor_sensortyp,
        Sensor_installationsdatum,
        Sensor_messzeitpunkt
    )
    SELECT
        c.Sensor_key,
        c.Sensor_name,
        c.Sensor_stadtteil,
        c.Sensor_latitude,
        c.Sensor_longitude,
        c.Sensor_stations_typ,
        c.Sensor_station_installationsdatum,
        c.Sensor_status,
        c.Sensor_sensortyp,
        c.Sensor_installationsdatum,
        c.Sensor_messzeitpunkt
    FROM core.DIM_Wettersensor AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Sensor_name = EXCLUDED.Sensor_name,
        Sensor_stadtteil = EXCLUDED.Sensor_stadtteil,
        Sensor_latitude = EXCLUDED.Sensor_latitude,
        Sensor_longitude = EXCLUDED.Sensor_longitude,
        Sensor_stations_typ = EXCLUDED.Sensor_stations_typ,
        Sensor_station_installationsdatum = EXCLUDED.Sensor_station_installationsdatum,
        Sensor_status = EXCLUDED.Sensor_status,
        Sensor_sensortyp = EXCLUDED.Sensor_sensortyp,
        Sensor_installationsdatum = EXCLUDED.Sensor_installationsdatum,
        Sensor_messzeitpunkt = EXCLUDED.Sensor_messzeitpunkt;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_fahrradnutzung_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_Fahrradnutzung_Datum (
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        c.Datum_Key,
        c.Stunde,
        c.Datum,
        c.Monat,
        c.Quartal,
        c.Jahr
    FROM core.DIM_Datum AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Stunde = EXCLUDED.Stunde,
        Datum = EXCLUDED.Datum,
        Monat = EXCLUDED.Monat,
        Quartal = EXCLUDED.Quartal,
        Jahr = EXCLUDED.Jahr;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_fahrradnutzung_fahradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_Fahrradnutzung_Fahradstation (
        core_id,
        Fahrt_status,
        Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet
    )
    SELECT
        c.Fahrt_key,
        c.Fahrt_status,
        c.Fahrt_Station_Startstation_stadtteil,
        c.Fahrt_Station_Startstation_latitude,
        c.Fahrt_Station_Startstation_longitude,
        c.Fahrt_Station_Startstation_kapazitaet,
        c.Fahrt_Station_Endstation_stadtteil,
        c.Fahrt_Station_Endstation_latitude,
        c.Fahrt_Station_Endstation_longitude,
        c.Fahrt_Station_Endstation_kapazitaet
    FROM core.DIM_Fahrradstation AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_status = EXCLUDED.Fahrt_status,
        Fahrt_Station_Startstation_stadtteil = EXCLUDED.Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude = EXCLUDED.Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude = EXCLUDED.Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet = EXCLUDED.Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_stadtteil = EXCLUDED.Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude = EXCLUDED.Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude = EXCLUDED.Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet = EXCLUDED.Fahrt_Station_Endstation_kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_fahrradnutzung_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_Fahrradnutzung_Datum (
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        c.Datum_Key,
        c.Stunde,
        c.Datum,
        c.Monat,
        c.Quartal,
        c.Jahr
    FROM core.DIM_Datum AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Stunde = EXCLUDED.Stunde,
        Datum = EXCLUDED.Datum,
        Monat = EXCLUDED.Monat,
        Quartal = EXCLUDED.Quartal,
        Jahr = EXCLUDED.Jahr;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_fahradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Fahradstation (
        core_id,
        Fahrt_status,
        Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet
    )
    SELECT
        c.Fahrt_key,
        c.Fahrt_status,
        c.Fahrt_Station_Startstation_stadtteil,
        c.Fahrt_Station_Startstation_latitude,
        c.Fahrt_Station_Startstation_longitude,
        c.Fahrt_Station_Startstation_kapazitaet,
        c.Fahrt_Station_Endstation_stadtteil,
        c.Fahrt_Station_Endstation_latitude,
        c.Fahrt_Station_Endstation_longitude,
        c.Fahrt_Station_Endstation_kapazitaet
    FROM core.DIM_Fahrradstation AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_status = EXCLUDED.Fahrt_status,
        Fahrt_Station_Startstation_stadtteil = EXCLUDED.Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude = EXCLUDED.Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude = EXCLUDED.Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet = EXCLUDED.Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_stadtteil = EXCLUDED.Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude = EXCLUDED.Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude = EXCLUDED.Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet = EXCLUDED.Fahrt_Station_Endstation_kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_sensor()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Sensor (
        core_id,
        Sensor_name,
        Sensor_stadtteil,
        Sensor_latitude,
        Sensor_longitude,
        Sensor_stations_typ,
        Sensor_station_installationsdatum,
        Sensor_status,
        Sensor_sensortyp,
        Sensor_installationsdatum,
        Sensor_messzeitpunkt
    )
    SELECT
        c.Sensor_key,
        c.Sensor_name,
        c.Sensor_stadtteil,
        c.Sensor_latitude,
        c.Sensor_longitude,
        c.Sensor_stations_typ,
        c.Sensor_station_installationsdatum,
        c.Sensor_status,
        c.Sensor_sensortyp,
        c.Sensor_installationsdatum,
        c.Sensor_messzeitpunkt
    FROM core.DIM_Wettersensor AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Sensor_name = EXCLUDED.Sensor_name,
        Sensor_stadtteil = EXCLUDED.Sensor_stadtteil,
        Sensor_latitude = EXCLUDED.Sensor_latitude,
        Sensor_longitude = EXCLUDED.Sensor_longitude,
        Sensor_stations_typ = EXCLUDED.Sensor_stations_typ,
        Sensor_station_installationsdatum = EXCLUDED.Sensor_station_installationsdatum,
        Sensor_status = EXCLUDED.Sensor_status,
        Sensor_sensortyp = EXCLUDED.Sensor_sensortyp,
        Sensor_installationsdatum = EXCLUDED.Sensor_installationsdatum,
        Sensor_messzeitpunkt = EXCLUDED.Sensor_messzeitpunkt;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Datum (
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        c.Datum_Key,
        c.Stunde,
        c.Datum,
        c.Monat,
        c.Quartal,
        c.Jahr
    FROM core.DIM_Datum AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Stunde = EXCLUDED.Stunde,
        Datum = EXCLUDED.Datum,
        Monat = EXCLUDED.Monat,
        Quartal = EXCLUDED.Quartal,
        Jahr = EXCLUDED.Jahr;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_oepnv_versanstaltung()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_OePNV_Versanstaltung (
        core_id,
        Veranstaltung_name,
        Veranstaltung_beschreibung,
        Veranstaltung_Veranstalter_name,
        Veranstaltung_Veranstalter_organisationstyp,
        Veranstaltung_Veranstaltungstyp,
        Veranstaltung_termin_status,
        Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status,
        Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil,
        Veranstaltung_latitude,
        Veranstaltung_longitude,
        Veranstaltung_kapazitaet
    )
    SELECT
        c.Veranstaltung_Key,
        c.Veranstaltung_name,
        c.Veranstaltung_beschreibung,
        c.Veranstaltung_Veranstalter_name,
        c.Veranstaltung_Veranstalter_organisationstyp,
        c.Veranstaltung_Veranstaltungstyp,
        c.Veranstaltung_termin_status,
        c.Veranstaltung_tickettyp,
        c.Veranstaltung_Ticket_status,
        c.Veranstaltung_Veranstaltungsort_name,
        c.Veranstaltung_stadtteil,
        c.Veranstaltung_latitude,
        c.Veranstaltung_longitude,
        c.Veranstaltung_kapazitaet
    FROM core.DIM_Veranstaltung AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Veranstaltung_name = EXCLUDED.Veranstaltung_name,
        Veranstaltung_beschreibung = EXCLUDED.Veranstaltung_beschreibung,
        Veranstaltung_Veranstalter_name = EXCLUDED.Veranstaltung_Veranstalter_name,
        Veranstaltung_Veranstalter_organisationstyp = EXCLUDED.Veranstaltung_Veranstalter_organisationstyp,
        Veranstaltung_Veranstaltungstyp = EXCLUDED.Veranstaltung_Veranstaltungstyp,
        Veranstaltung_termin_status = EXCLUDED.Veranstaltung_termin_status,
        Veranstaltung_tickettyp = EXCLUDED.Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status = EXCLUDED.Veranstaltung_Ticket_status,
        Veranstaltung_Veranstaltungsort_name = EXCLUDED.Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil = EXCLUDED.Veranstaltung_stadtteil,
        Veranstaltung_latitude = EXCLUDED.Veranstaltung_latitude,
        Veranstaltung_longitude = EXCLUDED.Veranstaltung_longitude,
        Veranstaltung_kapazitaet = EXCLUDED.Veranstaltung_kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_fahrradnutzung_versanstaltung()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_Fahrradnutzung_Versanstaltung (
        core_id,
        Veranstaltung_name,
        Veranstaltung_beschreibung,
        Veranstaltung_Veranstalter_name,
        Veranstaltung_Veranstalter_organisationstyp,
        Veranstaltung_Veranstaltungstyp,
        Veranstaltung_termin_status,
        Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status,
        Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil,
        Veranstaltung_latitude,
        Veranstaltung_longitude,
        Veranstaltung_kapazitaet
    )
    SELECT
        c.Veranstaltung_Key,
        c.Veranstaltung_name,
        c.Veranstaltung_beschreibung,
        c.Veranstaltung_Veranstalter_name,
        c.Veranstaltung_Veranstalter_organisationstyp,
        c.Veranstaltung_Veranstaltungstyp,
        c.Veranstaltung_termin_status,
        c.Veranstaltung_tickettyp,
        c.Veranstaltung_Ticket_status,
        c.Veranstaltung_Veranstaltungsort_name,
        c.Veranstaltung_stadtteil,
        c.Veranstaltung_latitude,
        c.Veranstaltung_longitude,
        c.Veranstaltung_kapazitaet
    FROM core.DIM_Veranstaltung AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Veranstaltung_name = EXCLUDED.Veranstaltung_name,
        Veranstaltung_beschreibung = EXCLUDED.Veranstaltung_beschreibung,
        Veranstaltung_Veranstalter_name = EXCLUDED.Veranstaltung_Veranstalter_name,
        Veranstaltung_Veranstalter_organisationstyp = EXCLUDED.Veranstaltung_Veranstalter_organisationstyp,
        Veranstaltung_Veranstaltungstyp = EXCLUDED.Veranstaltung_Veranstaltungstyp,
        Veranstaltung_termin_status = EXCLUDED.Veranstaltung_termin_status,
        Veranstaltung_tickettyp = EXCLUDED.Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status = EXCLUDED.Veranstaltung_Ticket_status,
        Veranstaltung_Veranstaltungsort_name = EXCLUDED.Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil = EXCLUDED.Veranstaltung_stadtteil,
        Veranstaltung_latitude = EXCLUDED.Veranstaltung_latitude,
        Veranstaltung_longitude = EXCLUDED.Veranstaltung_longitude,
        Veranstaltung_kapazitaet = EXCLUDED.Veranstaltung_kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_oepnv_linie()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_OePNV_Linie (
        core_id,
        Linie_liniennummer,
        Linie_bezeichnung,
        Linie_verkehrsmittel,
        Linie_gueltig_ab,
        Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug,
        Linie_Fahrt_datum,
        Linie_fahrtrichtung,
        Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude
    )
    SELECT
        c.Linie_Key,
        c.Linie_liniennummer,
        c.Linie_bezeichnung,
        c.Linie_verkehrsmittel,
        c.Linie_gueltig_ab,
        c.Linie_gueltig_bis,
        c.Linie_Fahrzeug_kapazitaet,
        c.Linie_fahrzeug,
        c.Linie_Fahrt_datum,
        c.Linie_fahrtrichtung,
        c.Linie_Haltestelle_name,
        c.Linie_Haltestelle_stadtteil,
        c.Linie_Haltestelle_latitude,
        c.Linie_Haltestelle_longitude
    FROM core.DIM_Linie AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Linie_liniennummer = EXCLUDED.Linie_liniennummer,
        Linie_bezeichnung = EXCLUDED.Linie_bezeichnung,
        Linie_verkehrsmittel = EXCLUDED.Linie_verkehrsmittel,
        Linie_gueltig_ab = EXCLUDED.Linie_gueltig_ab,
        Linie_gueltig_bis = EXCLUDED.Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet = EXCLUDED.Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug = EXCLUDED.Linie_fahrzeug,
        Linie_Fahrt_datum = EXCLUDED.Linie_Fahrt_datum,
        Linie_fahrtrichtung = EXCLUDED.Linie_fahrtrichtung,
        Linie_Haltestelle_name = EXCLUDED.Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil = EXCLUDED.Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude = EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude = EXCLUDED.Linie_Haltestelle_longitude;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_oepnv_linie()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_OePNV_Linie (
        core_id,
        Linie_liniennummer,
        Linie_bezeichnung,
        Linie_verkehrsmittel,
        Linie_gueltig_ab,
        Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug,
        Linie_Fahrt_datum,
        Linie_fahrtrichtung,
        Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude
    )
    SELECT
        c.Linie_Key,
        c.Linie_liniennummer,
        c.Linie_bezeichnung,
        c.Linie_verkehrsmittel,
        c.Linie_gueltig_ab,
        c.Linie_gueltig_bis,
        c.Linie_Fahrzeug_kapazitaet,
        c.Linie_fahrzeug,
        c.Linie_Fahrt_datum,
        c.Linie_fahrtrichtung,
        c.Linie_Haltestelle_name,
        c.Linie_Haltestelle_stadtteil,
        c.Linie_Haltestelle_latitude,
        c.Linie_Haltestelle_longitude
    FROM core.DIM_Linie AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Linie_liniennummer = EXCLUDED.Linie_liniennummer,
        Linie_bezeichnung = EXCLUDED.Linie_bezeichnung,
        Linie_verkehrsmittel = EXCLUDED.Linie_verkehrsmittel,
        Linie_gueltig_ab = EXCLUDED.Linie_gueltig_ab,
        Linie_gueltig_bis = EXCLUDED.Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet = EXCLUDED.Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug = EXCLUDED.Linie_fahrzeug,
        Linie_Fahrt_datum = EXCLUDED.Linie_Fahrt_datum,
        Linie_fahrtrichtung = EXCLUDED.Linie_fahrtrichtung,
        Linie_Haltestelle_name = EXCLUDED.Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil = EXCLUDED.Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude = EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude = EXCLUDED.Linie_Haltestelle_longitude;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_linie()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Linie (
        core_id,
        Linie_liniennummer,
        Linie_bezeichnung,
        Linie_verkehrsmittel,
        Linie_gueltig_ab,
        Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug,
        Linie_Fahrt_datum,
        Linie_fahrtrichtung,
        Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude
    )
    SELECT
        c.Linie_Key,
        c.Linie_liniennummer,
        c.Linie_bezeichnung,
        c.Linie_verkehrsmittel,
        c.Linie_gueltig_ab,
        c.Linie_gueltig_bis,
        c.Linie_Fahrzeug_kapazitaet,
        c.Linie_fahrzeug,
        c.Linie_Fahrt_datum,
        c.Linie_fahrtrichtung,
        c.Linie_Haltestelle_name,
        c.Linie_Haltestelle_stadtteil,
        c.Linie_Haltestelle_latitude,
        c.Linie_Haltestelle_longitude
    FROM core.DIM_Linie AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Linie_liniennummer = EXCLUDED.Linie_liniennummer,
        Linie_bezeichnung = EXCLUDED.Linie_bezeichnung,
        Linie_verkehrsmittel = EXCLUDED.Linie_verkehrsmittel,
        Linie_gueltig_ab = EXCLUDED.Linie_gueltig_ab,
        Linie_gueltig_bis = EXCLUDED.Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet = EXCLUDED.Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug = EXCLUDED.Linie_fahrzeug,
        Linie_Fahrt_datum = EXCLUDED.Linie_Fahrt_datum,
        Linie_fahrtrichtung = EXCLUDED.Linie_fahrtrichtung,
        Linie_Haltestelle_name = EXCLUDED.Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil = EXCLUDED.Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude = EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude = EXCLUDED.Linie_Haltestelle_longitude;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_oepnv_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.veranstaltungen_und_oepnv_datum (
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        c.Datum_Key,
        c.Stunde,
        c.Datum,
        c.Monat,
        c.Quartal,
        c.Jahr
    FROM core.DIM_Datum AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Stunde = EXCLUDED.Stunde,
        Datum = EXCLUDED.Datum,
        Monat = EXCLUDED.Monat,
        Quartal = EXCLUDED.Quartal,
        Jahr = EXCLUDED.Jahr;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_oepnv_sensor()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.wetter_und_oepnv_Sensor (
        core_id,
        Sensor_name,
        Sensor_stadtteil,
        Sensor_latitude,
        Sensor_longitude,
        Sensor_stations_typ,
        Sensor_station_installationsdatum,
        Sensor_status,
        Sensor_sensortyp,
        Sensor_installationsdatum,
        Sensor_messzeitpunkt
    )
    SELECT
        c.Sensor_key,
        c.Sensor_name,
        c.Sensor_stadtteil,
        c.Sensor_latitude,
        c.Sensor_longitude,
        c.Sensor_stations_typ,
        c.Sensor_station_installationsdatum,
        c.Sensor_status,
        c.Sensor_sensortyp,
        c.Sensor_installationsdatum,
        c.Sensor_messzeitpunkt
    FROM core.DIM_Wettersensor AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Sensor_name = EXCLUDED.Sensor_name,
        Sensor_stadtteil = EXCLUDED.Sensor_stadtteil,
        Sensor_latitude = EXCLUDED.Sensor_latitude,
        Sensor_longitude = EXCLUDED.Sensor_longitude,
        Sensor_stations_typ = EXCLUDED.Sensor_stations_typ,
        Sensor_station_installationsdatum = EXCLUDED.Sensor_station_installationsdatum,
        Sensor_status = EXCLUDED.Sensor_status,
        Sensor_sensortyp = EXCLUDED.Sensor_sensortyp,
        Sensor_installationsdatum = EXCLUDED.Sensor_installationsdatum,
        Sensor_messzeitpunkt = EXCLUDED.Sensor_messzeitpunkt;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_oepnv_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.wetter_und_oepnv_datum (
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        c.Datum_Key,
        c.Stunde,
        c.Datum,
        c.Monat,
        c.Quartal,
        c.Jahr
    FROM core.DIM_Datum AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Stunde = EXCLUDED.Stunde,
        Datum = EXCLUDED.Datum,
        Monat = EXCLUDED.Monat,
        Quartal = EXCLUDED.Quartal,
        Jahr = EXCLUDED.Jahr;
END;
$$;

-- ============================================================
-- Faktentransfers
-- ============================================================

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_fahrradnutzung()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Datumszuordnung prüfen. Der Zeitstempel wird auf den Stundenkey YYYYMMDDHH abgebildet.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Wetter_und_Fahrradnutzung c
        WHERE COALESCE(c.BS_Fahrt_startzeit, c.BS_Fahrt_endzeit) IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM core.DIM_Datum cd
              JOIN reporting.Wetter_und_Fahrradnutzung_Datum rd ON rd.core_id = cd.Datum_Key
              WHERE cd.Datum_Key = TO_CHAR(COALESCE(c.BS_Fahrt_startzeit, c.BS_Fahrt_endzeit), 'YYYYMMDDHH24')::BIGINT
          )
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Datumsdimension in transfer_wetter_und_fahrradnutzung.';
    END IF;

    -- Pflichtzuordnung Fahrradstation prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Wetter_und_Fahrradnutzung c
        WHERE c.src_bs_fahrt_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Fahrradstation cd JOIN reporting.Wetter_und_Fahrradnutzung_Fahradstation r ON r.core_id = cd.Fahrt_key WHERE cd.src_bs_fahrt_id = c.src_bs_fahrt_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Fahrradstation in transfer_wetter_und_fahrradnutzung.';
    END IF;

    -- Pflichtzuordnung Wettersensor prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Wetter_und_Fahrradnutzung c
        WHERE c.src_as_messung_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Wettersensor cd JOIN reporting.Wetter_und_Fahrradnutzung_Sensor r ON r.core_id = cd.Sensor_key WHERE cd.src_as_messung_id = c.src_as_messung_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Wettersensor in transfer_wetter_und_fahrradnutzung.';
    END IF;

    INSERT INTO reporting.Wetter_und_Fahrradnutzung (
        core_id, Fahrt_key, Sensor_key, Fahrradstation_Startzeit, Fahrradstation_Endzeit, Fahrradstation_Startstation_Name, Fahrradstation_Endstation_Name, Wetterstation_Einheit, Wetterstation_Messwert, Datum_Key
    )
    SELECT
        c.id, f.Fahrt_key, s.Sensor_key, c.BS_Fahrt_startzeit, c.BS_Fahrt_endzeit, c.BS_Station_Startstation_name, c.BS_Station_Endstation_name, c.AS_Sensor_einheit, c.AS_Messung_Messwert, d.Datum_Key
    FROM core.Topic_Wetter_und_Fahrradnutzung AS c
    LEFT JOIN core.DIM_Fahrradstation AS cd_f
        ON cd_f.src_bs_fahrt_id = c.src_bs_fahrt_id
    LEFT JOIN reporting.Wetter_und_Fahrradnutzung_Fahradstation AS f
        ON f.core_id = cd_f.Fahrt_key
    LEFT JOIN core.DIM_Wettersensor AS cd_s
        ON cd_s.src_as_messung_id = c.src_as_messung_id
    LEFT JOIN reporting.Wetter_und_Fahrradnutzung_Sensor AS s
        ON s.core_id = cd_s.Sensor_key
    LEFT JOIN core.DIM_Datum AS cdate
        ON cdate.Datum_Key = TO_CHAR(c.BS_Fahrt_startzeit, 'YYYYMMDDHH24')::BIGINT
    LEFT JOIN reporting.Wetter_und_Fahrradnutzung_Datum AS d
        ON d.core_id = cdate.Datum_Key
    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_key = EXCLUDED.Fahrt_key, Sensor_key = EXCLUDED.Sensor_key, Fahrradstation_Startzeit = EXCLUDED.Fahrradstation_Startzeit, Fahrradstation_Endzeit = EXCLUDED.Fahrradstation_Endzeit, Fahrradstation_Startstation_Name = EXCLUDED.Fahrradstation_Startstation_Name, Fahrradstation_Endstation_Name = EXCLUDED.Fahrradstation_Endstation_Name, Wetterstation_Einheit = EXCLUDED.Wetterstation_Einheit, Wetterstation_Messwert = EXCLUDED.Wetterstation_Messwert, Datum_Key = EXCLUDED.Datum_Key;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_oepnv()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Datumszuordnung prüfen. Der Zeitstempel wird auf den Stundenkey YYYYMMDDHH abgebildet.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Veranstaltungen_und_OePNV c
        WHERE COALESCE(c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich) IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM core.DIM_Datum cd
              JOIN reporting.Veranstaltungen_und_OePNV_Datum rd ON rd.core_id = cd.Datum_Key
              WHERE cd.Datum_Key = TO_CHAR(COALESCE(c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich), 'YYYYMMDDHH24')::BIGINT
          )
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Datumsdimension in transfer_veranstaltungen_und_oepnv.';
    END IF;

    -- Pflichtzuordnung Veranstaltung prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Veranstaltungen_und_OePNV c
        WHERE c.src_ce_termin_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Veranstaltung cd JOIN reporting.Veranstaltungen_und_OePNV_Versanstaltung r ON r.core_id = cd.Veranstaltung_Key WHERE cd.src_ce_termin_id = c.src_ce_termin_id AND cd.src_ce_ticket_id = c.src_ce_ticket_id AND cd.src_ce_einlass_id = c.src_ce_einlass_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Veranstaltung in transfer_veranstaltungen_und_oepnv.';
    END IF;

    -- Pflichtzuordnung Linie prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Veranstaltungen_und_OePNV c
        WHERE c.src_cm_fahrt_haltestelle_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Linie cd JOIN reporting.Veranstaltungen_und_OePNV_Linie r ON r.core_id = cd.Linie_Key WHERE cd.src_cm_fahrt_haltestelle_id = c.src_cm_fahrt_haltestelle_id AND cd.src_cm_fahrplan_id = c.src_cm_fahrplan_id AND cd.src_cm_fahrgastaufkommen_id = c.src_cm_fahrgastaufkommen_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Linie in transfer_veranstaltungen_und_oepnv.';
    END IF;

    INSERT INTO reporting.Veranstaltungen_und_OePNV (
        core_id, Veranstaltung_key, Linie_key, Veranstaltung_Beginn_geplant, Veranstaltung_Ende_geplant, Veranstaltung_Beginn_tatsaechlich, Veranstaltung_Ende_tatsaechlich, Veranstaltung_Einlass_status, Veranstaltung_Einlass_Startzeit, Linie_Einsteiger, Linie_Aussteiger, Linie_Ankunft_geplant, Linier_Abfahrt_geplant, Linie_Ankunft_tatsaechlich, Linie_Abfahrt_tatsaechlich, Linie_Haltestelle_Name, Datum_Key
    )
    SELECT
        c.id, v.Veranstaltung_key, l.Linie_key, c.CE_Veranstalter_beginn_geplant, c.CE_Veranstalter_ende_geplant, c.CE_Veranstalter_beginn_tatsaechlich, c.CE_Veranstalter_ende_tatsaechlich, c.CE_Einlass_einlass_status, c.CE_Einlass_einlass_zeitpunkt, c.CM_Fahrgastaufkommen_einsteiger, c.CM_Fahrgastaufkommen_aussteiger, c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrplan_abfahrt_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich, c.CM_Fahrt_Haltestelle_abfahrt_tatsaechlich, c.CM_Haltestelle_name, d.Datum_Key
    FROM core.Topic_Veranstaltungen_und_OePNV AS c
    LEFT JOIN core.DIM_Veranstaltung AS cd_v
        ON cd_v.src_ce_termin_id = c.src_ce_termin_id
       AND cd_v.src_ce_ticket_id = c.src_ce_ticket_id
       AND cd_v.src_ce_einlass_id = c.src_ce_einlass_id
    LEFT JOIN reporting.Veranstaltungen_und_OePNV_Versanstaltung AS v
        ON v.core_id = cd_v.Veranstaltung_Key
    LEFT JOIN core.DIM_Linie AS cd_l
        ON cd_l.src_cm_fahrt_haltestelle_id = c.src_cm_fahrt_haltestelle_id
       AND cd_l.src_cm_fahrplan_id = c.src_cm_fahrplan_id
       AND cd_l.src_cm_fahrgastaufkommen_id = c.src_cm_fahrgastaufkommen_id
    LEFT JOIN reporting.Veranstaltungen_und_OePNV_Linie AS l
        ON l.core_id = cd_l.Linie_Key
    LEFT JOIN core.DIM_Datum AS cdate
        ON cdate.Datum_Key = TO_CHAR(COALESCE(c.CM_Fahrplan_ankunft_geplant,c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich), 'YYYYMMDDHH24')::BIGINT
    LEFT JOIN reporting.Veranstaltungen_und_OePNV_Datum AS d
        ON d.core_id = cdate.Datum_Key
    ON CONFLICT (core_id) DO UPDATE SET
        Veranstaltung_key = EXCLUDED.Veranstaltung_key, Linie_key = EXCLUDED.Linie_key, Veranstaltung_Beginn_geplant = EXCLUDED.Veranstaltung_Beginn_geplant, Veranstaltung_Ende_geplant = EXCLUDED.Veranstaltung_Ende_geplant, Veranstaltung_Beginn_tatsaechlich = EXCLUDED.Veranstaltung_Beginn_tatsaechlich, Veranstaltung_Ende_tatsaechlich = EXCLUDED.Veranstaltung_Ende_tatsaechlich, Veranstaltung_Einlass_status = EXCLUDED.Veranstaltung_Einlass_status, Veranstaltung_Einlass_Startzeit = EXCLUDED.Veranstaltung_Einlass_Startzeit, Linie_Einsteiger = EXCLUDED.Linie_Einsteiger, Linie_Aussteiger = EXCLUDED.Linie_Aussteiger, Linie_Ankunft_geplant = EXCLUDED.Linie_Ankunft_geplant, Linier_Abfahrt_geplant = EXCLUDED.Linier_Abfahrt_geplant, Linie_Ankunft_tatsaechlich = EXCLUDED.Linie_Ankunft_tatsaechlich, Linie_Abfahrt_tatsaechlich = EXCLUDED.Linie_Abfahrt_tatsaechlich, Linie_Haltestelle_Name = EXCLUDED.Linie_Haltestelle_Name, Datum_Key = EXCLUDED.Datum_Key;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_fahrradnutzung()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Datumszuordnung prüfen. Der Zeitstempel wird auf den Stundenkey YYYYMMDDHH abgebildet.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Veranstaltungen_und_Fahrradnutzung c
        WHERE COALESCE(c.BS_Fahrt_startzeit, c.CE_Veranstalter_beginn_tatsaechlich, c.CE_Veranstalter_beginn_geplant) IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM core.DIM_Datum cd
              JOIN reporting.Veranstaltungen_und_Fahrradnutzung_Datum rd ON rd.core_id = cd.Datum_Key
              WHERE cd.Datum_Key = TO_CHAR(COALESCE(c.BS_Fahrt_startzeit, c.CE_Veranstalter_beginn_tatsaechlich, c.CE_Veranstalter_beginn_geplant), 'YYYYMMDDHH24')::BIGINT
          )
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Datumsdimension in transfer_veranstaltungen_und_fahrradnutzung.';
    END IF;

    -- Pflichtzuordnung Veranstaltung prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Veranstaltungen_und_Fahrradnutzung c
        WHERE c.src_ce_termin_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Veranstaltung cd JOIN reporting.Veranstaltungen_und_Fahrradnutzung_Versanstaltung r ON r.core_id = cd.Veranstaltung_Key WHERE cd.src_ce_termin_id = c.src_ce_termin_id AND cd.src_ce_ticket_id = c.src_ce_ticket_id AND cd.src_ce_einlass_id = c.src_ce_einlass_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Veranstaltung in transfer_veranstaltungen_und_fahrradnutzung.';
    END IF;

    -- Pflichtzuordnung Fahrradstation prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Veranstaltungen_und_Fahrradnutzung c
        WHERE c.src_bs_fahrt_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Fahrradstation cd JOIN reporting.Veranstaltungen_und_Fahrradnutzung_Fahradstation r ON r.core_id = cd.Fahrt_key WHERE cd.src_bs_fahrt_id = c.src_bs_fahrt_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Fahrradstation in transfer_veranstaltungen_und_fahrradnutzung.';
    END IF;

    INSERT INTO reporting.Veranstaltungen_und_Fahrradnutzung (
        core_id, Veranstaltung_key, Fahrt_key, Veranstaltung_Beginn_geplant, Veranstaltung_Ende_geplant, Veranstaltung_Beginn_tatsaechlich, Veranstaltung_Ende_tatsaechlich, Veranstaltung_Einlass_status, Veranstaltung_Einlass_Startzeit, Fahrradstation_Startzeit, Fahrradstation_Endzeit, Fahrradstation_Startstation_Name, Fahrradstation_Endstation_Name, Datum_Key
    )
    SELECT
        c.id, v.Veranstaltung_key, f.Fahrt_key, c.CE_Veranstalter_beginn_geplant, c.CE_Veranstalter_ende_geplant, c.CE_Veranstalter_beginn_tatsaechlich, c.CE_Veranstalter_ende_tatsaechlich, c.CE_Einlass_einlass_status, c.CE_Einlass_einlass_zeitpunkt, c.BS_Fahrt_startzeit, c.BS_Fahrt_endzeit, c.BS_Station_Startstation_name, c.BS_Station_Endstation_name, d.Datum_Key
    FROM core.Topic_Veranstaltungen_und_Fahrradnutzung AS c
    LEFT JOIN core.DIM_Veranstaltung AS cd_v
        ON cd_v.src_ce_termin_id = c.src_ce_termin_id
       AND cd_v.src_ce_ticket_id = c.src_ce_ticket_id
       AND cd_v.src_ce_einlass_id = c.src_ce_einlass_id
    LEFT JOIN reporting.Veranstaltungen_und_Fahrradnutzung_Versanstaltung AS v
        ON v.core_id = cd_v.Veranstaltung_Key
    LEFT JOIN core.DIM_Fahrradstation AS cd_f
        ON cd_f.src_bs_fahrt_id = c.src_bs_fahrt_id
    LEFT JOIN reporting.Veranstaltungen_und_Fahrradnutzung_Fahradstation AS f
        ON f.core_id = cd_f.Fahrt_key
    LEFT JOIN core.DIM_Datum AS cdate
        ON cdate.Datum_Key = TO_CHAR(COALESCE(c.BS_Fahrt_startzeit,c.CE_Veranstalter_beginn_tatsaechlich,c.CE_Veranstalter_beginn_geplant), 'YYYYMMDDHH24')::BIGINT
    LEFT JOIN reporting.Veranstaltungen_und_Fahrradnutzung_Datum AS d
        ON d.core_id = cdate.Datum_Key
    ON CONFLICT (core_id) DO UPDATE SET
        Veranstaltung_key = EXCLUDED.Veranstaltung_key, Fahrt_key = EXCLUDED.Fahrt_key, Veranstaltung_Beginn_geplant = EXCLUDED.Veranstaltung_Beginn_geplant, Veranstaltung_Ende_geplant = EXCLUDED.Veranstaltung_Ende_geplant, Veranstaltung_Beginn_tatsaechlich = EXCLUDED.Veranstaltung_Beginn_tatsaechlich, Veranstaltung_Ende_tatsaechlich = EXCLUDED.Veranstaltung_Ende_tatsaechlich, Veranstaltung_Einlass_status = EXCLUDED.Veranstaltung_Einlass_status, Veranstaltung_Einlass_Startzeit = EXCLUDED.Veranstaltung_Einlass_Startzeit, Fahrradstation_Startzeit = EXCLUDED.Fahrradstation_Startzeit, Fahrradstation_Endzeit = EXCLUDED.Fahrradstation_Endzeit, Fahrradstation_Startstation_Name = EXCLUDED.Fahrradstation_Startstation_Name, Fahrradstation_Endstation_Name = EXCLUDED.Fahrradstation_Endstation_Name, Datum_Key = EXCLUDED.Datum_Key;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_oepnv()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Datumszuordnung prüfen. Der Zeitstempel wird auf den Stundenkey YYYYMMDDHH abgebildet.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Wetter_und_OePNV c
        WHERE COALESCE(c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich) IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM core.DIM_Datum cd
              JOIN reporting.Wetter_und_OePNV_Datum rd ON rd.core_id = cd.Datum_Key
              WHERE cd.Datum_Key = TO_CHAR(COALESCE(c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich), 'YYYYMMDDHH24')::BIGINT
          )
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Datumsdimension in transfer_wetter_und_oepnv.';
    END IF;

    -- Pflichtzuordnung Linie prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Wetter_und_OePNV c
        WHERE c.src_cm_fahrt_haltestelle_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Linie cd JOIN reporting.Wetter_und_OePNV_Linie r ON r.core_id = cd.Linie_Key WHERE cd.src_cm_fahrt_haltestelle_id = c.src_cm_fahrt_haltestelle_id AND cd.src_cm_fahrplan_id = c.src_cm_fahrplan_id AND cd.src_cm_fahrgastaufkommen_id = c.src_cm_fahrgastaufkommen_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Linie in transfer_wetter_und_oepnv.';
    END IF;

    -- Pflichtzuordnung Wettersensor prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Wetter_und_OePNV c
        WHERE c.src_as_messung_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Wettersensor cd JOIN reporting.Wetter_und_OePNV_Sensor r ON r.core_id = cd.Sensor_key WHERE cd.src_as_messung_id = c.src_as_messung_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Wettersensor in transfer_wetter_und_oepnv.';
    END IF;

    INSERT INTO reporting.Wetter_und_OePNV (
        core_id, Linie_key, Sensor_key, Linie_Einsteiger, Linie_Aussteiger, Linie_Ankunft_geplant, Linier_Abfahrt_geplant, Linie_Ankunft_tatsaechlich, Linie_Abfahrt_tatsaechlich, Linie_Haltestelle_Name, Wetterstation_Einheit, Wetterstation_Messwert, Datum_Key
    )
    SELECT
        c.id, l.Linie_key, s.Sensor_key, c.CM_Fahrgastaufkommen_einsteiger, c.CM_Fahrgastaufkommen_aussteiger, c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrplan_abfahrt_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich, c.CM_Fahrt_Haltestelle_abfahrt_tatsaechlich, c.CM_Haltestelle_name, c.AS_Sensor_einheit, c.AS_Messung_Messwert, d.Datum_Key
    FROM core.Topic_Wetter_und_OePNV AS c
    LEFT JOIN core.DIM_Linie AS cd_l
        ON cd_l.src_cm_fahrt_haltestelle_id = c.src_cm_fahrt_haltestelle_id
       AND cd_l.src_cm_fahrplan_id = c.src_cm_fahrplan_id
       AND cd_l.src_cm_fahrgastaufkommen_id = c.src_cm_fahrgastaufkommen_id
    LEFT JOIN reporting.Wetter_und_OePNV_Linie AS l
        ON l.core_id = cd_l.Linie_Key
    LEFT JOIN core.DIM_Wettersensor AS cd_s
        ON cd_s.src_as_messung_id = c.src_as_messung_id
    LEFT JOIN reporting.Wetter_und_OePNV_Sensor AS s
        ON s.core_id = cd_s.Sensor_key
    LEFT JOIN core.DIM_Datum AS cdate
        ON cdate.Datum_Key = TO_CHAR(COALESCE(c.CM_Fahrplan_ankunft_geplant,c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich), 'YYYYMMDDHH24')::BIGINT
    LEFT JOIN reporting.Wetter_und_OePNV_Datum AS d
        ON d.core_id = cdate.Datum_Key
    ON CONFLICT (core_id) DO UPDATE SET
        Linie_key = EXCLUDED.Linie_key, Sensor_key = EXCLUDED.Sensor_key, Linie_Einsteiger = EXCLUDED.Linie_Einsteiger, Linie_Aussteiger = EXCLUDED.Linie_Aussteiger, Linie_Ankunft_geplant = EXCLUDED.Linie_Ankunft_geplant, Linier_Abfahrt_geplant = EXCLUDED.Linier_Abfahrt_geplant, Linie_Ankunft_tatsaechlich = EXCLUDED.Linie_Ankunft_tatsaechlich, Linie_Abfahrt_tatsaechlich = EXCLUDED.Linie_Abfahrt_tatsaechlich, Linie_Haltestelle_Name = EXCLUDED.Linie_Haltestelle_Name, Wetterstation_Einheit = EXCLUDED.Wetterstation_Einheit, Wetterstation_Messwert = EXCLUDED.Wetterstation_Messwert, Datum_Key = EXCLUDED.Datum_Key;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Datumszuordnung prüfen. Der Zeitstempel wird auf den Stundenkey YYYYMMDDHH abgebildet.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Luftqualitaet_und_Mobilitaetsaufkommen c
        WHERE COALESCE(c.BS_Fahrt_startzeit, c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich) IS NOT NULL
          AND NOT EXISTS (
              SELECT 1
              FROM core.DIM_Datum cd
              JOIN reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Datum rd ON rd.core_id = cd.Datum_Key
              WHERE cd.Datum_Key = TO_CHAR(COALESCE(c.BS_Fahrt_startzeit, c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich), 'YYYYMMDDHH24')::BIGINT
          )
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Datumsdimension in transfer_luftqualitaet_und_mobilitaetsaufkommen.';
    END IF;

    -- Pflichtzuordnung Fahrradstation prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Luftqualitaet_und_Mobilitaetsaufkommen c
        WHERE c.src_bs_fahrt_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Fahrradstation cd JOIN reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Fahradstation r ON r.core_id = cd.Fahrt_key WHERE cd.src_bs_fahrt_id = c.src_bs_fahrt_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Fahrradstation in transfer_luftqualitaet_und_mobilitaetsaufkommen.';
    END IF;

    -- Pflichtzuordnung Wettersensor prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Luftqualitaet_und_Mobilitaetsaufkommen c
        WHERE c.src_as_messung_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Wettersensor cd JOIN reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Sensor r ON r.core_id = cd.Sensor_key WHERE cd.src_as_messung_id = c.src_as_messung_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Wettersensor in transfer_luftqualitaet_und_mobilitaetsaufkommen.';
    END IF;

    -- Pflichtzuordnung Linie prüfen; fehlende Reporting-Dimension nicht stillschweigend übergehen.
    IF EXISTS (
        SELECT 1
        FROM core.Topic_Luftqualitaet_und_Mobilitaetsaufkommen c
        WHERE c.src_cm_fahrt_haltestelle_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM core.DIM_Linie cd JOIN reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Linie r ON r.core_id = cd.Linie_Key WHERE cd.src_cm_fahrt_haltestelle_id = c.src_cm_fahrt_haltestelle_id AND cd.src_cm_fahrplan_id = c.src_cm_fahrplan_id AND cd.src_cm_fahrgastaufkommen_id = c.src_cm_fahrgastaufkommen_id)
    ) THEN
        RAISE EXCEPTION 'Reporting-Transfer abgebrochen: fehlende Dimension Linie in transfer_luftqualitaet_und_mobilitaetsaufkommen.';
    END IF;

    INSERT INTO reporting.Luftqualitaet_und_Mobilitaetsaufkommen (
        core_id, Fahrt_key, Sensor_key, Linie_key, Fahrradstation_Startzeit, Fahrradstation_Endzeit, Fahrradstation_Startstation_Name, Fahrradstation_Endstation_Name, Wetterstation_Einheit, Wetterstation_Messwert, Linie_Einsteiger, Linie_Aussteiger, Linie_Ankunft_geplant, Linier_Abfahrt_geplant, Linie_Ankunft_tatsaechlich, Linie_Abfahrt_tatsaechlich, Linie_Haltestelle_Name, Datum_Key
    )
    SELECT
        c.id, f.Fahrt_key, s.Sensor_key, l.Linie_key, c.BS_Fahrt_startzeit, c.BS_Fahrt_endzeit, c.BS_Station_Startstation_name, c.BS_Station_Endstation_name, c.AS_Sensor_einheit, c.AS_Messung_Messwert, c.CM_Fahrgastaufkommen_einsteiger, c.CM_Fahrgastaufkommen_aussteiger, c.CM_Fahrplan_ankunft_geplant, c.CM_Fahrplan_abfahrt_geplant, c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich, c.CM_Fahrt_Haltestelle_abfahrt_tatsaechlich, c.CM_Haltestelle_name, d.Datum_Key
    FROM core.Topic_Luftqualitaet_und_Mobilitaetsaufkommen AS c
    LEFT JOIN core.DIM_Fahrradstation AS cd_f
        ON cd_f.src_bs_fahrt_id = c.src_bs_fahrt_id
    LEFT JOIN reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Fahradstation AS f
        ON f.core_id = cd_f.Fahrt_key
    LEFT JOIN core.DIM_Wettersensor AS cd_s
        ON cd_s.src_as_messung_id = c.src_as_messung_id
    LEFT JOIN reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Sensor AS s
        ON s.core_id = cd_s.Sensor_key
    LEFT JOIN core.DIM_Linie AS cd_l
        ON cd_l.src_cm_fahrt_haltestelle_id = c.src_cm_fahrt_haltestelle_id
       AND cd_l.src_cm_fahrplan_id = c.src_cm_fahrplan_id
       AND cd_l.src_cm_fahrgastaufkommen_id = c.src_cm_fahrgastaufkommen_id
    LEFT JOIN reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Linie AS l
        ON l.core_id = cd_l.Linie_Key
    LEFT JOIN core.DIM_Datum AS cdate
        ON cdate.Datum_Key = TO_CHAR(COALESCE(c.BS_Fahrt_startzeit,c.CM_Fahrplan_ankunft_geplant,c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich), 'YYYYMMDDHH24')::BIGINT
    LEFT JOIN reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Datum AS d
        ON d.core_id = cdate.Datum_Key
    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_key = EXCLUDED.Fahrt_key, Sensor_key = EXCLUDED.Sensor_key, Linie_key = EXCLUDED.Linie_key, Fahrradstation_Startzeit = EXCLUDED.Fahrradstation_Startzeit, Fahrradstation_Endzeit = EXCLUDED.Fahrradstation_Endzeit, Fahrradstation_Startstation_Name = EXCLUDED.Fahrradstation_Startstation_Name, Fahrradstation_Endstation_Name = EXCLUDED.Fahrradstation_Endstation_Name, Wetterstation_Einheit = EXCLUDED.Wetterstation_Einheit, Wetterstation_Messwert = EXCLUDED.Wetterstation_Messwert, Linie_Einsteiger = EXCLUDED.Linie_Einsteiger, Linie_Aussteiger = EXCLUDED.Linie_Aussteiger, Linie_Ankunft_geplant = EXCLUDED.Linie_Ankunft_geplant, Linier_Abfahrt_geplant = EXCLUDED.Linier_Abfahrt_geplant, Linie_Ankunft_tatsaechlich = EXCLUDED.Linie_Ankunft_tatsaechlich, Linie_Abfahrt_tatsaechlich = EXCLUDED.Linie_Abfahrt_tatsaechlich, Linie_Haltestelle_Name = EXCLUDED.Linie_Haltestelle_Name, Datum_Key = EXCLUDED.Datum_Key;
END;
$$;

-- ============================================================
-- Empfohlene Aufrufreihenfolge
-- ============================================================
-- Dimensionen zuerst:
-- CALL reporting.transfer_wetter_und_fahrradnutzung_fahradstation();
-- CALL reporting.transfer_wetter_und_fahrradnutzung_sensor();
-- CALL reporting.transfer_wetter_und_fahrradnutzung_datum();
-- CALL reporting.transfer_veranstaltungen_und_oepnv_versanstaltung();
-- CALL reporting.transfer_veranstaltungen_und_oepnv_linie();
-- CALL reporting.transfer_veranstaltungen_und_oepnv_datum();
-- CALL reporting.transfer_veranstaltungen_und_fahrradnutzung_versanstaltung();
-- CALL reporting.transfer_veranstaltungen_und_fahrradnutzung_fahradstation();
-- CALL reporting.transfer_veranstaltungen_und_fahrradnutzung_datum();
-- CALL reporting.transfer_wetter_und_oepnv_linie();
-- CALL reporting.transfer_wetter_und_oepnv_sensor();
-- CALL reporting.transfer_wetter_und_oepnv_datum();
-- CALL reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_fahradstation();
-- CALL reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_sensor();
-- CALL reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_linie();
-- CALL reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_datum();
-- Danach die fünf Faktentransfers:
-- CALL reporting.transfer_wetter_und_fahrradnutzung();
-- CALL reporting.transfer_veranstaltungen_und_oepnv();
-- CALL reporting.transfer_veranstaltungen_und_fahrradnutzung();
-- CALL reporting.transfer_wetter_und_oepnv();
-- CALL reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen();
