CREATE SCHEMA reporting;

-- Dimensionen 

CREATE TABLE reporting.Wetter_und_Fahrradnutzung_Fahradstation (
    Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
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

CREATE TABLE reporting.Wetter_und_Fahrradnutzung_Sensor (
    Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Sensor_name VARCHAR(100),
    Sensor_stadtteil VARCHAR(100),
    Sensor_latitude DECIMAL(10,7),
    Sensor_longitude DECIMAL(10,7),
    Sensor_stations_typ VARCHAR(30),
    Sensor_station_installationsdatum DATE,
    Sensor_status VARCHAR(20),
    Sensor_sensortyp VARCHAR(50),
    Sensor_installationsdatum DATE,
    Sensor_messzeitpunkt TIMESTAMP
);

CREATE TABLE reporting.Wetter_und_Fahrradnutzung_Datum (
    Datum_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
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
    Veranstaltung_Veranstaltungstyp VARCHAR(50),
    Veranstaltung_termin_status VARCHAR(30),
    Veranstaltung_tickettyp VARCHAR(30),
    Veranstaltung_Ticket_status VARCHAR(20),
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
    Linie_Fahrzeug_kapazitaet INT,
    Linie_fahrzeug INT,
    Linie_Fahrt_datum DATE,
    Linie_fahrtrichtung VARCHAR(50),
    Linie_Haltestelle_name VARCHAR(100),
    Linie_Haltestelle_stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);

CREATE TABLE reporting.Veranstaltungen_und_OePNV_Datum (
    Datum_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
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
    Veranstaltung_Veranstaltungstyp VARCHAR(50),
    Veranstaltung_termin_status VARCHAR(30),
    Veranstaltung_tickettyp VARCHAR(30),
    Veranstaltung_Ticket_status VARCHAR(20),
    Veranstaltung_Veranstaltungsort_name VARCHAR(100),
    Veranstaltung_stadtteil VARCHAR(100),
    Veranstaltung_latitude DECIMAL(10,7),
    Veranstaltung_longitude DECIMAL(10,7),
    Veranstaltung_kapazitaet INT
);

CREATE TABLE reporting.Veranstaltungen_und_Fahrradnutzung_Fahradstation (
    Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
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

CREATE TABLE reporting.Veranstaltungen_und_Fahrradnutzung_Datum (
    Datum_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
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
    Linie_Fahrzeug_kapazitaet INT,
    Linie_fahrzeug INT,
    Linie_Fahrt_datum DATE,
    Linie_fahrtrichtung VARCHAR(50),
    Linie_Haltestelle_name VARCHAR(100),
    Linie_Haltestelle_stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);

CREATE TABLE reporting.Wetter_und_OePNV_Sensor (
    Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Sensor_name VARCHAR(100),
    Sensor_stadtteil VARCHAR(100),
    Sensor_latitude DECIMAL(10,7),
    Sensor_longitude DECIMAL(10,7),
    Sensor_stations_typ VARCHAR(30),
    Sensor_station_installationsdatum DATE,
    Sensor_status VARCHAR(20),
    Sensor_sensortyp VARCHAR(50),
    Sensor_installationsdatum DATE,
    Sensor_messzeitpunkt TIMESTAMP
);

CREATE TABLE reporting.Wetter_und_OePNV_Datum (
    Datum_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Stunde    SMALLINT,
    Datum     DATE,
    Monat     SMALLINT,
    Quartal   SMALLINT,
    Jahr      SMALLINT
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Fahradstation (
    Fahrt_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
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

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Linie (
    Linie_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Linie_liniennummer VARCHAR(10),
    Linie_bezeichnung VARCHAR(100),
    Linie_verkehrsmittel VARCHAR(20),
    Linie_gueltig_ab DATE,
    Linie_gueltig_bis DATE,
    Linie_Fahrzeug_kapazitaet INT,
    Linie_fahrzeug INT,
    Linie_Fahrt_datum DATE,
    Linie_fahrtrichtung VARCHAR(50),
    Linie_Haltestelle_name VARCHAR(100),
    Linie_Haltestelle_stadtteil VARCHAR(100),
    Linie_Haltestelle_latitude DECIMAL(10,7),
    Linie_Haltestelle_longitude DECIMAL(10,7)
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Sensor (
    Sensor_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Sensor_name VARCHAR(100),
    Sensor_stadtteil VARCHAR(100),
    Sensor_latitude DECIMAL(10,7),
    Sensor_longitude DECIMAL(10,7),
    Sensor_stations_typ VARCHAR(30),
    Sensor_station_installationsdatum DATE,
    Sensor_status VARCHAR(20),
    Sensor_sensortyp VARCHAR(50),
    Sensor_installationsdatum DATE,
    Sensor_messzeitpunkt TIMESTAMP
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Datum (
    Datum_Key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Stunde    SMALLINT,
    Datum     DATE,
    Monat     SMALLINT,
    Quartal   SMALLINT,
    Jahr      SMALLINT
);

-- Fakten
CREATE TABLE reporting.Wetter_und_Fahrradnutzung (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Fahrt_key BIGINT REFERENCES reporting.Wetter_und_Fahrradnutzung_Fahradstation(Fahrt_key),
    Fahrradstation_Startzeit TIMESTAMP,
    Fahrradstation_Endzeit TIMESTAMP,
    Fahrradstation_Startstation_Name VARCHAR(100),
    Fahrradstation_Endstation_Name VARCHAR(100),
    Sensor_key BIGINT REFERENCES reporting.Wetter_und_Fahrradnutzung_Sensor(Sensor_key),
    Wetterstation_Einheit VARCHAR(20),
    Wetterstation_Messwert DECIMAL(10,2),
    Datum_Key BIGINT REFERENCES reporting.Wetter_und_Fahrradnutzung_Datum(Datum_Key)
);

CREATE TABLE reporting.Veranstaltungen_und_OePNV (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Veranstaltung_key BIGINT REFERENCES reporting.Veranstaltungen_und_OePNV_Versanstaltung(Veranstaltung_Key),
    Veranstaltung_Beginn_geplant TIMESTAMP,
    Veranstaltung_Ende_geplant TIMESTAMP,
    Veranstaltung_Beginn_tatsaechlich TIMESTAMP,
    Veranstaltung_Ende_tatsaechlich TIMESTAMP,
    Veranstaltung_Einlass_status VARCHAR(20),
    Veranstaltung_Einlass_Startzeit TIMESTAMP,

    Linie_key BIGINT REFERENCES reporting.Veranstaltungen_und_OePNV_Linie(Linie_Key),
    Linie_Einsteiger INT,
    Linie_Aussteiger INT,
    Linie_Ankunft_geplant TIMESTAMP,
    Linier_Abfahrt_geplant TIMESTAMP,
    Linie_Ankunft_tatsaechlich TIMESTAMP,
    Linie_Abfahrt_tatsaechlich TIMESTAMP,
    Linie_Haltestelle_Name VARCHAR(100),
    Datum_Key BIGINT REFERENCES reporting.Veranstaltungen_und_OePNV_Datum(Datum_Key)
);

CREATE TABLE reporting.Veranstaltungen_und_Fahrradnutzung (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Veranstaltung_key BIGINT REFERENCES reporting.Veranstaltungen_und_Fahrradnutzung_Versanstaltung(Veranstaltung_Key),
    Veranstaltung_Beginn_geplant TIMESTAMP,
    Veranstaltung_Ende_geplant TIMESTAMP,
    Veranstaltung_Beginn_tatsaechlich TIMESTAMP,
    Veranstaltung_Ende_tatsaechlich TIMESTAMP,
    Veranstaltung_Einlass_status VARCHAR(20),
    Veranstaltung_Einlass_Startzeit TIMESTAMP,
    
    Fahrt_key BIGINT REFERENCES reporting.Veranstaltungen_und_Fahrradnutzung_Fahradstation(Fahrt_key),
    Fahrradstation_Startzeit TIMESTAMP,
    Fahrradstation_Endzeit TIMESTAMP,
    Fahrradstation_Startstation_Name VARCHAR(100),
    Fahrradstation_Endstation_Name VARCHAR(100),
    Datum_Key BIGINT REFERENCES reporting.Veranstaltungen_und_Fahrradnutzung_Datum(Datum_Key)
);

CREATE TABLE reporting.Wetter_und_OePNV (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Linie_key BIGINT REFERENCES reporting.Wetter_und_OePNV_Linie(Linie_Key),
    Linie_Einsteiger INT,
    Linie_Aussteiger INT,
    Linie_Ankunft_geplant TIMESTAMP,
    Linier_Abfahrt_geplant TIMESTAMP,
    Linie_Ankunft_tatsaechlich TIMESTAMP,
    Linie_Abfahrt_tatsaechlich TIMESTAMP,
    Linie_Haltestelle_Name VARCHAR(100),

    Sensor_key BIGINT REFERENCES reporting.Wetter_und_OePNV_Sensor(Sensor_key),
    Wetterstation_Einheit VARCHAR(20),
    Wetterstation_Messwert DECIMAL(10,2),
    Datum_Key BIGINT REFERENCES reporting.Wetter_und_OePNV_Datum(Datum_Key)
);

CREATE TABLE reporting.Luftqualitaet_und_Mobilitaetsaufkommen (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    core_id BIGINT NOT NULL UNIQUE,
    Fahrt_key BIGINT REFERENCES reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Fahradstation(Fahrt_key),
    Fahrradstation_Startzeit TIMESTAMP,
    Fahrradstation_Endzeit TIMESTAMP,
    Fahrradstation_Startstation_Name VARCHAR(100),
    Fahrradstation_Endstation_Name VARCHAR(100),
    Sensor_key BIGINT REFERENCES reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Sensor(Sensor_key),
    Wetterstation_Einheit VARCHAR(20),
    Wetterstation_Messwert DECIMAL(10,2),

    Linie_key BIGINT REFERENCES reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Linie(Linie_Key),
    Linie_Einsteiger INT,
    Linie_Aussteiger INT,
    Linie_Ankunft_geplant TIMESTAMP,
    Linier_Abfahrt_geplant TIMESTAMP,
    Linie_Ankunft_tatsaechlich TIMESTAMP,
    Linie_Abfahrt_tatsaechlich TIMESTAMP,
    Linie_Haltestelle_Name VARCHAR(100),
    Datum_Key BIGINT REFERENCES reporting.Luftqualitaet_und_Mobilitaetsaufkommen_Datum(Datum_Key)
);