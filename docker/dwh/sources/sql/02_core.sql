CREATE SCHEMA core;

CREATE TABLE core.Topic_Wetter_und_Fahrradnutzung (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    src_bs_fahrt_id INT,
    src_as_messung_id BIGINT,
    BS_Fahrt_id_startstation INT,
    BS_Fahrt_id_endstation INT,
    BS_Fahrt_startzeit TIMESTAMP,
    BS_Fahrt_endzeit TIMESTAMP,
    BS_Station_Startstation_name VARCHAR(100),
    BS_Station_Endstation_name VARCHAR(100),
    AS_Sensor_einheit VARCHAR(20),
    AS_Sensor_id_sensor BIGINT,
    AS_Messung_Messwert DECIMAL(10,2)
);

CREATE TABLE core.Topic_Veranstaltungen_und_OePNV (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    src_ce_termin_id BIGINT,
    src_ce_ticket_id BIGINT,
    src_ce_einlass_id BIGINT,
    src_cm_fahrt_haltestelle_id INT,
    src_cm_fahrplan_id INT,
    src_cm_fahrgastaufkommen_id INT,

    CE_Veranstaltung_id_typ BIGINT,
    CE_Veranstaltung_id_veranstalter BIGINT,
    CE_Veranstaltungstermin_id_veranstaltung BIGINT,

    CE_Veranstalter_id_veranstaltungsort BIGINT,
    CE_Veranstalter_beginn_geplant TIMESTAMP,
    CE_Veranstalter_ende_geplant TIMESTAMP,
    CE_Veranstalter_beginn_tatsaechlich TIMESTAMP,
    CE_Veranstalter_ende_tatsaechlich TIMESTAMP,

    CE_Ticket_id_termin BIGINT,
    CE_Einlass_id_ticket BIGINT,
    CE_Einlass_einlass_status VARCHAR(20),
    CE_Einlass_einlass_zeitpunkt TIMESTAMP,

    CM_Fahrt_id_linie INT,
    CM_Fahrt_fahrzeug INT,

    CM_Fahrgastaufkommen_id_fahrt INT,
    CM_Fahrgastaufkommen_id_haltestelle INT,
    CM_Fahrgastaufkommen_einsteiger INT,
    CM_Fahrgastaufkommen_aussteiger INT,

    CM_Fahrplan_id_fahrt INT,
    CM_Fahrplan_id_haltestelle INT,
    CM_Fahrplan_ankunft_geplant TIMESTAMP,
    CM_Fahrplan_abfahrt_geplant TIMESTAMP,

    CM_Fahrt_Haltestelle_id_fahrt INT,
    CM_Fahrt_Haltestelle_id_haltestelle INT,
    CM_Fahrt_Haltestelle_ankunft_tatsaechlich TIMESTAMP,
    CM_Fahrt_Haltestelle_abfahrt_tatsaechlich TIMESTAMP,

    CM_Haltestelle_name VARCHAR(100)
);

CREATE TABLE core.Topic_Veranstaltungen_und_Fahrradnutzung (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    src_ce_termin_id BIGINT,
    src_ce_ticket_id BIGINT,
    src_ce_einlass_id BIGINT,
    src_bs_fahrt_id INT,

    CE_Veranstaltung_id_typ BIGINT,
    CE_Veranstaltung_id_veranstalter BIGINT,

    CE_Veranstaltungstermin_id_veranstaltung BIGINT,
    CE_Veranstalter_id_veranstaltungsort BIGINT,
    CE_Veranstalter_beginn_geplant TIMESTAMP,
    CE_Veranstalter_ende_geplant TIMESTAMP,
    CE_Veranstalter_beginn_tatsaechlich TIMESTAMP,
    CE_Veranstalter_ende_tatsaechlich TIMESTAMP,

    CE_Ticket_id_termin BIGINT,
    CE_Einlass_id_ticket BIGINT,
    CE_Einlass_einlass_status VARCHAR(20),
    CE_Einlass_einlass_zeitpunkt TIMESTAMP,

    BS_Fahrt_id_startstation INT,
    BS_Fahrt_id_endstation INT,
    BS_Fahrt_startzeit TIMESTAMP,
    BS_Fahrt_endzeit TIMESTAMP,
    BS_Station_Startstation_name VARCHAR(100),
    BS_Station_Endstation_name VARCHAR(100)
);

