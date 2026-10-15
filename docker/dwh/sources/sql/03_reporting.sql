CREATE SCHEMA reporting;

CREATE TABLE reporting.Wetter_und_Fahrradnutzung (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Fahrradstation_Startstation_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrradstation_Endstation_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrradstation_Startzeit TIMESTAMP,
    Fahrradstation_Endzeit TIMESTAMP,
    Fahrradstation_Status VARCHAR(20),

    Fahrradstation_Name VARCHAR(100),
    Fahrradstation_Stadtteil VARCHAR(100),
    Fahrradstation_Latitude DECIMAL(10,7),
    Fahrradstation_Longitude DECIMAL(10,7),
    Fahrradstation_Kapazitaet INT,

    Wetterstation_Name VARCHAR(100),
    Wetterstation_Stadtteil VARCHAR(100),
    Wetterstation_latitude DECIMAL(10,7),
    Wetterstation_longitude DECIMAL(10,7),
    Wetterstation_Typ VARCHAR(30),
    Wetterstation_Installationsdatum DATE,
    Wetterstation_Status VARCHAR(20),

    Wetterstation_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Wetterstation_Sensortyp VARCHAR(50),
    Wetterstation_Einheit VARCHAR(20),
    Wetterstation_Sensor_Installationsdatum DATE,
    Wetterstation_Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Wetterstation_Messzeitpunkt TIMESTAMP,
    Wetterstation_Messwert DECIMAL(10,2)
);

CREATE TABLE reporting.Veranstaltungen_und_OePNV (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Veranstaltung_Name VARCHAR(100),
    Veranstaltung_Beschreibung VARCHAR(255),
    Veranstaltung_Typ_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Veranstalter_key BIGINT GENERATED ALWAYS AS IDENTITY,

    Veranstaltung_Veranstalter_Name VARCHAR(100),
    Veranstaltung_Veranstalter_Organisationstyp VARCHAR(50),

    Veranstaltung_Veranstaltungstyp_Bezeichnung VARCHAR(50),

    Veranstaltung_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Ort_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Beginn_geplant TIMESTAMP,
    Veranstaltung_Ende_geplant TIMESTAMP,
    Veranstaltung_Beginn_tatsaechlich TIMESTAMP,
    Veranstaltung_Ende_tatsaechlich TIMESTAMP,
    Veranstaltung_Status VARCHAR(30),

    Veranstaltung_tickettyp VARCHAR(30),
    Veranstaltung_Ticket_status VARCHAR(20),
    Veranstaltung_Ticket_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Einlass_status VARCHAR(20),
    Veranstaltung_Einlass_Startzeit TIMESTAMP,
    Veranstaltung_Veranstaltungsort_Name VARCHAR(100),
    Veranstaltung_Stadtteil VARCHAR(100),
    Veranstaltung_latitude DECIMAL(10,7),
    Veranstaltung_longitude DECIMAL(10,7),
    Veranstaltung_Kapazitaet INT,

    Linie_Liniennummer VARCHAR(10),
    Linie_Bezeichnung VARCHAR(100),
    Linie_Verkehrsmittel VARCHAR(20),
    Linie_Gueltig_ab DATE,
    Linie_Gueltig_bis DATE,

    Linie_Kapazitaet INT,

    Linie_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrzeug_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrt_Datum DATE,
    Linie_Fahrtrichtung VARCHAR(50),
    Linie_Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Einsteiger INT,
    Linie_Aussteiger INT,
    Linie_Ankunft_geplant TIMESTAMP,
    Linier_Abfahrt_geplant TIMESTAMP,
    Linie_Ankunft_tatsaechlich TIMESTAMP,
    Linie_Abfahrt_tatsaechlich TIMESTAMP,

    Linie_Haltestelle_Name VARCHAR(100),
    Linie_Haltestelle_Stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);

