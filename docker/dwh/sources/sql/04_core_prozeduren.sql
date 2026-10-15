CREATE OR REPLACE PROCEDURE core.transfer_dim_fahrradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO core.DIM_Fahrradstation (
        src_bs_fahrt_id,
        Fahrt_id_startstation,
        Fahrt_id_endstation,
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
        f.id,
        f.id_startstation,
        f.id_zielstation,
        f.startzeit,
        f.endzeit,
        f.status,
        s1.name,
        s1.stadtteil,
        s1.latitude,
        s1.longitude,
        s1.kapazitaet,
        s2.name,
        s2.stadtteil,
        s2.latitude,
        s2.longitude,
        s2.kapazitaet
    FROM staging.bs_fahrt f
    LEFT JOIN staging.bs_station s1
        ON s1.id = f.id_startstation
    LEFT JOIN staging.bs_station s2
        ON s2.id = f.id_zielstation
    WHERE NOT EXISTS (
        SELECT 1
        FROM core.dim_fahrradstation d
        WHERE d.src_bs_fahrt_id = f.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE core.transfer_dim_wettersensor()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO core.DIM_Wettersensor (
        src_as_messung_id,
        Sensor_name,
        Sensor_stadtteil,
        Sensor_latitude,
        Sensor_longitude,
        Sensor_stations_typ,
        Sensor_station_installationsdatum,
        Sensor_status,
        Sensor_id_station,
        Sensor_sensortyp,
        Sensor_einheit,
        Sensor_installationsdatum,
        Sensor_id_sensor,
        Sensor_messzeitpunkt,
        Sensor_Messwert
    )
    SELECT
        m.id,
        st.name,
        st.stadtteil,
        st.latitude,
        st.longitude,
        st.stations_typ,
        st.installationsdatum,
        st.status,
        s.id_station,
        s.sensortyp,
        s.einheit,
        s.installationsdatum,
        s.id,
        m.messzeitpunkt,
        m.messwert
    FROM staging.as_messung m
    JOIN staging.as_sensor s
        ON s.id = m.id_sensor
    JOIN staging.as_station st
        ON st.id = s.id_station
    WHERE NOT EXISTS (
        SELECT 1
        FROM core.dim_wettersensor d
        WHERE d.src_as_messung_id = m.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE core.transfer_dim_veranstaltung()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO core.DIM_Veranstaltung (
        src_ce_veranstaltung_id,
        src_ce_termin_id,
        src_ce_ticket_id,
        src_ce_einlass_id,
        Veranstaltung_name,
        Veranstaltung_beschreibung,
        Veranstaltung_id_typ,
        Veranstaltung_id_veranstalter,
        Veranstaltung_Veranstalter_name,
        Veranstaltung_Veranstalter_organisationstyp,
        Veranstaltung_Veranstaltungstyp,
        Veranstaltung_id_veranstaltung,
        Veranstaltung_id_veranstaltungsort,
        Veranstaltung_beginn_geplant,
        Veranstaltung_ende_geplant,
        Veranstaltung_beginn_tatsaechlich,
        Veranstaltung_ende_tatsaechlich,
        Veranstaltung_termin_status,
        Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status,
        Veranstaltung_id_ticket,
        Veranstaltung_einlass_status,
        Veranstaltung_einlass_zeitpunkt,
        Veranstaltung_Veranstaltungsort_name,
        Veranstaltung_stadtteil,
        Veranstaltung_latitude,
        Veranstaltung_longitude,
        Veranstaltung_kapazitaet
    )
    SELECT
        v.id,
        t.id,
        ti.id,
        e.id,
        v.name,
        v.beschreibung,
        v.id_typ,
        v.id_veranstalter,
        va.name,
        va.organisationstyp,
        vt.bezeichnung,
        t.id_veranstaltung,
        t.id_veranstaltungsort,
        t.beginn_geplant,
        t.ende_geplant,
        t.beginn_tatsaechlich,
        t.ende_tatsaechlich,
        t.status,
        ti.tickettyp,
        ti.status,
        e.id_ticket,
        e.einlass_status,
        e.einlasszeitpunkt,
        o.name,
        o.stadtteil,
        o.latitude,
        o.longitude,
        o.kapazitaet
    FROM staging.ce_veranstaltung v
    LEFT JOIN staging.ce_veranstaltungstyp vt
        ON vt.id = v.id_typ
    LEFT JOIN staging.ce_veranstalter va
        ON va.id = v.id_veranstalter
    LEFT JOIN staging.ce_veranstaltungstermin t
        ON t.id_veranstaltung = v.id
    LEFT JOIN staging.ce_veranstaltungsort o
        ON o.id = t.id_veranstaltungsort
    LEFT JOIN staging.ce_ticket ti
        ON ti.id_termin = t.id
    LEFT JOIN staging.ce_einlass e
        ON e.id_ticket = ti.id
    WHERE NOT EXISTS (
        SELECT 1
        FROM core.dim_veranstaltung d
        WHERE d.src_ce_veranstaltung_id
                  IS NOT DISTINCT FROM v.id
          AND d.src_ce_termin_id
                  IS NOT DISTINCT FROM t.id
          AND d.src_ce_ticket_id
                  IS NOT DISTINCT FROM ti.id
          AND d.src_ce_einlass_id
                  IS NOT DISTINCT FROM e.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE core.transfer_dim_linie()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO core.DIM_Linie (
        src_cm_fahrt_id,
        src_cm_fahrplan_id,
        src_cm_fahrt_haltestelle_id,
        src_cm_fahrgastaufkommen_id,
        Linie_liniennummer,
        Linie_bezeichnung,
        Linie_verkehrsmittel,
        Linie_gueltig_ab,
        Linie_gueltig_bis,
        Linie_Fahrzeug_kapazitaet,
        Linie_id_linie,
        Linie_fahrzeug,
        Linie_Fahrt_datum,
        Linie_fahrtrichtung,
        Linie_id_fahrt,
        Linie_id_haltestelle,
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
        f.id,
        fp.id,
        fh.id,
        fg.id,
        l.liniennummer,
        l.bezeichnung,
        l.verkehrsmittel,
        l.gueltig_ab,
        l.gueltig_bis,
        fzg.kapazitaet,
        f.id_linie,
        f.id_fahrzeug,
        f.datum,
        f.fahrtrichtung,
        fh.id_fahrt,
        fh.id_haltestelle,
        fg.einsteiger,
        fg.aussteiger,
        fp.ankunft_geplant,
        fp.abfahrt_geplant,
        fh.ankunft_tatsaechlich,
        fh.abfahrt_tatsaechlich,
        h.name,
        h.stadtteil,
        h.latitude,
        h.longitude
    FROM staging.cm_fahrt_haltestelle fh
    JOIN staging.cm_fahrt f
        ON f.id = fh.id_fahrt
    JOIN staging.cm_linie l
        ON l.id = f.id_linie
    LEFT JOIN staging.cm_fahrzeug fzg
        ON fzg.id = f.id_fahrzeug
    LEFT JOIN staging.cm_fahrplan fp
        ON fp.id_fahrt = fh.id_fahrt
       AND fp.id_haltestelle = fh.id_haltestelle
    LEFT JOIN staging.cm_fahrgastaufkommen fg
        ON fg.id_fahrt = fh.id_fahrt
       AND fg.id_haltestelle = fh.id_haltestelle
    LEFT JOIN staging.cm_haltestelle h
        ON h.id = fh.id_haltestelle
    WHERE NOT EXISTS (
        SELECT 1
        FROM core.dim_linie d
        WHERE d.src_cm_fahrt_haltestelle_id
                  IS NOT DISTINCT FROM fh.id
          AND d.src_cm_fahrplan_id
                  IS NOT DISTINCT FROM fp.id
          AND d.src_cm_fahrgastaufkommen_id
                  IS NOT DISTINCT FROM fg.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE core.transfer_topic_wetter_und_fahrradnutzung(
    p_zeitfenster_minuten INTEGER DEFAULT 60
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_zeitfenster_minuten < 0 THEN
        RAISE EXCEPTION 'Das Zeitfenster darf nicht negativ sein.';
    END IF;

    INSERT INTO core.topic_wetter_und_fahrradnutzung (
        src_bs_fahrt_id,
        src_as_messung_id,

        bs_fahrt_id_startstation,
        bs_fahrt_id_endstation,
        bs_fahrt_startzeit,
        bs_fahrt_endzeit,
        bs_fahrt_status,

        bs_station_1_name,
        bs_station_1_stadtteil,
        bs_station_1_latitude,
        bs_station_1_longitude,
        bs_station_1_kapazitaet,

        bs_station_2_name,
        bs_station_2_stadtteil,
        bs_station_2_latitude,
        bs_station_2_longitude,
        bs_station_2_kapazitaet,

        as_station_name,
        as_station_stadtteil,
        as_station_latitude,
        as_station_longitude,
        as_station_stations_typ,
        as_station_installationsdatum,
        as_station_status,

        as_sensor_id_station,
        as_sensor_sensortyp,
        as_sensor_einheit,
        as_sensor_installationsdatum,
        as_sensor_id_sensor,

        as_messung_messzeitpunkt,
        as_messung_messwert
    )
    SELECT
        bf.id,
        m.id,

        bf.id_startstation,
        bf.id_zielstation,
        bf.startzeit,
        bf.endzeit,
        bf.status,

        bs1.name,
        bs1.stadtteil,
        bs1.latitude,
        bs1.longitude,
        bs1.kapazitaet,

        bs2.name,
        bs2.stadtteil,
        bs2.latitude,
        bs2.longitude,
        bs2.kapazitaet,

        ast.name,
        ast.stadtteil,
        ast.latitude,
        ast.longitude,
        ast.stations_typ,
        ast.installationsdatum,
        ast.status,

        s.id_station,
        s.sensortyp,
        s.einheit,
        s.installationsdatum,
        s.id,

        m.messzeitpunkt,
        m.messwert

    FROM staging.as_messung m
    JOIN staging.as_sensor s
        ON s.id = m.id_sensor
    JOIN staging.as_station ast
        ON ast.id = s.id_station

    LEFT JOIN staging.bs_fahrt bf
        ON m.messzeitpunkt BETWEEN
            bf.startzeit
                - p_zeitfenster_minuten * INTERVAL '1 minute'
            AND
            bf.endzeit
                + p_zeitfenster_minuten * INTERVAL '1 minute'

    LEFT JOIN staging.bs_station bs1
        ON bs1.id = bf.id_startstation
    LEFT JOIN staging.bs_station bs2
        ON bs2.id = bf.id_zielstation

    WHERE NOT EXISTS (
        SELECT 1
        FROM core.topic_wetter_und_fahrradnutzung tgt
        WHERE tgt.src_as_messung_id = m.id
          AND tgt.src_bs_fahrt_id IS NOT DISTINCT FROM bf.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE core.transfer_topic_wetter_und_oepnv(
    p_zeitfenster_minuten INTEGER DEFAULT 60
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_zeitfenster_minuten < 0 THEN
        RAISE EXCEPTION 'Das Zeitfenster darf nicht negativ sein.';
    END IF;

    INSERT INTO core.topic_wetter_und_oepnv (
        src_as_messung_id,
        src_cm_fahrt_haltestelle_id,
        src_cm_fahrplan_id,
        src_cm_fahrgastaufkommen_id,

        cm_linie_liniennummer,
        cm_linie_bezeichnung,
        cm_linie_verkehrsmittel,
        cm_linie_gueltig_ab,
        cm_linie_gueltig_bis,

        cm_fahrzeug_kapazitaet,

        cm_fahrt_id_linie,
        cm_fahrt_fahrzeug,
        cm_fahrt_datum,
        cm_fahrt_fahrtrichtung,

        cm_fahrgastaufkommen_id_fahrt,
        cm_fahrgastaufkommen_id_haltestelle,
        cm_fahrgastaufkommen_einsteiger,
        cm_fahrgastaufkommen_aussteiger,

        cm_fahrplan_id_fahrt,
        cm_fahrplan_id_haltestelle,
        cm_fahrplan_ankunft_geplant,
        cm_fahrplan_abfahrt_geplant,

        cm_fahrt_haltestelle_id_fahrt,
        cm_fahrt_haltestelle_id_haltestelle,
        cm_fahrt_haltestelle_ankunft_tatsaechlich,
        cm_fahrt_haltestelle_abfahrt_tatsaechlich,

        cm_haltestelle_name,
        cm_haltestelle_stadtteil,
        cm_haltestelle_latitude,
        cm_haltestelle_longitude,

        as_station_name,
        as_station_stadtteil,
        as_station_latitude,
        as_station_longitude,
        as_station_stations_typ,
        as_station_installationsdatum,
        as_station_status,

        as_sensor_id_station,
        as_sensor_sensortyp,
        as_sensor_einheit,
        as_sensor_installationsdatum,
        as_sensor_id_sensor,

        as_messung_messzeitpunkt,
        as_messung_messwert
    )
    SELECT
        m.id,
        fh.id,
        fp.id,
        fg.id,

        l.liniennummer,
        l.bezeichnung,
        l.verkehrsmittel,
        l.gueltig_ab,
        l.gueltig_bis,

        fzg.kapazitaet,

        f.id_linie,
        f.id_fahrzeug,
        f.datum,
        f.fahrtrichtung,

        fg.id_fahrt,
        fg.id_haltestelle,
        fg.einsteiger,
        fg.aussteiger,

        fp.id_fahrt,
        fp.id_haltestelle,
        fp.ankunft_geplant,
        fp.abfahrt_geplant,

        fh.id_fahrt,
        fh.id_haltestelle,
        fh.ankunft_tatsaechlich,
        fh.abfahrt_tatsaechlich,

        h.name,
        h.stadtteil,
        h.latitude,
        h.longitude,

        ast.name,
        ast.stadtteil,
        ast.latitude,
        ast.longitude,
        ast.stations_typ,
        ast.installationsdatum,
        ast.status,

        s.id_station,
        s.sensortyp,
        s.einheit,
        s.installationsdatum,
        s.id,

        m.messzeitpunkt,
        m.messwert

    FROM staging.as_messung m
    JOIN staging.as_sensor s
        ON s.id = m.id_sensor
    JOIN staging.as_station ast
        ON ast.id = s.id_station

    LEFT JOIN staging.cm_fahrt_haltestelle fh
        ON m.messzeitpunkt BETWEEN
            COALESCE(fh.ankunft_tatsaechlich, fh.abfahrt_tatsaechlich)
                - p_zeitfenster_minuten * INTERVAL '1 minute'
            AND
            COALESCE(fh.abfahrt_tatsaechlich, fh.ankunft_tatsaechlich)
                + p_zeitfenster_minuten * INTERVAL '1 minute'

    LEFT JOIN staging.cm_fahrt f
        ON f.id = fh.id_fahrt
    LEFT JOIN staging.cm_linie l
        ON l.id = f.id_linie
    LEFT JOIN staging.cm_fahrzeug fzg
        ON fzg.id = f.id_fahrzeug
    LEFT JOIN staging.cm_haltestelle h
        ON h.id = fh.id_haltestelle

    LEFT JOIN staging.cm_fahrplan fp
        ON fp.id_fahrt = fh.id_fahrt
       AND fp.id_haltestelle = fh.id_haltestelle

    LEFT JOIN staging.cm_fahrgastaufkommen fg
        ON fg.id_fahrt = fh.id_fahrt
       AND fg.id_haltestelle = fh.id_haltestelle

    WHERE NOT EXISTS (
        SELECT 1
        FROM core.topic_wetter_und_oepnv tgt
        WHERE tgt.src_as_messung_id = m.id
          AND tgt.src_cm_fahrt_haltestelle_id
                IS NOT DISTINCT FROM fh.id
          AND tgt.src_cm_fahrplan_id
                IS NOT DISTINCT FROM fp.id
          AND tgt.src_cm_fahrgastaufkommen_id
                IS NOT DISTINCT FROM fg.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE core.transfer_topic_veranstaltungen_und_fahrradnutzung(
    p_zeitfenster_minuten INTEGER DEFAULT 60
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_zeitfenster_minuten < 0 THEN
        RAISE EXCEPTION 'Das Zeitfenster darf nicht negativ sein.';
    END IF;

    INSERT INTO core.topic_veranstaltungen_und_fahrradnutzung (
        src_ce_termin_id,
        src_ce_ticket_id,
        src_ce_einlass_id,
        src_bs_fahrt_id,

        ce_veranstaltung_name,
        ce_veranstaltung_beschreibung,
        ce_veranstaltung_id_typ,
        ce_veranstaltung_id_veranstalter,
        ce_veranstalter_name,
        ce_veranstalter_organisationstyp,
        ce_veranstaltungstyp_bezeichnung,

        ce_veranstaltungstermin_id_veranstaltung,
        ce_veranstalter_id_veranstaltungsort,
        ce_veranstalter_beginn_geplant,
        ce_veranstalter_ende_geplant,
        ce_veranstalter_beginn_tatsaechlich,
        ce_veranstalter_ende_tatsaechlich,
        ce_veranstalter_status,

        ce_ticket_tickettyp,
        ce_ticket_status,
        ce_einlass_id_ticket,
        ce_einlass_einlass_status,
        ce_einlass_einlass_zeitpunkt,

        ce_veranstaltungsort_name,
        ce_veranstaltungsort_stadtteil,
        ce_veranstaltungsort_latitude,
        ce_veranstaltungsort_longitude,
        ce_veranstaltungsort_kapazitaet,

        bs_fahrt_id_startstation,
        bs_fahrt_id_endstation,
        bs_fahrt_startzeit,
        bs_fahrt_endzeit,
        bs_fahrt_status,

        bs_station_1_name,
        bs_station_1_stadtteil,
        bs_station_1_latitude,
        bs_station_1_longitude,
        bs_station_1_kapazitaet,

        bs_station_2_name,
        bs_station_2_stadtteil,
        bs_station_2_latitude,
        bs_station_2_longitude,
        bs_station_2_kapazitaet
    )
    SELECT
        t.id,
        tk.id,
        e.id,
        bf.id,

        v.name,
        v.beschreibung,
        v.id_typ,
        v.id_veranstalter,
        va.name,
        va.organisationstyp,
        vt.bezeichnung,

        t.id_veranstaltung,
        t.id_veranstaltungsort,
        t.beginn_geplant,
        t.ende_geplant,
        t.beginn_tatsaechlich,
        t.ende_tatsaechlich,
        t.status,

        tk.tickettyp,
        tk.status,
        e.id_ticket,
        e.einlass_status,
        e.einlasszeitpunkt,

        ort.name,
        ort.stadtteil,
        ort.latitude,
        ort.longitude,
        ort.kapazitaet,

        bf.id_startstation,
        bf.id_zielstation,
        bf.startzeit,
        bf.endzeit,
        bf.status,

        bs1.name,
        bs1.stadtteil,
        bs1.latitude,
        bs1.longitude,
        bs1.kapazitaet,

        bs2.name,
        bs2.stadtteil,
        bs2.latitude,
        bs2.longitude,
        bs2.kapazitaet

    FROM staging.ce_veranstaltungstermin t
    JOIN staging.ce_veranstaltung v
        ON v.id = t.id_veranstaltung

    LEFT JOIN staging.ce_veranstaltungstyp vt
        ON vt.id = v.id_typ
    LEFT JOIN staging.ce_veranstalter va
        ON va.id = v.id_veranstalter
    LEFT JOIN staging.ce_veranstaltungsort ort
        ON ort.id = t.id_veranstaltungsort
    LEFT JOIN staging.ce_ticket tk
        ON tk.id_termin = t.id
    LEFT JOIN staging.ce_einlass e
        ON e.id_ticket = tk.id

    LEFT JOIN staging.bs_fahrt bf
        ON bf.startzeit <=
            COALESCE(t.ende_tatsaechlich, t.ende_geplant)
                + p_zeitfenster_minuten * INTERVAL '1 minute'
       AND bf.endzeit >=
            COALESCE(t.beginn_tatsaechlich, t.beginn_geplant)
                - p_zeitfenster_minuten * INTERVAL '1 minute'

    LEFT JOIN staging.bs_station bs1
        ON bs1.id = bf.id_startstation
    LEFT JOIN staging.bs_station bs2
        ON bs2.id = bf.id_zielstation

    WHERE NOT EXISTS (
        SELECT 1
        FROM core.topic_veranstaltungen_und_fahrradnutzung tgt
        WHERE tgt.src_ce_termin_id = t.id
          AND tgt.src_ce_ticket_id IS NOT DISTINCT FROM tk.id
          AND tgt.src_ce_einlass_id IS NOT DISTINCT FROM e.id
          AND tgt.src_bs_fahrt_id IS NOT DISTINCT FROM bf.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE core.transfer_topic_veranstaltungen_und_oepnv(
    p_zeitfenster_minuten INTEGER DEFAULT 60
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_zeitfenster_minuten < 0 THEN
        RAISE EXCEPTION 'Das Zeitfenster darf nicht negativ sein.';
    END IF;

    INSERT INTO core.topic_veranstaltungen_und_oepnv (
        src_ce_termin_id,
        src_ce_ticket_id,
        src_ce_einlass_id,
        src_cm_fahrt_haltestelle_id,
        src_cm_fahrplan_id,
        src_cm_fahrgastaufkommen_id,

        ce_veranstaltung_name,
        ce_veranstaltung_beschreibung,
        ce_veranstaltung_id_typ,
        ce_veranstaltung_id_veranstalter,
        ce_veranstalter_name,
        ce_veranstalter_organisationstyp,
        ce_veranstaltungstyp_bezeichnung,

        ce_veranstaltungstermin_id_veranstaltung,
        ce_veranstalter_id_veranstaltungsort,
        ce_veranstalter_beginn_geplant,
        ce_veranstalter_ende_geplant,
        ce_veranstalter_beginn_tatsaechlich,
        ce_veranstalter_ende_tatsaechlich,
        ce_veranstalter_status,

        ce_ticket_tickettyp,
        ce_ticket_status,
        ce_einlass_id_ticket,
        ce_einlass_einlass_status,
        ce_einlass_einlass_zeitpunkt,

        ce_veranstaltungsort_name,
        ce_veranstaltungsort_stadtteil,
        ce_veranstaltungsort_latitude,
        ce_veranstaltungsort_longitude,
        ce_veranstaltungsort_kapazitaet,

        cm_linie_liniennummer,
        cm_linie_bezeichnung,
        cm_linie_verkehrsmittel,
        cm_linie_gueltig_ab,
        cm_linie_gueltig_bis,

        cm_fahrzeug_kapazitaet,

        cm_fahrt_id_linie,
        cm_fahrt_fahrzeug,
        cm_fahrt_datum,
        cm_fahrt_fahrtrichtung,

        cm_fahrgastaufkommen_id_fahrt,
        cm_fahrgastaufkommen_id_haltestelle,
        cm_fahrgastaufkommen_einsteiger,
        cm_fahrgastaufkommen_aussteiger,

        cm_fahrplan_id_fahrt,
        cm_fahrplan_id_haltestelle,
        cm_fahrplan_ankunft_geplant,
        cm_fahrplan_abfahrt_geplant,

        cm_fahrt_haltestelle_id_fahrt,
        cm_fahrt_haltestelle_id_haltestelle,
        cm_fahrt_haltestelle_ankunft_tatsaechlich,
        cm_fahrt_haltestelle_abfahrt_tatsaechlich,

        cm_haltestelle_name,
        cm_haltestelle_stadtteil,
        cm_haltestelle_latitude,
        cm_haltestelle_longitude
    )
    SELECT
        t.id,
        tk.id,
        e.id,
        fh.id,
        fp.id,
        fg.id,

        v.name,
        v.beschreibung,
        v.id_typ,
        v.id_veranstalter,
        va.name,
        va.organisationstyp,
        vt.bezeichnung,

        t.id_veranstaltung,
        t.id_veranstaltungsort,
        t.beginn_geplant,
        t.ende_geplant,
        t.beginn_tatsaechlich,
        t.ende_tatsaechlich,
        t.status,

        tk.tickettyp,
        tk.status,
        e.id_ticket,
        e.einlass_status,
        e.einlasszeitpunkt,

        ort.name,
        ort.stadtteil,
        ort.latitude,
        ort.longitude,
        ort.kapazitaet,

        l.liniennummer,
        l.bezeichnung,
        l.verkehrsmittel,
        l.gueltig_ab,
        l.gueltig_bis,

        fzg.kapazitaet,

        f.id_linie,
        f.id_fahrzeug,
        f.datum,
        f.fahrtrichtung,

        fg.id_fahrt,
        fg.id_haltestelle,
        fg.einsteiger,
        fg.aussteiger,

        fp.id_fahrt,
        fp.id_haltestelle,
        fp.ankunft_geplant,
        fp.abfahrt_geplant,

        fh.id_fahrt,
        fh.id_haltestelle,
        fh.ankunft_tatsaechlich,
        fh.abfahrt_tatsaechlich,

        h.name,
        h.stadtteil,
        h.latitude,
        h.longitude

    FROM staging.ce_veranstaltungstermin t
    JOIN staging.ce_veranstaltung v
        ON v.id = t.id_veranstaltung

    LEFT JOIN staging.ce_veranstaltungstyp vt
        ON vt.id = v.id_typ
    LEFT JOIN staging.ce_veranstalter va
        ON va.id = v.id_veranstalter
    LEFT JOIN staging.ce_veranstaltungsort ort
        ON ort.id = t.id_veranstaltungsort
    LEFT JOIN staging.ce_ticket tk
        ON tk.id_termin = t.id
    LEFT JOIN staging.ce_einlass e
        ON e.id_ticket = tk.id

    LEFT JOIN staging.cm_fahrt_haltestelle fh
        ON COALESCE(fh.ankunft_tatsaechlich, fh.abfahrt_tatsaechlich)
            <= COALESCE(t.ende_tatsaechlich, t.ende_geplant)
                + p_zeitfenster_minuten * INTERVAL '1 minute'
       AND COALESCE(fh.abfahrt_tatsaechlich, fh.ankunft_tatsaechlich)
            >= COALESCE(t.beginn_tatsaechlich, t.beginn_geplant)
                - p_zeitfenster_minuten * INTERVAL '1 minute'

    LEFT JOIN staging.cm_fahrt f
        ON f.id = fh.id_fahrt
    LEFT JOIN staging.cm_linie l
        ON l.id = f.id_linie
    LEFT JOIN staging.cm_fahrzeug fzg
        ON fzg.id = f.id_fahrzeug
    LEFT JOIN staging.cm_haltestelle h
        ON h.id = fh.id_haltestelle

    LEFT JOIN staging.cm_fahrplan fp
        ON fp.id_fahrt = fh.id_fahrt
       AND fp.id_haltestelle = fh.id_haltestelle

    LEFT JOIN staging.cm_fahrgastaufkommen fg
        ON fg.id_fahrt = fh.id_fahrt
       AND fg.id_haltestelle = fh.id_haltestelle

    WHERE NOT EXISTS (
        SELECT 1
        FROM core.topic_veranstaltungen_und_oepnv tgt
        WHERE tgt.src_ce_termin_id = t.id
          AND tgt.src_ce_ticket_id IS NOT DISTINCT FROM tk.id
          AND tgt.src_ce_einlass_id IS NOT DISTINCT FROM e.id
          AND tgt.src_cm_fahrt_haltestelle_id
                IS NOT DISTINCT FROM fh.id
          AND tgt.src_cm_fahrplan_id
                IS NOT DISTINCT FROM fp.id
          AND tgt.src_cm_fahrgastaufkommen_id
                IS NOT DISTINCT FROM fg.id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE core.transfer_topic_luftqualitaet_und_mobilitaetsaufkommen(
    p_zeitfenster_minuten INTEGER DEFAULT 60
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_zeitfenster_minuten < 0 THEN
        RAISE EXCEPTION 'Das Zeitfenster darf nicht negativ sein.';
    END IF;

    INSERT INTO core.topic_luftqualitaet_und_mobilitaetsaufkommen (
        src_bs_fahrt_id,
        src_as_messung_id,
        src_cm_fahrt_haltestelle_id,
        src_cm_fahrplan_id,
        src_cm_fahrgastaufkommen_id,

        bs_fahrt_id_startstation,
        bs_fahrt_id_endstation,
        bs_fahrt_startzeit,
        bs_fahrt_endzeit,
        bs_fahrt_status,

        bs_station_1_name,
        bs_station_1_stadtteil,
        bs_station_1_latitude,
        bs_station_1_longitude,
        bs_station_1_kapazitaet,

        bs_station_2_name,
        bs_station_2_stadtteil,
        bs_station_2_latitude,
        bs_station_2_longitude,
        bs_station_2_kapazitaet,

        as_station_name,
        as_station_stadtteil,
        as_station_latitude,
        as_station_longitude,
        as_station_stations_typ,
        as_station_installationsdatum,
        as_station_status,

        as_sensor_id_station,
        as_sensor_sensortyp,
        as_sensor_einheit,
        as_sensor_installationsdatum,
        as_sensor_id_sensor,

        as_messung_messzeitpunkt,
        as_messung_messwert,

        cm_linie_liniennummer,
        cm_linie_bezeichnung,
        cm_linie_verkehrsmittel,
        cm_linie_gueltig_ab,
        cm_linie_gueltig_bis,

        cm_fahrzeug_kapazitaet,

        cm_fahrt_id_linie,
        cm_fahrt_fahrzeug,
        cm_fahrt_datum,
        cm_fahrt_fahrtrichtung,

        cm_fahrgastaufkommen_id_fahrt,
        cm_fahrgastaufkommen_id_haltestelle,
        cm_fahrgastaufkommen_einsteiger,
        cm_fahrgastaufkommen_aussteiger,

        cm_fahrplan_id_fahrt,
        cm_fahrplan_id_haltestelle,
        cm_fahrplan_ankunft_geplant,
        cm_fahrplan_abfahrt_geplant,

        cm_fahrt_haltestelle_id_fahrt,
        cm_fahrt_haltestelle_id_haltestelle,
        cm_fahrt_haltestelle_ankunft_tatsaechlich,
        cm_fahrt_haltestelle_abfahrt_tatsaechlich,

        cm_haltestelle_name,
        cm_haltestelle_stadtteil,
        cm_haltestelle_latitude,
        cm_haltestelle_longitude
    )
    SELECT
        bf.id,
        m.id,
        fh.id,
        fp.id,
        fg.id,

        bf.id_startstation,
        bf.id_zielstation,
        bf.startzeit,
        bf.endzeit,
        bf.status,

        bs1.name,
        bs1.stadtteil,
        bs1.latitude,
        bs1.longitude,
        bs1.kapazitaet,

        bs2.name,
        bs2.stadtteil,
        bs2.latitude,
        bs2.longitude,
        bs2.kapazitaet,

        ast.name,
        ast.stadtteil,
        ast.latitude,
        ast.longitude,
        ast.stations_typ,
        ast.installationsdatum,
        ast.status,

        s.id_station,
        s.sensortyp,
        s.einheit,
        s.installationsdatum,
        s.id,

        m.messzeitpunkt,
        m.messwert,

        l.liniennummer,
        l.bezeichnung,
        l.verkehrsmittel,
        l.gueltig_ab,
        l.gueltig_bis,

        fzg.kapazitaet,

        f.id_linie,
        f.id_fahrzeug,
        f.datum,
        f.fahrtrichtung,

        fg.id_fahrt,
        fg.id_haltestelle,
        fg.einsteiger,
        fg.aussteiger,

        fp.id_fahrt,
        fp.id_haltestelle,
        fp.ankunft_geplant,
        fp.abfahrt_geplant,

        fh.id_fahrt,
        fh.id_haltestelle,
        fh.ankunft_tatsaechlich,
        fh.abfahrt_tatsaechlich,

        h.name,
        h.stadtteil,
        h.latitude,
        h.longitude

    FROM staging.as_messung m
    JOIN staging.as_sensor s
        ON s.id = m.id_sensor
    JOIN staging.as_station ast
        ON ast.id = s.id_station

    LEFT JOIN staging.bs_fahrt bf
        ON m.messzeitpunkt BETWEEN
            bf.startzeit
                - p_zeitfenster_minuten * INTERVAL '1 minute'
            AND
            bf.endzeit
                + p_zeitfenster_minuten * INTERVAL '1 minute'

    JOIN staging.bs_station bs1
        ON bs1.id = bf.id_startstation
    JOIN staging.bs_station bs2
        ON bs2.id = bf.id_zielstation

    LEFT JOIN staging.cm_fahrt_haltestelle fh
        ON m.messzeitpunkt BETWEEN
            fh.ankunft_tatsaechlich
                - p_zeitfenster_minuten * INTERVAL '1 minute'
            AND
            fh.abfahrt_tatsaechlich
                + p_zeitfenster_minuten * INTERVAL '1 minute'

    JOIN staging.cm_fahrt f
        ON f.id = fh.id_fahrt
    JOIN staging.cm_linie l
        ON l.id = f.id_linie
    JOIN staging.cm_fahrzeug fzg
        ON fzg.id = f.id_fahrzeug
    JOIN staging.cm_haltestelle h
        ON h.id = fh.id_haltestelle

    JOIN staging.cm_fahrplan fp
        ON fp.id_fahrt = fh.id_fahrt
       AND fp.id_haltestelle = fh.id_haltestelle

    JOIN staging.cm_fahrgastaufkommen fg
        ON fg.id_fahrt = fh.id_fahrt
       AND fg.id_haltestelle = fh.id_haltestelle

    WHERE NOT EXISTS (
        SELECT 1
        FROM core.topic_luftqualitaet_und_mobilitaetsaufkommen tgt
        WHERE tgt.src_bs_fahrt_id = bf.id
          AND tgt.src_as_messung_id = m.id
          AND tgt.src_cm_fahrt_haltestelle_id = fh.id
          AND tgt.src_cm_fahrplan_id = fp.id
          AND tgt.src_cm_fahrgastaufkommen_id = fg.id
    );
END;
$$;