CREATE TABLE core.Topic_Wetter_und_OePNV (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    src_as_messung_id BIGINT,
    src_cm_fahrt_haltestelle_id INT,
    src_cm_fahrplan_id INT,
    src_cm_fahrgastaufkommen_id INT,

    CM_Fahrt_id_linie INT,
    CM_Fahrt_fahrzeug INT,

    CM_Fahrgastaufkommen_id_fahrt INT,
    CM_Fahrgastaufkommen_id_haltestelle INT,
    CM_Fahrgastaufkommen_einsteiger INT,
    CM_Fahrgastaufkommen_aussteiger INT,

    CM_Fahrplan_id_fahrt INT,
    CM_Fahrplan_id_haltestelle INT,
    CM_Fahrplan_ankunft_geplant TIMESTAMP,
    CM_Fahrplan_abfahrt_geplant TIMESTAMP,

    CM_Fahrt_Haltestelle_id_fahrt INT,
    CM_Fahrt_Haltestelle_id_haltestelle INT,
    CM_Fahrt_Haltestelle_ankunft_tatsaechlich TIMESTAMP,
    CM_Fahrt_Haltestelle_abfahrt_tatsaechlich TIMESTAMP,

    CM_Haltestelle_name VARCHAR(100),

    AS_Sensor_einheit VARCHAR(20),
    AS_Sensor_id_sensor BIGINT,
    AS_Messung_Messwert DECIMAL(10,2)
);

CREATE TABLE core.Topic_Luftqualitaet_und_Mobilitaetsaufkommen (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    src_bs_fahrt_id INT,
    src_as_messung_id BIGINT,
    src_cm_fahrt_haltestelle_id INT,
    src_cm_fahrplan_id INT,
    src_cm_fahrgastaufkommen_id INT,

    BS_Fahrt_id_startstation INT,
    BS_Fahrt_id_endstation INT,
    BS_Fahrt_startzeit TIMESTAMP,
    BS_Fahrt_endzeit TIMESTAMP,
    BS_Station_Startstation_name VARCHAR(100),
    BS_Station_Endstation_name VARCHAR(100),

    AS_Sensor_einheit VARCHAR(20),
    AS_Sensor_id_sensor BIGINT,
    AS_Messung_Messwert DECIMAL(10,2),

    CM_Fahrt_id_linie INT,
    CM_Fahrt_fahrzeug INT,

    CM_Fahrgastaufkommen_id_fahrt INT,
    CM_Fahrgastaufkommen_id_haltestelle INT,
    CM_Fahrgastaufkommen_einsteiger INT,
    CM_Fahrgastaufkommen_aussteiger INT,

    CM_Fahrplan_id_fahrt INT,
    CM_Fahrplan_id_haltestelle INT,
    CM_Fahrplan_ankunft_geplant TIMESTAMP,
    CM_Fahrplan_abfahrt_geplant TIMESTAMP,
    
    CM_Fahrt_Haltestelle_id_fahrt INT,
    CM_Fahrt_Haltestelle_id_haltestelle INT,
    CM_Fahrt_Haltestelle_ankunft_tatsaechlich TIMESTAMP,
    CM_Fahrt_Haltestelle_abfahrt_tatsaechlich TIMESTAMP,
    CM_Haltestelle_name VARCHAR(100)
);