CREATE TABLE reporting.Veranstaltungen_und_Fahrradnutzung (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Veranstaltung_Name VARCHAR(100),
    Veranstaltung_Beschreibung VARCHAR(255),
    Veranstaltung_Typ_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Veranstalter_key BIGINT GENERATED ALWAYS AS IDENTITY,

    Veranstaltung_Veranstalter_Name VARCHAR(100),
    Veranstaltung_Veranstalter_Organisationstyp VARCHAR(50),

    Veranstaltung_Veranstaltungstyp_Bezeichnung VARCHAR(50),

    Veranstaltung_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Ort_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Beginn_geplant TIMESTAMP,
    Veranstaltung_Ende_geplant TIMESTAMP,
    Veranstaltung_Beginn_tatsaechlich TIMESTAMP,
    Veranstaltung_Ende_tatsaechlich TIMESTAMP,
    Veranstaltung_Status VARCHAR(30),

    Veranstaltung_tickettyp VARCHAR(30),
    Veranstaltung_Ticket_status VARCHAR(20),
    Veranstaltung_Ticket_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Einlass_status VARCHAR(20),
    Veranstaltung_Einlass_Startzeit TIMESTAMP,
    Veranstaltung_Veranstaltungsort_Name VARCHAR(100),
    Veranstaltung_Stadtteil VARCHAR(100),
    Veranstaltung_latitude DECIMAL(10,7),
    Veranstaltung_longitude DECIMAL(10,7),
    Veranstaltung_Kapazitaet INT,
    
    Fahrradstation_Startstation_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrradstation_Endstation_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrradstation_Startzeit TIMESTAMP,
    Fahrradstation_Endzeit TIMESTAMP,
    Fahrradstation_Status VARCHAR(20),

    Fahrradstation_Name VARCHAR(100),
    Fahrradstation_Stadtteil VARCHAR(100),
    Fahrradstation_Latitude DECIMAL(10,7),
    Fahrradstation_Longitude DECIMAL(10,7),
    Fahrradstation_Kapazitaet INT
);

CREATE TABLE reporting.Wetter_und_OePNV (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Linie_Liniennummer VARCHAR(10),
    Linie_Bezeichnung VARCHAR(100),
    Linie_Verkehrsmittel VARCHAR(20),
    Linie_Gueltig_ab DATE,
    Linie_Gueltig_bis DATE,

    Linie_Kapazitaet INT,

    Linie_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrzeug_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrt_Datum DATE,
    Linie_Fahrtrichtung VARCHAR(50),
    Linie_Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Einsteiger INT,
    Linie_Aussteiger INT,
    Linie_Ankunft_geplant TIMESTAMP,
    Linier_Abfahrt_geplant TIMESTAMP,
    Linie_Ankunft_tatsaechlich TIMESTAMP,
    Linie_Abfahrt_tatsaechlich TIMESTAMP,

    Linie_Haltestelle_Name VARCHAR(100),
    Linie_Haltestelle_Stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7),

    Wetterstation_Name VARCHAR(100),
    Wetterstation_Stadtteil VARCHAR(100),
    Wetterstation_latitude DECIMAL(10,7),
    Wetterstation_longitude DECIMAL(10,7),
    Wetterstation_Typ VARCHAR(30),
    Wetterstation_Installationsdatum DATE,
    Wetterstation_Status VARCHAR(20),

    Wetterstation_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Wetterstation_Sensortyp VARCHAR(50),
    Wetterstation_Einheit VARCHAR(20),
    Wetterstation_Sensor_Installationsdatum DATE,
    Wetterstation_Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Wetterstation_Messzeitpunkt TIMESTAMP,
    Wetterstation_Messwert DECIMAL(10,2)
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Fahrradstation_Startstation_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrradstation_Endstation_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrradstation_Startzeit TIMESTAMP,
    Fahrradstation_Endzeit TIMESTAMP,
    Fahrradstation_Status VARCHAR(20),

    Fahrradstation_Name VARCHAR(100),
    Fahrradstation_Stadtteil VARCHAR(100),
    Fahrradstation_Latitude DECIMAL(10,7),
    Fahrradstation_Longitude DECIMAL(10,7),
    Fahrradstation_Kapazitaet INT,

    Wetterstation_Name VARCHAR(100),
    Wetterstation_Stadtteil VARCHAR(100),
    Wetterstation_latitude DECIMAL(10,7),
    Wetterstation_longitude DECIMAL(10,7),
    Wetterstation_Typ VARCHAR(30),
    Wetterstation_Installationsdatum DATE,
    Wetterstation_Status VARCHAR(20),

    Wetterstation_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Wetterstation_Sensortyp VARCHAR(50),
    Wetterstation_Einheit VARCHAR(20),
    Wetterstation_Sensor_Installationsdatum DATE,
    Wetterstation_Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Wetterstation_Messzeitpunkt TIMESTAMP,
    Wetterstation_Messwert DECIMAL(10,2),

    Linie_Liniennummer VARCHAR(10),
    Linie_Bezeichnung VARCHAR(100),
    Linie_Verkehrsmittel VARCHAR(20),
    Linie_Gueltig_ab DATE,
    Linie_Gueltig_bis DATE,

    Linie_Kapazitaet INT,

    Linie_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrzeug_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrt_Datum DATE,
    Linie_Fahrtrichtung VARCHAR(50),
    Linie_Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Einsteiger INT,
    Linie_Aussteiger INT,
    Linie_Ankunft_geplant TIMESTAMP,
    Linier_Abfahrt_geplant TIMESTAMP,
    Linie_Ankunft_tatsaechlich TIMESTAMP,
    Linie_Abfahrt_tatsaechlich TIMESTAMP,

    Linie_Haltestelle_Name VARCHAR(100),
    Linie_Haltestelle_Stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);

