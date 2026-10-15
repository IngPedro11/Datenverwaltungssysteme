CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_fahrradnutzung()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_Fahrradnutzung (
        core_id,

        Fahrradstation_Startzeit,
        Fahrradstation_Endzeit,
        Fahrradstation_Status,

        Fahrradstation_Name,
        Fahrradstation_Stadtteil,
        Fahrradstation_Latitude,
        Fahrradstation_Longitude,
        Fahrradstation_Kapazitaet,

        Wetterstation_Name,
        Wetterstation_Stadtteil,
        Wetterstation_Latitude,
        Wetterstation_Longitude,
        Wetterstation_Typ,
        Wetterstation_Installationsdatum,
        Wetterstation_Status,

        Wetterstation_Sensortyp,
        Wetterstation_Einheit,
        Wetterstation_Sensor_Installationsdatum,
        Wetterstation_Messzeitpunkt,
        Wetterstation_Messwert
    )
    SELECT
        c.id,

        c.BS_Fahrt_startzeit,
        c.BS_Fahrt_endzeit,
        c.BS_Fahrt_status,

        c.BS_Station_1_name,
        c.BS_Station_1_stadtteil,
        c.BS_Station_1_latitude,
        c.BS_Station_1_longitude,
        c.BS_Station_1_kapazitaet,

        c.AS_Station_name,
        c.AS_Station_stadtteil,
        c.AS_Station_latitude,
        c.AS_Station_longitude,
        c.AS_Station_stations_typ,
        c.AS_Station_installationsdatum,
        c.AS_Station_status,

        c.AS_Sensor_sensortyp,
        c.AS_Sensor_einheit,
        c.AS_Sensor_installationsdatum,
        c.AS_Messung_messzeitpunkt,
        c.AS_Messung_Messwert

    FROM core.Topic_Wetter_und_Fahrradnutzung c

    ON CONFLICT (core_id)
    DO UPDATE SET
        Fahrradstation_Startzeit = EXCLUDED.Fahrradstation_Startzeit,
        Fahrradstation_Endzeit = EXCLUDED.Fahrradstation_Endzeit,
        Fahrradstation_Status = EXCLUDED.Fahrradstation_Status,

        Fahrradstation_Name = EXCLUDED.Fahrradstation_Name,
        Fahrradstation_Stadtteil = EXCLUDED.Fahrradstation_Stadtteil,
        Fahrradstation_Latitude = EXCLUDED.Fahrradstation_Latitude,
        Fahrradstation_Longitude = EXCLUDED.Fahrradstation_Longitude,
        Fahrradstation_Kapazitaet = EXCLUDED.Fahrradstation_Kapazitaet,

        Wetterstation_Name = EXCLUDED.Wetterstation_Name,
        Wetterstation_Stadtteil = EXCLUDED.Wetterstation_Stadtteil,
        Wetterstation_Latitude = EXCLUDED.Wetterstation_Latitude,
        Wetterstation_Longitude = EXCLUDED.Wetterstation_Longitude,
        Wetterstation_Typ = EXCLUDED.Wetterstation_Typ,
        Wetterstation_Installationsdatum = EXCLUDED.Wetterstation_Installationsdatum,
        Wetterstation_Status = EXCLUDED.Wetterstation_Status,

        Wetterstation_Sensortyp = EXCLUDED.Wetterstation_Sensortyp,
        Wetterstation_Einheit = EXCLUDED.Wetterstation_Einheit,
        Wetterstation_Sensor_Installationsdatum = EXCLUDED.Wetterstation_Sensor_Installationsdatum,
        Wetterstation_Messzeitpunkt = EXCLUDED.Wetterstation_Messzeitpunkt,
        Wetterstation_Messwert = EXCLUDED.Wetterstation_Messwert;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_oepnv()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_OePNV (
        core_id,
        Veranstaltung_Name,
        Veranstaltung_Beschreibung,
        Veranstaltung_Veranstalter_Name,
        Veranstaltung_Veranstalter_Organisationstyp,
        Veranstaltung_Veranstaltungstyp_Bezeichnung,
        Veranstaltung_Beginn_geplant,
        Veranstaltung_Ende_geplant,
        Veranstaltung_Beginn_tatsaechlich,
        Veranstaltung_Ende_tatsaechlich,
        Veranstaltung_Status,
        Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status,
        Veranstaltung_Einlass_status,
        Veranstaltung_Einlass_Startzeit,
        Veranstaltung_Veranstaltungsort_Name,
        Veranstaltung_Stadtteil,
        Veranstaltung_latitude,
        Veranstaltung_longitude,
        Veranstaltung_Kapazitaet,
        Linie_Liniennummer,
        Linie_Bezeichnung,
        Linie_Verkehrsmittel,
        Linie_Gueltig_ab,
        Linie_Gueltig_bis,
        Linie_Kapazitaet,
        Linie_Fahrt_Datum,
        Linie_Fahrtrichtung,
        Linie_Einsteiger,
        Linie_Aussteiger,
        Linie_Ankunft_geplant,
        Linier_Abfahrt_geplant,
        Linie_Ankunft_tatsaechlich,
        Linie_Abfahrt_tatsaechlich,
        Linie_Haltestelle_Name,
        Linie_Haltestelle_Stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude
    )
    SELECT
        c.id,
        c.CE_Veranstaltung_name,
        c.CE_Veranstaltung_beschreibung,
        c.CE_Veranstalter_name,
        c.CE_Veranstalter_organisationstyp,
        c.CE_Veranstaltungstyp_bezeichnung,
        c.CE_Veranstalter_beginn_geplant,
        c.CE_Veranstalter_ende_geplant,
        c.CE_Veranstalter_beginn_tatsaechlich,
        c.CE_Veranstalter_ende_tatsaechlich,
        c.CE_Veranstalter_status,
        c.CE_Ticket_tickettyp,
        c.CE_Ticket_status,
        c.CE_Einlass_einlass_status,
        c.CE_Einlass_einlass_zeitpunkt,
        c.CE_Veranstaltungsort_name,
        c.CE_Veranstaltungsort_stadtteil,
        c.CE_Veranstaltungsort_latitude,
        c.CE_Veranstaltungsort_longitude,
        c.CE_Veranstaltungsort_kapazitaet,
        c.CM_Linie_liniennummer,
        c.CM_Linie_bezeichnung,
        c.CM_Linie_verkehrsmittel,
        c.CM_Linie_gueltig_ab,
        c.CM_Linie_gueltig_bis,
        c.CM_Fahrzeug_kapazitaet,
        c.CM_Fahrt_datum,
        c.CM_Fahrt_fahrtrichtung,
        c.CM_Fahrgastaufkommen_einsteiger,
        c.CM_Fahrgastaufkommen_aussteiger,
        c.CM_Fahrplan_ankunft_geplant,
        c.CM_Fahrplan_abfahrt_geplant,
        c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich,
        c.CM_Fahrt_Haltestelle_abfahrt_tatsaechlich,
        c.CM_Haltestelle_name,
        c.CM_Haltestelle_stadtteil,
        c.CM_Haltestelle_latitude,
        c.CM_Haltestelle_longitude
    FROM core.Topic_Veranstaltungen_und_OePNV AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Veranstaltung_Name = EXCLUDED.Veranstaltung_Name,
        Veranstaltung_Beschreibung = EXCLUDED.Veranstaltung_Beschreibung,
        Veranstaltung_Veranstalter_Name = EXCLUDED.Veranstaltung_Veranstalter_Name,
        Veranstaltung_Veranstalter_Organisationstyp = EXCLUDED.Veranstaltung_Veranstalter_Organisationstyp,
        Veranstaltung_Veranstaltungstyp_Bezeichnung = EXCLUDED.Veranstaltung_Veranstaltungstyp_Bezeichnung,
        Veranstaltung_Beginn_geplant = EXCLUDED.Veranstaltung_Beginn_geplant,
        Veranstaltung_Ende_geplant = EXCLUDED.Veranstaltung_Ende_geplant,
        Veranstaltung_Beginn_tatsaechlich = EXCLUDED.Veranstaltung_Beginn_tatsaechlich,
        Veranstaltung_Ende_tatsaechlich = EXCLUDED.Veranstaltung_Ende_tatsaechlich,
        Veranstaltung_Status = EXCLUDED.Veranstaltung_Status,
        Veranstaltung_tickettyp = EXCLUDED.Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status = EXCLUDED.Veranstaltung_Ticket_status,
        Veranstaltung_Einlass_status = EXCLUDED.Veranstaltung_Einlass_status,
        Veranstaltung_Einlass_Startzeit = EXCLUDED.Veranstaltung_Einlass_Startzeit,
        Veranstaltung_Veranstaltungsort_Name = EXCLUDED.Veranstaltung_Veranstaltungsort_Name,
        Veranstaltung_Stadtteil = EXCLUDED.Veranstaltung_Stadtteil,
        Veranstaltung_latitude = EXCLUDED.Veranstaltung_latitude,
        Veranstaltung_longitude = EXCLUDED.Veranstaltung_longitude,
        Veranstaltung_Kapazitaet = EXCLUDED.Veranstaltung_Kapazitaet,
        Linie_Liniennummer = EXCLUDED.Linie_Liniennummer,
        Linie_Bezeichnung = EXCLUDED.Linie_Bezeichnung,
        Linie_Verkehrsmittel = EXCLUDED.Linie_Verkehrsmittel,
        Linie_Gueltig_ab = EXCLUDED.Linie_Gueltig_ab,
        Linie_Gueltig_bis = EXCLUDED.Linie_Gueltig_bis,
        Linie_Kapazitaet = EXCLUDED.Linie_Kapazitaet,
        Linie_Fahrt_Datum = EXCLUDED.Linie_Fahrt_Datum,
        Linie_Fahrtrichtung = EXCLUDED.Linie_Fahrtrichtung,
        Linie_Einsteiger = EXCLUDED.Linie_Einsteiger,
        Linie_Aussteiger = EXCLUDED.Linie_Aussteiger,
        Linie_Ankunft_geplant = EXCLUDED.Linie_Ankunft_geplant,
        Linier_Abfahrt_geplant = EXCLUDED.Linier_Abfahrt_geplant,
        Linie_Ankunft_tatsaechlich = EXCLUDED.Linie_Ankunft_tatsaechlich,
        Linie_Abfahrt_tatsaechlich = EXCLUDED.Linie_Abfahrt_tatsaechlich,
        Linie_Haltestelle_Name = EXCLUDED.Linie_Haltestelle_Name,
        Linie_Haltestelle_Stadtteil = EXCLUDED.Linie_Haltestelle_Stadtteil,
        Linie_Haltestelle_latitude = EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude = EXCLUDED.Linie_Haltestelle_longitude;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_fahrradnutzung()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_Fahrradnutzung (
        core_id,
        Veranstaltung_Name,
        Veranstaltung_Beschreibung,
        Veranstaltung_Veranstalter_Name,
        Veranstaltung_Veranstalter_Organisationstyp,
        Veranstaltung_Veranstaltungstyp_Bezeichnung,
        Veranstaltung_Beginn_geplant,
        Veranstaltung_Ende_geplant,
        Veranstaltung_Beginn_tatsaechlich,
        Veranstaltung_Ende_tatsaechlich,
        Veranstaltung_Status,
        Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status,
        Veranstaltung_Einlass_status,
        Veranstaltung_Einlass_Startzeit,
        Veranstaltung_Veranstaltungsort_Name,
        Veranstaltung_Stadtteil,
        Veranstaltung_latitude,
        Veranstaltung_longitude,
        Veranstaltung_Kapazitaet,
        Fahrradstation_Startzeit,
        Fahrradstation_Endzeit,
        Fahrradstation_Status,

        Fahrradstation_Name,
        Fahrradstation_Stadtteil,
        Fahrradstation_Latitude,
        Fahrradstation_Longitude,
        Fahrradstation_Kapazitaet
    )
    SELECT
        c.id,
        c.CE_Veranstaltung_name,
        c.CE_Veranstaltung_beschreibung,
        c.CE_Veranstalter_name,
        c.CE_Veranstalter_organisationstyp,
        c.CE_Veranstaltungstyp_bezeichnung,
        c.CE_Veranstalter_beginn_geplant,
        c.CE_Veranstalter_ende_geplant,
        c.CE_Veranstalter_beginn_tatsaechlich,
        c.CE_Veranstalter_ende_tatsaechlich,
        c.CE_Veranstalter_status,
        c.CE_Ticket_tickettyp,
        c.CE_Ticket_status,
        c.CE_Einlass_einlass_status,
        c.CE_Einlass_einlass_zeitpunkt,
        c.CE_Veranstaltungsort_name,
        c.CE_Veranstaltungsort_stadtteil,
        c.CE_Veranstaltungsort_latitude,
        c.CE_Veranstaltungsort_longitude,
        c.CE_Veranstaltungsort_kapazitaet,
        c.BS_Fahrt_startzeit,
        c.BS_Fahrt_endzeit,
        c.BS_Fahrt_status,

        c.BS_Station_1_name,
        c.BS_Station_1_stadtteil,
        c.BS_Station_1_latitude,
        c.BS_Station_1_longitude,
        c.BS_Station_1_kapazitaet
    FROM core.Topic_Veranstaltungen_und_Fahrradnutzung AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Veranstaltung_Name = EXCLUDED.Veranstaltung_Name,
        Veranstaltung_Beschreibung = EXCLUDED.Veranstaltung_Beschreibung,
        Veranstaltung_Veranstalter_Name = EXCLUDED.Veranstaltung_Veranstalter_Name,
        Veranstaltung_Veranstalter_Organisationstyp = EXCLUDED.Veranstaltung_Veranstalter_Organisationstyp,
        Veranstaltung_Veranstaltungstyp_Bezeichnung = EXCLUDED.Veranstaltung_Veranstaltungstyp_Bezeichnung,
        Veranstaltung_Beginn_geplant = EXCLUDED.Veranstaltung_Beginn_geplant,
        Veranstaltung_Ende_geplant = EXCLUDED.Veranstaltung_Ende_geplant,
        Veranstaltung_Beginn_tatsaechlich = EXCLUDED.Veranstaltung_Beginn_tatsaechlich,
        Veranstaltung_Ende_tatsaechlich = EXCLUDED.Veranstaltung_Ende_tatsaechlich,
        Veranstaltung_Status = EXCLUDED.Veranstaltung_Status,
        Veranstaltung_tickettyp = EXCLUDED.Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status = EXCLUDED.Veranstaltung_Ticket_status,
        Veranstaltung_Einlass_status = EXCLUDED.Veranstaltung_Einlass_status,
        Veranstaltung_Einlass_Startzeit = EXCLUDED.Veranstaltung_Einlass_Startzeit,
        Veranstaltung_Veranstaltungsort_Name = EXCLUDED.Veranstaltung_Veranstaltungsort_Name,
        Veranstaltung_Stadtteil = EXCLUDED.Veranstaltung_Stadtteil,
        Veranstaltung_latitude = EXCLUDED.Veranstaltung_latitude,
        Veranstaltung_longitude = EXCLUDED.Veranstaltung_longitude,
        Veranstaltung_Kapazitaet = EXCLUDED.Veranstaltung_Kapazitaet,
        Fahrradstation_Startzeit = EXCLUDED.Fahrradstation_Startzeit,
        Fahrradstation_Endzeit = EXCLUDED.Fahrradstation_Endzeit,
        Fahrradstation_Status = EXCLUDED.Fahrradstation_Status,

        Fahrradstation_Name = EXCLUDED.Fahrradstation_Name,
        Fahrradstation_Stadtteil = EXCLUDED.Fahrradstation_Stadtteil,
        Fahrradstation_Latitude = EXCLUDED.Fahrradstation_Latitude,
        Fahrradstation_Longitude = EXCLUDED.Fahrradstation_Longitude,
        Fahrradstation_Kapazitaet = EXCLUDED.Fahrradstation_Kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_oepnv()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_OePNV (
        core_id,
        Linie_Liniennummer,
        Linie_Bezeichnung,
        Linie_Verkehrsmittel,
        Linie_Gueltig_ab,
        Linie_Gueltig_bis,
        Linie_Kapazitaet,
        Linie_Fahrt_Datum,
        Linie_Fahrtrichtung,
        Linie_Einsteiger,
        Linie_Aussteiger,
        Linie_Ankunft_geplant,
        Linier_Abfahrt_geplant,
        Linie_Ankunft_tatsaechlich,
        Linie_Abfahrt_tatsaechlich,
        Linie_Haltestelle_Name,
        Linie_Haltestelle_Stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude,
        Wetterstation_Name,
        Wetterstation_Stadtteil,
        Wetterstation_Latitude,
        Wetterstation_Longitude,
        Wetterstation_Typ,
        Wetterstation_Installationsdatum,
        Wetterstation_Status,

        Wetterstation_Sensortyp,
        Wetterstation_Einheit,
        Wetterstation_Sensor_Installationsdatum,
        Wetterstation_Messzeitpunkt,
        Wetterstation_Messwert
    )
    SELECT
        c.id,
        c.CM_Linie_liniennummer,
        c.CM_Linie_bezeichnung,
        c.CM_Linie_verkehrsmittel,
        c.CM_Linie_gueltig_ab,
        c.CM_Linie_gueltig_bis,
        c.CM_Fahrzeug_kapazitaet,
        c.CM_Fahrt_datum,
        c.CM_Fahrt_fahrtrichtung,
        c.CM_Fahrgastaufkommen_einsteiger,
        c.CM_Fahrgastaufkommen_aussteiger,
        c.CM_Fahrplan_ankunft_geplant,
        c.CM_Fahrplan_abfahrt_geplant,
        c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich,
        c.CM_Fahrt_Haltestelle_abfahrt_tatsaechlich,
        c.CM_Haltestelle_name,
        c.CM_Haltestelle_stadtteil,
        c.CM_Haltestelle_latitude,
        c.CM_Haltestelle_longitude,
        c.AS_Station_name,
        c.AS_Station_stadtteil,
        c.AS_Station_latitude,
        c.AS_Station_longitude,
        c.AS_Station_stations_typ,
        c.AS_Station_installationsdatum,
        c.AS_Station_status,

        c.AS_Sensor_sensortyp,
        c.AS_Sensor_einheit,
        c.AS_Sensor_installationsdatum,
        c.AS_Messung_messzeitpunkt,
        c.AS_Messung_Messwert
    FROM core.Topic_Wetter_und_OePNV AS c
    ON CONFLICT (core_id) DO UPDATE SET
        Linie_Liniennummer = EXCLUDED.Linie_Liniennummer,
        Linie_Bezeichnung = EXCLUDED.Linie_Bezeichnung,
        Linie_Verkehrsmittel = EXCLUDED.Linie_Verkehrsmittel,
        Linie_Gueltig_ab = EXCLUDED.Linie_Gueltig_ab,
        Linie_Gueltig_bis = EXCLUDED.Linie_Gueltig_bis,
        Linie_Kapazitaet = EXCLUDED.Linie_Kapazitaet,
        Linie_Fahrt_Datum = EXCLUDED.Linie_Fahrt_Datum,
        Linie_Fahrtrichtung = EXCLUDED.Linie_Fahrtrichtung,
        Linie_Einsteiger = EXCLUDED.Linie_Einsteiger,
        Linie_Aussteiger = EXCLUDED.Linie_Aussteiger,
        Linie_Ankunft_geplant = EXCLUDED.Linie_Ankunft_geplant,
        Linier_Abfahrt_geplant = EXCLUDED.Linier_Abfahrt_geplant,
        Linie_Ankunft_tatsaechlich = EXCLUDED.Linie_Ankunft_tatsaechlich,
        Linie_Abfahrt_tatsaechlich = EXCLUDED.Linie_Abfahrt_tatsaechlich,
        Linie_Haltestelle_Name = EXCLUDED.Linie_Haltestelle_Name,
        Linie_Haltestelle_Stadtteil = EXCLUDED.Linie_Haltestelle_Stadtteil,
        Linie_Haltestelle_latitude = EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude = EXCLUDED.Linie_Haltestelle_longitude,
        Wetterstation_Name = EXCLUDED.Wetterstation_Name,
        Wetterstation_Stadtteil = EXCLUDED.Wetterstation_Stadtteil,
        Wetterstation_Latitude = EXCLUDED.Wetterstation_Latitude,
        Wetterstation_Longitude = EXCLUDED.Wetterstation_Longitude,
        Wetterstation_Typ = EXCLUDED.Wetterstation_Typ,
        Wetterstation_Installationsdatum = EXCLUDED.Wetterstation_Installationsdatum,
        Wetterstation_Status = EXCLUDED.Wetterstation_Status,
        Wetterstation_Sensortyp = EXCLUDED.Wetterstation_Sensortyp,
        Wetterstation_Einheit = EXCLUDED.Wetterstation_Einheit,
        Wetterstation_Sensor_Installationsdatum = EXCLUDED.Wetterstation_Sensor_Installationsdatum,
        Wetterstation_Messzeitpunkt = EXCLUDED.Wetterstation_Messzeitpunkt,
        Wetterstation_Messwert = EXCLUDED.Wetterstation_Messwert;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Luftqualitaet_und_Mobilitaetsaufkommen (
        core_id,

        Fahrradstation_Startzeit,
        Fahrradstation_Endzeit,
        Fahrradstation_Status,

        Fahrradstation_Name,
        Fahrradstation_Stadtteil,
        Fahrradstation_Latitude,
        Fahrradstation_Longitude,
        Fahrradstation_Kapazitaet,

        Wetterstation_Name,
        Wetterstation_Stadtteil,
        Wetterstation_Latitude,
        Wetterstation_Longitude,
        Wetterstation_Typ,
        Wetterstation_Installationsdatum,
        Wetterstation_Status,

        Wetterstation_Sensortyp,
        Wetterstation_Einheit,
        Wetterstation_Sensor_Installationsdatum,
        Wetterstation_Messzeitpunkt,
        Wetterstation_Messwert,
        Linie_Liniennummer,
        Linie_Bezeichnung,
        Linie_Verkehrsmittel,
        Linie_Gueltig_ab,
        Linie_Gueltig_bis,
        Linie_Kapazitaet,
        Linie_Fahrt_Datum,
        Linie_Fahrtrichtung,
        Linie_Einsteiger,
        Linie_Aussteiger,
        Linie_Ankunft_geplant,
        Linier_Abfahrt_geplant,
        Linie_Ankunft_tatsaechlich,
        Linie_Abfahrt_tatsaechlich,
        Linie_Haltestelle_Name,
        Linie_Haltestelle_Stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude
    )
    SELECT
        c.id,

        c.BS_Fahrt_startzeit,
        c.BS_Fahrt_endzeit,
        c.BS_Fahrt_status,

        c.BS_Station_1_name,
        c.BS_Station_1_stadtteil,
        c.BS_Station_1_latitude,
        c.BS_Station_1_longitude,
        c.BS_Station_1_kapazitaet,

        c.AS_Station_name,
        c.AS_Station_stadtteil,
        c.AS_Station_latitude,
        c.AS_Station_longitude,
        c.AS_Station_stations_typ,
        c.AS_Station_installationsdatum,
        c.AS_Station_status,

        c.AS_Sensor_sensortyp,
        c.AS_Sensor_einheit,
        c.AS_Sensor_installationsdatum,
        c.AS_Messung_messzeitpunkt,
        c.AS_Messung_Messwert,
        c.CM_Linie_liniennummer,
        c.CM_Linie_bezeichnung,
        c.CM_Linie_verkehrsmittel,
        c.CM_Linie_gueltig_ab,
        c.CM_Linie_gueltig_bis,
        c.CM_Fahrzeug_kapazitaet,
        c.CM_Fahrt_datum,
        c.CM_Fahrt_fahrtrichtung,
        c.CM_Fahrgastaufkommen_einsteiger,
        c.CM_Fahrgastaufkommen_aussteiger,
        c.CM_Fahrplan_ankunft_geplant,
        c.CM_Fahrplan_abfahrt_geplant,
        c.CM_Fahrt_Haltestelle_ankunft_tatsaechlich,
        c.CM_Fahrt_Haltestelle_abfahrt_tatsaechlich,
        c.CM_Haltestelle_name,
        c.CM_Haltestelle_stadtteil,
        c.CM_Haltestelle_latitude,
        c.CM_Haltestelle_longitude
    FROM core.Topic_Luftqualitaet_und_Mobilitaetsaufkommen c

    ON CONFLICT (core_id)
    DO UPDATE SET
        Fahrradstation_Startzeit = EXCLUDED.Fahrradstation_Startzeit,
        Fahrradstation_Endzeit = EXCLUDED.Fahrradstation_Endzeit,
        Fahrradstation_Status = EXCLUDED.Fahrradstation_Status,

        Fahrradstation_Name = EXCLUDED.Fahrradstation_Name,
        Fahrradstation_Stadtteil = EXCLUDED.Fahrradstation_Stadtteil,
        Fahrradstation_Latitude = EXCLUDED.Fahrradstation_Latitude,
        Fahrradstation_Longitude = EXCLUDED.Fahrradstation_Longitude,
        Fahrradstation_Kapazitaet = EXCLUDED.Fahrradstation_Kapazitaet,

        Wetterstation_Name = EXCLUDED.Wetterstation_Name,
        Wetterstation_Stadtteil = EXCLUDED.Wetterstation_Stadtteil,
        Wetterstation_Latitude = EXCLUDED.Wetterstation_Latitude,
        Wetterstation_Longitude = EXCLUDED.Wetterstation_Longitude,
        Wetterstation_Typ = EXCLUDED.Wetterstation_Typ,
        Wetterstation_Installationsdatum = EXCLUDED.Wetterstation_Installationsdatum,
        Wetterstation_Status = EXCLUDED.Wetterstation_Status,

        Wetterstation_Sensortyp = EXCLUDED.Wetterstation_Sensortyp,
        Wetterstation_Einheit = EXCLUDED.Wetterstation_Einheit,
        Wetterstation_Sensor_Installationsdatum = EXCLUDED.Wetterstation_Sensor_Installationsdatum,
        Wetterstation_Messzeitpunkt = EXCLUDED.Wetterstation_Messzeitpunkt,
        Wetterstation_Messwert = EXCLUDED.Wetterstation_Messwert,
        Linie_Liniennummer = EXCLUDED.Linie_Liniennummer,
        Linie_Bezeichnung = EXCLUDED.Linie_Bezeichnung,
        Linie_Verkehrsmittel = EXCLUDED.Linie_Verkehrsmittel,
        Linie_Gueltig_ab = EXCLUDED.Linie_Gueltig_ab,
        Linie_Gueltig_bis = EXCLUDED.Linie_Gueltig_bis,
        Linie_Kapazitaet = EXCLUDED.Linie_Kapazitaet,
        Linie_Fahrt_Datum = EXCLUDED.Linie_Fahrt_Datum,
        Linie_Fahrtrichtung = EXCLUDED.Linie_Fahrtrichtung,
        Linie_Einsteiger = EXCLUDED.Linie_Einsteiger,
        Linie_Aussteiger = EXCLUDED.Linie_Aussteiger,
        Linie_Ankunft_geplant = EXCLUDED.Linie_Ankunft_geplant,
        Linier_Abfahrt_geplant = EXCLUDED.Linier_Abfahrt_geplant,
        Linie_Ankunft_tatsaechlich = EXCLUDED.Linie_Ankunft_tatsaechlich,
        Linie_Abfahrt_tatsaechlich = EXCLUDED.Linie_Abfahrt_tatsaechlich,
        Linie_Haltestelle_Name = EXCLUDED.Linie_Haltestelle_Name,
        Linie_Haltestelle_Stadtteil = EXCLUDED.Linie_Haltestelle_Stadtteil,
        Linie_Haltestelle_latitude = EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude = EXCLUDED.Linie_Haltestelle_longitude;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_fahrradnutzung_fahradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_Fahrradnutzung_Fahradstation (
        core_id,
        Fahrt_startzeit,
        Fahrt_endzeit,
        Fahrt_status,
        Fahrt_Station_Startstation_name,
        Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_name,
        Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet
    )
    SELECT
        d.Fahrt_key,
        d.Fahrt_startzeit,
        d.Fahrt_endzeit,
        d.Fahrt_status,
        d.Fahrt_Station_Startstation_name,
        d.Fahrt_Station_Startstation_stadtteil,
        d.Fahrt_Station_Startstation_latitude,
        d.Fahrt_Station_Startstation_longitude,
        d.Fahrt_Station_Startstation_kapazitaet,
        d.Fahrt_Station_Endstation_name,
        d.Fahrt_Station_Endstation_stadtteil,
        d.Fahrt_Station_Endstation_latitude,
        d.Fahrt_Station_Endstation_longitude,
        d.Fahrt_Station_Endstation_kapazitaet
    FROM core.DIM_Fahrradstation AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_startzeit = EXCLUDED.Fahrt_startzeit,
        Fahrt_endzeit = EXCLUDED.Fahrt_endzeit,
        Fahrt_status = EXCLUDED.Fahrt_status,
        Fahrt_Station_Startstation_name = EXCLUDED.Fahrt_Station_Startstation_name,
        Fahrt_Station_Startstation_stadtteil = EXCLUDED.Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude = EXCLUDED.Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude = EXCLUDED.Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet = EXCLUDED.Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_name = EXCLUDED.Fahrt_Station_Endstation_name,
        Fahrt_Station_Endstation_stadtteil = EXCLUDED.Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude = EXCLUDED.Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude = EXCLUDED.Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet = EXCLUDED.Fahrt_Station_Endstation_kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_fahrradnutzung_fahradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_Fahrradnutzung_Fahradstation (
        core_id,
        Fahrt_startzeit,
        Fahrt_endzeit,
        Fahrt_status,
        Fahrt_Station_Startstation_name,
        Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_name,
        Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet
    )
    SELECT
        d.Fahrt_key,
        d.Fahrt_startzeit,
        d.Fahrt_endzeit,
        d.Fahrt_status,
        d.Fahrt_Station_Startstation_name,
        d.Fahrt_Station_Startstation_stadtteil,
        d.Fahrt_Station_Startstation_latitude,
        d.Fahrt_Station_Startstation_longitude,
        d.Fahrt_Station_Startstation_kapazitaet,
        d.Fahrt_Station_Endstation_name,
        d.Fahrt_Station_Endstation_stadtteil,
        d.Fahrt_Station_Endstation_latitude,
        d.Fahrt_Station_Endstation_longitude,
        d.Fahrt_Station_Endstation_kapazitaet
    FROM core.DIM_Fahrradstation AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_startzeit =
            EXCLUDED.Fahrt_startzeit,
        Fahrt_endzeit =
            EXCLUDED.Fahrt_endzeit,
        Fahrt_status =
            EXCLUDED.Fahrt_status,
        Fahrt_Station_Startstation_name =
            EXCLUDED.Fahrt_Station_Startstation_name,
        Fahrt_Station_Startstation_stadtteil =
            EXCLUDED.Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude =
            EXCLUDED.Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude =
            EXCLUDED.Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet =
            EXCLUDED.Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_name =
            EXCLUDED.Fahrt_Station_Endstation_name,
        Fahrt_Station_Endstation_stadtteil =
            EXCLUDED.Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude =
            EXCLUDED.Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude =
            EXCLUDED.Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet =
            EXCLUDED.Fahrt_Station_Endstation_kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_fahrradnutzung_fahradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_Fahrradnutzung_Fahradstation (
        core_id,
        Fahrt_startzeit,
        Fahrt_endzeit,
        Fahrt_status,
        Fahrt_Station_Startstation_name,
        Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_name,
        Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet
    )
    SELECT
        d.Fahrt_key,
        d.Fahrt_startzeit,
        d.Fahrt_endzeit,
        d.Fahrt_status,
        d.Fahrt_Station_Startstation_name,
        d.Fahrt_Station_Startstation_stadtteil,
        d.Fahrt_Station_Startstation_latitude,
        d.Fahrt_Station_Startstation_longitude,
        d.Fahrt_Station_Startstation_kapazitaet,
        d.Fahrt_Station_Endstation_name,
        d.Fahrt_Station_Endstation_stadtteil,
        d.Fahrt_Station_Endstation_latitude,
        d.Fahrt_Station_Endstation_longitude,
        d.Fahrt_Station_Endstation_kapazitaet
    FROM core.DIM_Fahrradstation AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_startzeit =
            EXCLUDED.Fahrt_startzeit,
        Fahrt_endzeit =
            EXCLUDED.Fahrt_endzeit,
        Fahrt_status =
            EXCLUDED.Fahrt_status,
        Fahrt_Station_Startstation_name =
            EXCLUDED.Fahrt_Station_Startstation_name,
        Fahrt_Station_Startstation_stadtteil =
            EXCLUDED.Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude =
            EXCLUDED.Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude =
            EXCLUDED.Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet =
            EXCLUDED.Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_name =
            EXCLUDED.Fahrt_Station_Endstation_name,
        Fahrt_Station_Endstation_stadtteil =
            EXCLUDED.Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude =
            EXCLUDED.Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude =
            EXCLUDED.Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet =
            EXCLUDED.Fahrt_Station_Endstation_kapazitaet;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_fahradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Fahradstation (
        core_id,
        Fahrt_startzeit,
        Fahrt_endzeit,
        Fahrt_status,
        Fahrt_Station_Startstation_name,
        Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_name,
        Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet
    )
    SELECT
        d.Fahrt_key,
        d.Fahrt_startzeit,
        d.Fahrt_endzeit,
        d.Fahrt_status,
        d.Fahrt_Station_Startstation_name,
        d.Fahrt_Station_Startstation_stadtteil,
        d.Fahrt_Station_Startstation_latitude,
        d.Fahrt_Station_Startstation_longitude,
        d.Fahrt_Station_Startstation_kapazitaet,
        d.Fahrt_Station_Endstation_name,
        d.Fahrt_Station_Endstation_stadtteil,
        d.Fahrt_Station_Endstation_latitude,
        d.Fahrt_Station_Endstation_longitude,
        d.Fahrt_Station_Endstation_kapazitaet
    FROM core.DIM_Fahrradstation AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Fahrt_startzeit =
            EXCLUDED.Fahrt_startzeit,
        Fahrt_endzeit =
            EXCLUDED.Fahrt_endzeit,
        Fahrt_status =
            EXCLUDED.Fahrt_status,
        Fahrt_Station_Startstation_name =
            EXCLUDED.Fahrt_Station_Startstation_name,
        Fahrt_Station_Startstation_stadtteil =
            EXCLUDED.Fahrt_Station_Startstation_stadtteil,
        Fahrt_Station_Startstation_latitude =
            EXCLUDED.Fahrt_Station_Startstation_latitude,
        Fahrt_Station_Startstation_longitude =
            EXCLUDED.Fahrt_Station_Startstation_longitude,
        Fahrt_Station_Startstation_kapazitaet =
            EXCLUDED.Fahrt_Station_Startstation_kapazitaet,
        Fahrt_Station_Endstation_name =
            EXCLUDED.Fahrt_Station_Endstation_name,
        Fahrt_Station_Endstation_stadtteil =
            EXCLUDED.Fahrt_Station_Endstation_stadtteil,
        Fahrt_Station_Endstation_latitude =
            EXCLUDED.Fahrt_Station_Endstation_latitude,
        Fahrt_Station_Endstation_longitude =
            EXCLUDED.Fahrt_Station_Endstation_longitude,
        Fahrt_Station_Endstation_kapazitaet =
            EXCLUDED.Fahrt_Station_Endstation_kapazitaet;
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
        Sensor_einheit,
        Sensor_installationsdatum,
        Sensor_messzeitpunkt,
        Sensor_Messwert
    )
    SELECT
        d.Sensor_Station_key,
        d.Sensor_name,
        d.Sensor_stadtteil,
        d.Sensor_latitude,
        d.Sensor_longitude,
        d.Sensor_stations_typ,
        d.Sensor_station_installationsdatum,
        d.Sensor_status,
        d.Sensor_sensortyp,
        d.Sensor_einheit,
        d.Sensor_installationsdatum,
        d.Sensor_messzeitpunkt,
        d.Sensor_Messwert
    FROM core.DIM_Wettersensor AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Sensor_name =
            EXCLUDED.Sensor_name,
        Sensor_stadtteil =
            EXCLUDED.Sensor_stadtteil,
        Sensor_latitude =
            EXCLUDED.Sensor_latitude,
        Sensor_longitude =
            EXCLUDED.Sensor_longitude,
        Sensor_stations_typ =
            EXCLUDED.Sensor_stations_typ,
        Sensor_station_installationsdatum =
            EXCLUDED.Sensor_station_installationsdatum,
        Sensor_status =
            EXCLUDED.Sensor_status,
        Sensor_sensortyp =
            EXCLUDED.Sensor_sensortyp,
        Sensor_einheit =
            EXCLUDED.Sensor_einheit,
        Sensor_installationsdatum =
            EXCLUDED.Sensor_installationsdatum,
        Sensor_messzeitpunkt =
            EXCLUDED.Sensor_messzeitpunkt,
        Sensor_Messwert =
            EXCLUDED.Sensor_Messwert;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_oepnv_sensor()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_OePNV_Sensor (
        core_id,
        Sensor_name,
        Sensor_stadtteil,
        Sensor_latitude,
        Sensor_longitude,
        Sensor_stations_typ,
        Sensor_station_installationsdatum,
        Sensor_status,
        Sensor_sensortyp,
        Sensor_einheit,
        Sensor_installationsdatum,
        Sensor_messzeitpunkt,
        Sensor_Messwert
    )
    SELECT
        d.Sensor_Station_key,
        d.Sensor_name,
        d.Sensor_stadtteil,
        d.Sensor_latitude,
        d.Sensor_longitude,
        d.Sensor_stations_typ,
        d.Sensor_station_installationsdatum,
        d.Sensor_status,
        d.Sensor_sensortyp,
        d.Sensor_einheit,
        d.Sensor_installationsdatum,
        d.Sensor_messzeitpunkt,
        d.Sensor_Messwert
    FROM core.DIM_Wettersensor AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Sensor_name =
            EXCLUDED.Sensor_name,
        Sensor_stadtteil =
            EXCLUDED.Sensor_stadtteil,
        Sensor_latitude =
            EXCLUDED.Sensor_latitude,
        Sensor_longitude =
            EXCLUDED.Sensor_longitude,
        Sensor_stations_typ =
            EXCLUDED.Sensor_stations_typ,
        Sensor_station_installationsdatum =
            EXCLUDED.Sensor_station_installationsdatum,
        Sensor_status =
            EXCLUDED.Sensor_status,
        Sensor_sensortyp =
            EXCLUDED.Sensor_sensortyp,
        Sensor_einheit =
            EXCLUDED.Sensor_einheit,
        Sensor_installationsdatum =
            EXCLUDED.Sensor_installationsdatum,
        Sensor_messzeitpunkt =
            EXCLUDED.Sensor_messzeitpunkt,
        Sensor_Messwert =
            EXCLUDED.Sensor_Messwert;
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
        Sensor_einheit,
        Sensor_installationsdatum,
        Sensor_messzeitpunkt,
        Sensor_Messwert
    )
    SELECT
        d.Sensor_Station_key,
        d.Sensor_name,
        d.Sensor_stadtteil,
        d.Sensor_latitude,
        d.Sensor_longitude,
        d.Sensor_stations_typ,
        d.Sensor_station_installationsdatum,
        d.Sensor_status,
        d.Sensor_sensortyp,
        d.Sensor_einheit,
        d.Sensor_installationsdatum,
        d.Sensor_messzeitpunkt,
        d.Sensor_Messwert
    FROM core.DIM_Wettersensor AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Sensor_name =
            EXCLUDED.Sensor_name,
        Sensor_stadtteil =
            EXCLUDED.Sensor_stadtteil,
        Sensor_latitude =
            EXCLUDED.Sensor_latitude,
        Sensor_longitude =
            EXCLUDED.Sensor_longitude,
        Sensor_stations_typ =
            EXCLUDED.Sensor_stations_typ,
        Sensor_station_installationsdatum =
            EXCLUDED.Sensor_station_installationsdatum,
        Sensor_status =
            EXCLUDED.Sensor_status,
        Sensor_sensortyp =
            EXCLUDED.Sensor_sensortyp,
        Sensor_einheit =
            EXCLUDED.Sensor_einheit,
        Sensor_installationsdatum =
            EXCLUDED.Sensor_installationsdatum,
        Sensor_messzeitpunkt =
            EXCLUDED.Sensor_messzeitpunkt,
        Sensor_Messwert =
            EXCLUDED.Sensor_Messwert;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_fahrradnutzung_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_Fahrradnutzung_Datum (
        Datum_Key,
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        d.Datum_Key,
        d.Datum_Key,
        d.Stunde,
        d.Datum,
        d.Monat,
        d.Quartal,
        d.Jahr
    FROM core.DIM_Datum AS d

    ON CONFLICT (Datum_Key) DO UPDATE SET
        core_id = EXCLUDED.core_id,
        Stunde = EXCLUDED.Stunde,
        Datum = EXCLUDED.Datum,
        Monat = EXCLUDED.Monat,
        Quartal = EXCLUDED.Quartal,
        Jahr = EXCLUDED.Jahr;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_veranstaltungen_und_oepnv_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Veranstaltungen_und_OePNV_Datum (
        Datum_Key,
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        d.Datum_Key,
        d.Datum_Key,
        d.Stunde,
        d.Datum,
        d.Monat,
        d.Quartal,
        d.Jahr
    FROM core.DIM_Datum AS d

    ON CONFLICT (Datum_Key) DO UPDATE SET
        core_id = EXCLUDED.core_id,
        Stunde = EXCLUDED.Stunde,
        Datum = EXCLUDED.Datum,
        Monat = EXCLUDED.Monat,
        Quartal = EXCLUDED.Quartal,
        Jahr = EXCLUDED.Jahr;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_wetter_und_oepnv_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Wetter_und_OePNV_Datum (
        Datum_Key,
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        d.Datum_Key,
        d.Datum_Key,
        d.Stunde,
        d.Datum,
        d.Monat,
        d.Quartal,
        d.Jahr
    FROM core.DIM_Datum AS d

    ON CONFLICT (Datum_Key) DO UPDATE SET
        core_id = EXCLUDED.core_id,
        Stunde = EXCLUDED.Stunde,
        Datum = EXCLUDED.Datum,
        Monat = EXCLUDED.Monat,
        Quartal = EXCLUDED.Quartal,
        Jahr = EXCLUDED.Jahr;
END;
$$;

CREATE OR REPLACE PROCEDURE reporting.transfer_luftqualitaet_und_mobilitaetsaufkommen_datum()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Datum (
        Datum_Key,
        core_id,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        d.Datum_Key,
        d.Datum_Key,
        d.Stunde,
        d.Datum,
        d.Monat,
        d.Quartal,
        d.Jahr
    FROM core.DIM_Datum AS d

    ON CONFLICT (Datum_Key) DO UPDATE SET
        core_id = EXCLUDED.core_id,
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
        Veranstaltung_beginn_geplant,
        Veranstaltung_ende_geplant,
        Veranstaltung_beginn_tatsaechlich,
        Veranstaltung_ende_tatsaechlich,
        Veranstaltung_termin_status,
        Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status,
        Veranstaltung_einlass_status,
        Veranstaltung_einlass_zeitpunkt,
        Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil,
        Veranstaltung_latitude,
        Veranstaltung_longitude,
        Veranstaltung_kapazitaet
    )
    SELECT
        d.Veranstaltung_Key,
        d.Veranstaltung_name,
        d.Veranstaltung_beschreibung,
        d.Veranstaltung_Veranstalter_name,
        d.Veranstaltung_Veranstalter_organisationstyp,
        d.Veranstaltung_Veranstaltungstyp,
        d.Veranstaltung_beginn_geplant,
        d.Veranstaltung_ende_geplant,
        d.Veranstaltung_beginn_tatsaechlich,
        d.Veranstaltung_ende_tatsaechlich,
        d.Veranstaltung_termin_status,
        d.Veranstaltung_tickettyp,
        d.Veranstaltung_Ticket_status,
        d.Veranstaltung_einlass_status,
        d.Veranstaltung_einlass_zeitpunkt,
        d.Veranstaltung_Veranstaltungsort_name,
        d.Veranstaltung_stadtteil,
        d.Veranstaltung_latitude,
        d.Veranstaltung_longitude,
        d.Veranstaltung_kapazitaet
    FROM core.DIM_Veranstaltung AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Veranstaltung_name =
            EXCLUDED.Veranstaltung_name,
        Veranstaltung_beschreibung =
            EXCLUDED.Veranstaltung_beschreibung,
        Veranstaltung_Veranstalter_name =
            EXCLUDED.Veranstaltung_Veranstalter_name,
        Veranstaltung_Veranstalter_organisationstyp =
            EXCLUDED.Veranstaltung_Veranstalter_organisationstyp,
        Veranstaltung_Veranstaltungstyp =
            EXCLUDED.Veranstaltung_Veranstaltungstyp,
        Veranstaltung_beginn_geplant =
            EXCLUDED.Veranstaltung_beginn_geplant,
        Veranstaltung_ende_geplant =
            EXCLUDED.Veranstaltung_ende_geplant,
        Veranstaltung_beginn_tatsaechlich =
            EXCLUDED.Veranstaltung_beginn_tatsaechlich,
        Veranstaltung_ende_tatsaechlich =
            EXCLUDED.Veranstaltung_ende_tatsaechlich,
        Veranstaltung_termin_status =
            EXCLUDED.Veranstaltung_termin_status,
        Veranstaltung_tickettyp =
            EXCLUDED.Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status =
            EXCLUDED.Veranstaltung_Ticket_status,
        Veranstaltung_einlass_status =
            EXCLUDED.Veranstaltung_einlass_status,
        Veranstaltung_einlass_zeitpunkt =
            EXCLUDED.Veranstaltung_einlass_zeitpunkt,
        Veranstaltung_Veranstaltungsort_name =
            EXCLUDED.Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil =
            EXCLUDED.Veranstaltung_stadtteil,
        Veranstaltung_latitude =
            EXCLUDED.Veranstaltung_latitude,
        Veranstaltung_longitude =
            EXCLUDED.Veranstaltung_longitude,
        Veranstaltung_kapazitaet =
            EXCLUDED.Veranstaltung_kapazitaet;
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
        Veranstaltung_beginn_geplant,
        Veranstaltung_ende_geplant,
        Veranstaltung_beginn_tatsaechlich,
        Veranstaltung_ende_tatsaechlich,
        Veranstaltung_termin_status,
        Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status,
        Veranstaltung_einlass_status,
        Veranstaltung_einlass_zeitpunkt,
        Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil,
        Veranstaltung_latitude,
        Veranstaltung_longitude,
        Veranstaltung_kapazitaet
    )
    SELECT
        d.Veranstaltung_Key,
        d.Veranstaltung_name,
        d.Veranstaltung_beschreibung,
        d.Veranstaltung_Veranstalter_name,
        d.Veranstaltung_Veranstalter_organisationstyp,
        d.Veranstaltung_Veranstaltungstyp,
        d.Veranstaltung_beginn_geplant,
        d.Veranstaltung_ende_geplant,
        d.Veranstaltung_beginn_tatsaechlich,
        d.Veranstaltung_ende_tatsaechlich,
        d.Veranstaltung_termin_status,
        d.Veranstaltung_tickettyp,
        d.Veranstaltung_Ticket_status,
        d.Veranstaltung_einlass_status,
        d.Veranstaltung_einlass_zeitpunkt,
        d.Veranstaltung_Veranstaltungsort_name,
        d.Veranstaltung_stadtteil,
        d.Veranstaltung_latitude,
        d.Veranstaltung_longitude,
        d.Veranstaltung_kapazitaet
    FROM core.DIM_Veranstaltung AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Veranstaltung_name =
            EXCLUDED.Veranstaltung_name,
        Veranstaltung_beschreibung =
            EXCLUDED.Veranstaltung_beschreibung,
        Veranstaltung_Veranstalter_name =
            EXCLUDED.Veranstaltung_Veranstalter_name,
        Veranstaltung_Veranstalter_organisationstyp =
            EXCLUDED.Veranstaltung_Veranstalter_organisationstyp,
        Veranstaltung_Veranstaltungstyp =
            EXCLUDED.Veranstaltung_Veranstaltungstyp,
        Veranstaltung_beginn_geplant =
            EXCLUDED.Veranstaltung_beginn_geplant,
        Veranstaltung_ende_geplant =
            EXCLUDED.Veranstaltung_ende_geplant,
        Veranstaltung_beginn_tatsaechlich =
            EXCLUDED.Veranstaltung_beginn_tatsaechlich,
        Veranstaltung_ende_tatsaechlich =
            EXCLUDED.Veranstaltung_ende_tatsaechlich,
        Veranstaltung_termin_status =
            EXCLUDED.Veranstaltung_termin_status,
        Veranstaltung_tickettyp =
            EXCLUDED.Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status =
            EXCLUDED.Veranstaltung_Ticket_status,
        Veranstaltung_einlass_status =
            EXCLUDED.Veranstaltung_einlass_status,
        Veranstaltung_einlass_zeitpunkt =
            EXCLUDED.Veranstaltung_einlass_zeitpunkt,
        Veranstaltung_Veranstaltungsort_name =
            EXCLUDED.Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil =
            EXCLUDED.Veranstaltung_stadtteil,
        Veranstaltung_latitude =
            EXCLUDED.Veranstaltung_latitude,
        Veranstaltung_longitude =
            EXCLUDED.Veranstaltung_longitude,
        Veranstaltung_kapazitaet =
            EXCLUDED.Veranstaltung_kapazitaet;
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
        Linie_einsteiger,
        Linie_aussteiger,
        Linie_ankunft_geplant,
        Linie_abfahrt_geplant,
        Linie_ankunft_tatsaechlich,
        Linie_abfahrt_tatsaechlich,
        Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude
    )
    SELECT
        d.Linie_Key,
        d.Linie_liniennummer,
        d.Linie_bezeichnung,
        d.Linie_verkehrsmittel,
        d.Linie_gueltig_ab,
        d.Linie_gueltig_bis,
        d.Linie_Fahrzeug_kapazitaet,
        d.Linie_fahrzeug,
        d.Linie_Fahrt_datum,
        d.Linie_fahrtrichtung,
        d.Linie_einsteiger,
        d.Linie_aussteiger,
        d.Linie_ankunft_geplant,
        d.Linie_abfahrt_geplant,
        d.Linie_ankunft_tatsaechlich,
        d.Linie_abfahrt_tatsaechlich,
        d.Linie_Haltestelle_name,
        d.Linie_Haltestelle_stadtteil,
        d.Linie_Haltestelle_latitude,
        d.Linie_Haltestelle_longitude
    FROM core.DIM_Linie AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Linie_liniennummer =
            EXCLUDED.Linie_liniennummer,
        Linie_bezeichnung =
            EXCLUDED.Linie_bezeichnung,
        Linie_verkehrsmittel =
            EXCLUDED.Linie_verkehrsmittel,
        Linie_gueltig_ab =
            EXCLUDED.Linie_gueltig_ab,
        Linie_gueltig_bis =
            EXCLUDED.Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet =
            EXCLUDED.Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug =
            EXCLUDED.Linie_fahrzeug,
        Linie_Fahrt_datum =
            EXCLUDED.Linie_Fahrt_datum,
        Linie_fahrtrichtung =
            EXCLUDED.Linie_fahrtrichtung,
        Linie_einsteiger =
            EXCLUDED.Linie_einsteiger,
        Linie_aussteiger =
            EXCLUDED.Linie_aussteiger,
        Linie_ankunft_geplant =
            EXCLUDED.Linie_ankunft_geplant,
        Linie_abfahrt_geplant =
            EXCLUDED.Linie_abfahrt_geplant,
        Linie_ankunft_tatsaechlich =
            EXCLUDED.Linie_ankunft_tatsaechlich,
        Linie_abfahrt_tatsaechlich =
            EXCLUDED.Linie_abfahrt_tatsaechlich,
        Linie_Haltestelle_name =
            EXCLUDED.Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil =
            EXCLUDED.Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude =
            EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude =
            EXCLUDED.Linie_Haltestelle_longitude;
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
        Linie_einsteiger,
        Linie_aussteiger,
        Linie_ankunft_geplant,
        Linie_abfahrt_geplant,
        Linie_ankunft_tatsaechlich,
        Linie_abfahrt_tatsaechlich,
        Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude
    )
    SELECT
        d.Linie_Key,
        d.Linie_liniennummer,
        d.Linie_bezeichnung,
        d.Linie_verkehrsmittel,
        d.Linie_gueltig_ab,
        d.Linie_gueltig_bis,
        d.Linie_Fahrzeug_kapazitaet,
        d.Linie_fahrzeug,
        d.Linie_Fahrt_datum,
        d.Linie_fahrtrichtung,
        d.Linie_einsteiger,
        d.Linie_aussteiger,
        d.Linie_ankunft_geplant,
        d.Linie_abfahrt_geplant,
        d.Linie_ankunft_tatsaechlich,
        d.Linie_abfahrt_tatsaechlich,
        d.Linie_Haltestelle_name,
        d.Linie_Haltestelle_stadtteil,
        d.Linie_Haltestelle_latitude,
        d.Linie_Haltestelle_longitude
    FROM core.DIM_Linie AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Linie_liniennummer =
            EXCLUDED.Linie_liniennummer,
        Linie_bezeichnung =
            EXCLUDED.Linie_bezeichnung,
        Linie_verkehrsmittel =
            EXCLUDED.Linie_verkehrsmittel,
        Linie_gueltig_ab =
            EXCLUDED.Linie_gueltig_ab,
        Linie_gueltig_bis =
            EXCLUDED.Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet =
            EXCLUDED.Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug =
            EXCLUDED.Linie_fahrzeug,
        Linie_Fahrt_datum =
            EXCLUDED.Linie_Fahrt_datum,
        Linie_fahrtrichtung =
            EXCLUDED.Linie_fahrtrichtung,
        Linie_einsteiger =
            EXCLUDED.Linie_einsteiger,
        Linie_aussteiger =
            EXCLUDED.Linie_aussteiger,
        Linie_ankunft_geplant =
            EXCLUDED.Linie_ankunft_geplant,
        Linie_abfahrt_geplant =
            EXCLUDED.Linie_abfahrt_geplant,
        Linie_ankunft_tatsaechlich =
            EXCLUDED.Linie_ankunft_tatsaechlich,
        Linie_abfahrt_tatsaechlich =
            EXCLUDED.Linie_abfahrt_tatsaechlich,
        Linie_Haltestelle_name =
            EXCLUDED.Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil =
            EXCLUDED.Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude =
            EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude =
            EXCLUDED.Linie_Haltestelle_longitude;
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
        Linie_einsteiger,
        Linie_aussteiger,
        Linie_ankunft_geplant,
        Linie_abfahrt_geplant,
        Linie_ankunft_tatsaechlich,
        Linie_abfahrt_tatsaechlich,
        Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude
    )
    SELECT
        d.Linie_Key,
        d.Linie_liniennummer,
        d.Linie_bezeichnung,
        d.Linie_verkehrsmittel,
        d.Linie_gueltig_ab,
        d.Linie_gueltig_bis,
        d.Linie_Fahrzeug_kapazitaet,
        d.Linie_fahrzeug,
        d.Linie_Fahrt_datum,
        d.Linie_fahrtrichtung,
        d.Linie_einsteiger,
        d.Linie_aussteiger,
        d.Linie_ankunft_geplant,
        d.Linie_abfahrt_geplant,
        d.Linie_ankunft_tatsaechlich,
        d.Linie_abfahrt_tatsaechlich,
        d.Linie_Haltestelle_name,
        d.Linie_Haltestelle_stadtteil,
        d.Linie_Haltestelle_latitude,
        d.Linie_Haltestelle_longitude
    FROM core.DIM_Linie AS d

    ON CONFLICT (core_id) DO UPDATE SET
        Linie_liniennummer =
            EXCLUDED.Linie_liniennummer,
        Linie_bezeichnung =
            EXCLUDED.Linie_bezeichnung,
        Linie_verkehrsmittel =
            EXCLUDED.Linie_verkehrsmittel,
        Linie_gueltig_ab =
            EXCLUDED.Linie_gueltig_ab,
        Linie_gueltig_bis =
            EXCLUDED.Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet =
            EXCLUDED.Linie_Fahrzeug_kapazitaet,
        Linie_fahrzeug =
            EXCLUDED.Linie_fahrzeug,
        Linie_Fahrt_datum =
            EXCLUDED.Linie_Fahrt_datum,
        Linie_fahrtrichtung =
            EXCLUDED.Linie_fahrtrichtung,
        Linie_einsteiger =
            EXCLUDED.Linie_einsteiger,
        Linie_aussteiger =
            EXCLUDED.Linie_aussteiger,
        Linie_ankunft_geplant =
            EXCLUDED.Linie_ankunft_geplant,
        Linie_abfahrt_geplant =
            EXCLUDED.Linie_abfahrt_geplant,
        Linie_ankunft_tatsaechlich =
            EXCLUDED.Linie_ankunft_tatsaechlich,
        Linie_abfahrt_tatsaechlich =
            EXCLUDED.Linie_abfahrt_tatsaechlich,
        Linie_Haltestelle_name =
            EXCLUDED.Linie_Haltestelle_name,
        Linie_Haltestelle_stadtteil =
            EXCLUDED.Linie_Haltestelle_stadtteil,
        Linie_Haltestelle_latitude =
            EXCLUDED.Linie_Haltestelle_latitude,
        Linie_Haltestelle_longitude =
            EXCLUDED.Linie_Haltestelle_longitude;
END;
$$;