CREATE TABLE core.DIM_Fahrradstation (
    Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    src_bs_fahrt_id INT,
    Fahrt_id_startstation INT,
    Fahrt_id_endstation INT,
    Fahrt_status VARCHAR(20),
    Fahrt_Station_Startstation_stadtteil VARCHAR(100),
    Fahrt_Station_Startstation_latitude DECIMAL(10,7),
    Fahrt_Station_Startstation_longitude DECIMAL(10,7),
    Fahrt_Station_Startstation_kapazitaet INT,
    Fahrt_Station_Endstation_stadtteil VARCHAR(100),
    Fahrt_Station_Endstation_latitude DECIMAL(10,7),
    Fahrt_Station_Endstation_longitude DECIMAL(10,7),
    Fahrt_Station_Endstation_kapazitaet INT
);

CREATE TABLE core.DIM_Wettersensor (
    Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY Primary KEY,
    src_as_messung_id BIGINT,
    Sensor_name VARCHAR(100),
    Sensor_stadtteil VARCHAR(100),
    Sensor_latitude DECIMAL(10,7),
    Sensor_longitude DECIMAL(10,7),
    Sensor_stations_typ VARCHAR(30),
    Sensor_station_installationsdatum DATE,
    Sensor_status VARCHAR(20),
    Sensor_id_station BIGINT,
    Sensor_sensortyp VARCHAR(50),
    Sensor_installationsdatum DATE,
    Sensor_id_sensor BIGINT,
    Sensor_messzeitpunkt TIMESTAMP
);

CREATE TABLE core.DIM_Datum (
    Datum_Key BIGINT PRIMARY KEY,
    Stunde    SMALLINT,
    Datum     DATE,
    Monat     SMALLINT,
    Quartal   SMALLINT,
    Jahr      SMALLINT
);

CREATE TABLE core.DIM_Veranstaltung (
    Veranstaltung_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    src_ce_veranstaltung_id BIGINT,
    src_ce_termin_id BIGINT,
    src_ce_ticket_id BIGINT,
    src_ce_einlass_id BIGINT,
    Veranstaltung_name VARCHAR(100),
    Veranstaltung_beschreibung VARCHAR(255),
    Veranstaltung_id_typ BIGINT,
    Veranstaltung_id_veranstalter BIGINT,
    Veranstaltung_Veranstalter_name VARCHAR(100),
    Veranstaltung_Veranstalter_organisationstyp VARCHAR(50),
    Veranstaltung_Veranstaltungstyp VARCHAR(50),
    Veranstaltung_id_veranstaltung BIGINT,
    Veranstaltung_id_veranstaltungsort BIGINT,
    Veranstaltung_termin_status VARCHAR(30),
    Veranstaltung_id_termin BIGINT,
    Veranstaltung_tickettyp VARCHAR(30),
    Veranstaltung_Ticket_status VARCHAR(20),
    Veranstaltung_id_ticket BIGINT,
    Veranstaltung_Veranstaltungsort_name VARCHAR(100),
    Veranstaltung_stadtteil VARCHAR(100),
    Veranstaltung_latitude DECIMAL(10,7),
    Veranstaltung_longitude DECIMAL(10,7),
    Veranstaltung_kapazitaet INT
);

CREATE TABLE core.DIM_Linie (
    Linie_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    src_cm_fahrt_id INT,
    src_cm_fahrplan_id INT,
    src_cm_fahrt_haltestelle_id INT,
    src_cm_fahrgastaufkommen_id INT,
    Linie_liniennummer VARCHAR(10),
    Linie_bezeichnung VARCHAR(100),
    Linie_verkehrsmittel VARCHAR(20),
    Linie_gueltig_ab DATE,
    Linie_gueltig_bis DATE,
    Linie_Fahrzeug_kapazitaet INT,
    Linie_id_linie INT,
    Linie_fahrzeug INT,
    Linie_Fahrt_datum DATE,
    Linie_fahrtrichtung VARCHAR(50),
    Linie_id_fahrt INT,
    Linie_id_haltestelle INT,
    Linie_Haltestelle_name VARCHAR(100),
    Linie_Haltestelle_stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);