CREATE TABLE reporting.Wetter_und_Fahrradnutzung_Fahradstation (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrt_startzeit TIMESTAMP,
    Fahrt_endzeit TIMESTAMP,
    Fahrt_status VARCHAR(20),
    Fahrt_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrt_Station_Startstation_name VARCHAR(100),
    Fahrt_Station_Startstation_stadtteil VARCHAR(100),
    Fahrt_Station_Startstation_latitude DECIMAL(10,7),
    Fahrt_Station_Startstation_longitude DECIMAL(10,7),
    Fahrt_Station_Startstation_kapazitaet INT,
    Fahrt_Station_Endstation_name VARCHAR(100),
    Fahrt_Station_Endstation_stadtteil VARCHAR(100),
    Fahrt_Station_Endstation_latitude DECIMAL(10,7),
    Fahrt_Station_Endstation_longitude DECIMAL(10,7),
    Fahrt_Station_Endstation_kapazitaet INT
);

CREATE TABLE reporting.Wetter_und_Fahrradnutzung_Sensor (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Sensor_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_name VARCHAR(100),
    Sensor_stadtteil VARCHAR(100),
    Sensor_latitude DECIMAL(10,7),
    Sensor_longitude DECIMAL(10,7),
    Sensor_stations_typ VARCHAR(30),
    Sensor_station_installationsdatum DATE,
    Sensor_status VARCHAR(20),
    Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_sensortyp VARCHAR(50),
    Sensor_einheit VARCHAR(20),
    Sensor_installationsdatum DATE,
    Sensor_Messung_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_messzeitpunkt TIMESTAMP,
    Sensor_Messwert DECIMAL(10,2)
);

CREATE TABLE reporting.Wetter_und_Fahrradnutzung_Datum (
    Datum_Key BIGINT PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Stunde    SMALLINT,
    Datum     DATE,
    Monat     SMALLINT,
    Quartal   SMALLINT,
    Jahr      SMALLINT
);

CREATE TABLE reporting.Veranstaltungen_und_OePNV_Versanstaltung (
    Veranstaltung_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Veranstaltung_name VARCHAR(100),
    Veranstaltung_beschreibung VARCHAR(255),
    Veranstaltung_Veranstalter_name VARCHAR(100),
    Veranstaltung_Veranstalter_organisationstyp VARCHAR(50),
    Veranstaltung_typ_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Veranstaltungstyp VARCHAR(50),
    Veranstaltung_termin_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_beginn_geplant TIMESTAMP,
    Veranstaltung_ende_geplant TIMESTAMP,
    Veranstaltung_beginn_tatsaechlich TIMESTAMP,
    Veranstaltung_ende_tatsaechlich TIMESTAMP,
    Veranstaltung_termin_status VARCHAR(30),
    Veranstaltung_Ticket_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_tickettyp VARCHAR(30),
    Veranstaltung_Ticket_status VARCHAR(20),
    Veranstaltung_Einlass_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_einlass_status VARCHAR(20),
    Veranstaltung_einlass_zeitpunkt TIMESTAMP,
    Veranstaltung_Veranstaltungsort_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Veranstaltungsort_name VARCHAR(100),
    Veranstaltung_stadtteil VARCHAR(100),
    Veranstaltung_latitude DECIMAL(10,7),
    Veranstaltung_longitude DECIMAL(10,7),
    Veranstaltung_kapazitaet INT
);

CREATE TABLE reporting.Veranstaltungen_und_OePNV_Linie (
    Linie_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Linie_liniennummer VARCHAR(10),
    Linie_bezeichnung VARCHAR(100),
    Linie_verkehrsmittel VARCHAR(20),
    Linie_gueltig_ab DATE,
    Linie_gueltig_bis DATE,
    Linie_Fahrzeug_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrzeug_kapazitaet INT,
    Linie_Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_fahrzeug INT,
    Linie_Fahrt_datum DATE,
    Linie_fahrtrichtung VARCHAR(50),
    Linie_Fahrgastaufkommen_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_einsteiger INT,
    Linie_aussteiger INT,
    Linie_Fahrplan_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_ankunft_geplant TIMESTAMP,
    Linie_abfahrt_geplant TIMESTAMP,
    Linie_Fahrt_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_ankunft_tatsaechlich TIMESTAMP,
    Linie_abfahrt_tatsaechlich TIMESTAMP,
    Linie_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Haltestelle_name VARCHAR(100),
    Linie_Haltestelle_stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);

CREATE TABLE reporting.Veranstaltungen_und_OePNV_Datum (
    Datum_Key BIGINT PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Stunde    SMALLINT,
    Datum     DATE,
    Monat     SMALLINT,
    Quartal   SMALLINT,
    Jahr      SMALLINT
);

CREATE TABLE reporting.Veranstaltungen_und_Fahrradnutzung_Versanstaltung (
    Veranstaltung_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Veranstaltung_name VARCHAR(100),
    Veranstaltung_beschreibung VARCHAR(255),
    Veranstaltung_Veranstalter_name VARCHAR(100),
    Veranstaltung_Veranstalter_organisationstyp VARCHAR(50),
    Veranstaltung_typ_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Veranstaltungstyp VARCHAR(50),
    Veranstaltung_termin_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_beginn_geplant TIMESTAMP,
    Veranstaltung_ende_geplant TIMESTAMP,
    Veranstaltung_beginn_tatsaechlich TIMESTAMP,
    Veranstaltung_ende_tatsaechlich TIMESTAMP,
    Veranstaltung_termin_status VARCHAR(30),
    Veranstaltung_Ticket_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_tickettyp VARCHAR(30),
    Veranstaltung_Ticket_status VARCHAR(20),
    Veranstaltung_Einlass_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_einlass_status VARCHAR(20),
    Veranstaltung_einlass_zeitpunkt TIMESTAMP,
    Veranstaltung_Veranstaltungsort_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Veranstaltung_Veranstaltungsort_name VARCHAR(100),
    Veranstaltung_stadtteil VARCHAR(100),
    Veranstaltung_latitude DECIMAL(10,7),
    Veranstaltung_longitude DECIMAL(10,7),
    Veranstaltung_kapazitaet INT
);

CREATE TABLE reporting.Veranstaltungen_und_Fahrradnutzung_Fahradstation (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrt_startzeit TIMESTAMP,
    Fahrt_endzeit TIMESTAMP,
    Fahrt_status VARCHAR(20),
    Fahrt_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrt_Station_Startstation_name VARCHAR(100),
    Fahrt_Station_Startstation_stadtteil VARCHAR(100),
    Fahrt_Station_Startstation_latitude DECIMAL(10,7),
    Fahrt_Station_Startstation_longitude DECIMAL(10,7),
    Fahrt_Station_Startstation_kapazitaet INT,
    Fahrt_Station_Endstation_name VARCHAR(100),
    Fahrt_Station_Endstation_stadtteil VARCHAR(100),
    Fahrt_Station_Endstation_latitude DECIMAL(10,7),
    Fahrt_Station_Endstation_longitude DECIMAL(10,7),
    Fahrt_Station_Endstation_kapazitaet INT
);

CREATE TABLE reporting.Veranstaltungen_und_Fahrradnutzung_Datum (
    Datum_Key BIGINT PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Stunde    SMALLINT,
    Datum     DATE,
    Monat     SMALLINT,
    Quartal   SMALLINT,
    Jahr      SMALLINT
);

CREATE TABLE reporting.Wetter_und_OePNV_Linie (
    Linie_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Linie_liniennummer VARCHAR(10),
    Linie_bezeichnung VARCHAR(100),
    Linie_verkehrsmittel VARCHAR(20),
    Linie_gueltig_ab DATE,
    Linie_gueltig_bis DATE,
    Linie_Fahrzeug_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrzeug_kapazitaet INT,
    Linie_Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_fahrzeug INT,
    Linie_Fahrt_datum DATE,
    Linie_fahrtrichtung VARCHAR(50),
    Linie_Fahrgastaufkommen_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_einsteiger INT,
    Linie_aussteiger INT,
    Linie_Fahrplan_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_ankunft_geplant TIMESTAMP,
    Linie_abfahrt_geplant TIMESTAMP,
    Linie_Fahrt_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_ankunft_tatsaechlich TIMESTAMP,
    Linie_abfahrt_tatsaechlich TIMESTAMP,
    Linie_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Haltestelle_name VARCHAR(100),
    Linie_Haltestelle_stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);

CREATE TABLE reporting.Wetter_und_OePNV_Sensor (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Sensor_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_name VARCHAR(100),
    Sensor_stadtteil VARCHAR(100),
    Sensor_latitude DECIMAL(10,7),
    Sensor_longitude DECIMAL(10,7),
    Sensor_stations_typ VARCHAR(30),
    Sensor_station_installationsdatum DATE,
    Sensor_status VARCHAR(20),
    Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_sensortyp VARCHAR(50),
    Sensor_einheit VARCHAR(20),
    Sensor_installationsdatum DATE,
    Sensor_Messung_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_messzeitpunkt TIMESTAMP,
    Sensor_Messwert DECIMAL(10,2)
);

CREATE TABLE reporting.Wetter_und_OePNV_Datum (
    Datum_Key BIGINT PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Stunde    SMALLINT,
    Datum     DATE,
    Monat     SMALLINT,
    Quartal   SMALLINT,
    Jahr      SMALLINT
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Fahradstation (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrt_startzeit TIMESTAMP,
    Fahrt_endzeit TIMESTAMP,
    Fahrt_status VARCHAR(20),
    Fahrt_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Fahrt_Station_Startstation_name VARCHAR(100),
    Fahrt_Station_Startstation_stadtteil VARCHAR(100),
    Fahrt_Station_Startstation_latitude DECIMAL(10,7),
    Fahrt_Station_Startstation_longitude DECIMAL(10,7),
    Fahrt_Station_Startstation_kapazitaet INT,
    Fahrt_Station_Endstation_name VARCHAR(100),
    Fahrt_Station_Endstation_stadtteil VARCHAR(100),
    Fahrt_Station_Endstation_latitude DECIMAL(10,7),
    Fahrt_Station_Endstation_longitude DECIMAL(10,7),
    Fahrt_Station_Endstation_kapazitaet INT
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Linie (
    Linie_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Linie_liniennummer VARCHAR(10),
    Linie_bezeichnung VARCHAR(100),
    Linie_verkehrsmittel VARCHAR(20),
    Linie_gueltig_ab DATE,
    Linie_gueltig_bis DATE,
    Linie_Fahrzeug_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Fahrzeug_kapazitaet INT,
    Linie_Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_fahrzeug INT,
    Linie_Fahrt_datum DATE,
    Linie_fahrtrichtung VARCHAR(50),
    Linie_Fahrgastaufkommen_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_einsteiger INT,
    Linie_aussteiger INT,
    Linie_Fahrplan_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_ankunft_geplant TIMESTAMP,
    Linie_abfahrt_geplant TIMESTAMP,
    Linie_Fahrt_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_ankunft_tatsaechlich TIMESTAMP,
    Linie_abfahrt_tatsaechlich TIMESTAMP,
    Linie_Haltestelle_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Linie_Haltestelle_name VARCHAR(100),
    Linie_Haltestelle_stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Sensor (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Sensor_Station_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_name VARCHAR(100),
    Sensor_stadtteil VARCHAR(100),
    Sensor_latitude DECIMAL(10,7),
    Sensor_longitude DECIMAL(10,7),
    Sensor_stations_typ VARCHAR(30),
    Sensor_station_installationsdatum DATE,
    Sensor_status VARCHAR(20),
    Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_sensortyp VARCHAR(50),
    Sensor_einheit VARCHAR(20),
    Sensor_installationsdatum DATE,
    Sensor_Messung_key BIGINT GENERATED ALWAYS AS IDENTITY,
    Sensor_messzeitpunkt TIMESTAMP,
    Sensor_Messwert DECIMAL(10,2)
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Datum (
    Datum_Key BIGINT PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Stunde    SMALLINT,
    Datum     DATE,
    Monat     SMALLINT,
    Quartal   SMALLINT,
    Jahr      SMALLINT
);
