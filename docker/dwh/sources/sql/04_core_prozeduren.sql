CREATE OR REPLACE PROCEDURE core.transfer_dim_fahrradstation()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO core.DIM_Fahrradstation (
        src_bs_fahrt_id,
        Fahrt_id_startstation,
        Fahrt_id_endstation,
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
        f.id,
        f.id_startstation,
        f.id_zielstation,
        f.status,
        s1.stadtteil,
        s1.latitude,
        s1.longitude,
        s1.kapazitaet,
        s2.stadtteil,
        s2.latitude,
        s2.longitude,
        s2.kapazitaet
    FROM staging.bs_fahrt f
    JOIN staging.bs_station s1
        ON s1.id = f.id_startstation
    JOIN staging.bs_station s2
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
        Sensor_installationsdatum,
        Sensor_id_sensor,
        Sensor_messzeitpunkt
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
        s.installationsdatum,
        s.id,
        m.messzeitpunkt
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
        Veranstaltung_termin_status,
        Veranstaltung_id_termin,
        Veranstaltung_tickettyp,
        Veranstaltung_Ticket_status,
        Veranstaltung_id_ticket,
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
        t.status,
        ti.id_termin,
        ti.tickettyp,
        ti.status,
        e.id_ticket,
        o.name,
        o.stadtteil,
        o.latitude,
        o.longitude,
        o.kapazitaet
    FROM staging.ce_veranstaltung v
    JOIN staging.ce_veranstaltungstyp vt
        ON vt.id = v.id_typ
    JOIN staging.ce_veranstalter va
        ON va.id = v.id_veranstalter
    JOIN staging.ce_veranstaltungstermin t
        ON t.id_veranstaltung = v.id
    JOIN staging.ce_veranstaltungsort o
        ON o.id = t.id_veranstaltungsort
    JOIN staging.ce_ticket ti
        ON ti.id_termin = t.id
    JOIN staging.ce_einlass e
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
        h.name,
        h.stadtteil,
        h.latitude,
        h.longitude
    FROM staging.cm_fahrt_haltestelle fh
    JOIN staging.cm_fahrt f
        ON f.id = fh.id_fahrt
    JOIN staging.cm_linie l
        ON l.id = f.id_linie
    JOIN staging.cm_fahrzeug fzg
        ON fzg.id = f.id_fahrzeug
    JOIN staging.cm_fahrplan fp
        ON fp.id_fahrt = fh.id_fahrt
       AND fp.id_haltestelle = fh.id_haltestelle
    JOIN staging.cm_fahrgastaufkommen fg
        ON fg.id_fahrt = fh.id_fahrt
       AND fg.id_haltestelle = fh.id_haltestelle
    JOIN staging.cm_haltestelle h
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
        bs_station_Startstation_name,
        bs_station_Endstation_name,
        as_sensor_einheit,
        as_sensor_id_sensor,
        as_messung_messwert
    )
    SELECT
        bf.id,
        m.id,

        bf.id_startstation,
        bf.id_zielstation,
        bf.startzeit,
        bf.endzeit,

        bs1.name,
        bs2.name,

        s.einheit,
        s.id,

        m.messwert

    FROM staging.as_messung m
    JOIN staging.as_sensor s
        ON s.id = m.id_sensor
    JOIN staging.as_station ast
        ON ast.id = s.id_station

    JOIN staging.bs_fahrt bf
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
;
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

        cm_fahrt_id_linie,
        cm_fahrt_fahrzeug,

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

        as_sensor_einheit,
        as_sensor_id_sensor,

        as_messung_messwert
    )
    SELECT
        m.id,
        fh.id,
        fp.id,
        fg.id,

        f.id_linie,
        f.id_fahrzeug,

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

        s.einheit,
        s.id,

        m.messwert

    FROM staging.as_messung m
    JOIN staging.as_sensor s
        ON s.id = m.id_sensor
    JOIN staging.as_station ast
        ON ast.id = s.id_station

    JOIN staging.cm_fahrt_haltestelle fh
        ON m.messzeitpunkt BETWEEN
            COALESCE(fh.ankunft_tatsaechlich, fh.abfahrt_tatsaechlich)
                - p_zeitfenster_minuten * INTERVAL '1 minute'
            AND
            COALESCE(fh.abfahrt_tatsaechlich, fh.ankunft_tatsaechlich)
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

        ce_veranstaltung_id_typ,
        ce_veranstaltung_id_veranstalter,

        ce_veranstaltungstermin_id_veranstaltung,
        ce_veranstalter_id_veranstaltungsort,
        ce_veranstalter_beginn_geplant,
        ce_veranstalter_ende_geplant,
        ce_veranstalter_beginn_tatsaechlich,
        ce_veranstalter_ende_tatsaechlich,

        ce_ticket_id_termin,
        ce_einlass_id_ticket,
        ce_einlass_einlass_status,
        ce_einlass_einlass_zeitpunkt,

        bs_fahrt_id_startstation,
        bs_fahrt_id_endstation,
        bs_fahrt_startzeit,
        bs_fahrt_endzeit,
        bs_station_Startstation_name,
        bs_station_Endstation_name
    )
    SELECT
        t.id,
        tk.id,
        e.id,
        bf.id,

        v.id_typ,
        v.id_veranstalter,

        t.id_veranstaltung,
        t.id_veranstaltungsort,
        t.beginn_geplant,
        t.ende_geplant,
        t.beginn_tatsaechlich,
        t.ende_tatsaechlich,

        tk.id_termin,
        e.id_ticket,
        e.einlass_status,
        e.einlasszeitpunkt,

        bf.id_startstation,
        bf.id_zielstation,
        bf.startzeit,
        bf.endzeit,
        bs1.name,
        bs2.name

    FROM staging.ce_veranstaltungstermin t
    JOIN staging.ce_veranstaltung v
        ON v.id = t.id_veranstaltung

    JOIN staging.ce_veranstaltungstyp vt
        ON vt.id = v.id_typ
    JOIN staging.ce_veranstalter va
        ON va.id = v.id_veranstalter
    JOIN staging.ce_veranstaltungsort ort
        ON ort.id = t.id_veranstaltungsort
    JOIN staging.ce_ticket tk
        ON tk.id_termin = t.id
    JOIN staging.ce_einlass e
        ON e.id_ticket = tk.id

    JOIN staging.bs_fahrt bf
        ON bf.startzeit <=
            COALESCE(t.ende_tatsaechlich, t.ende_geplant)
                + p_zeitfenster_minuten * INTERVAL '1 minute'
       AND bf.endzeit >=
            COALESCE(t.beginn_tatsaechlich, t.beginn_geplant)
                - p_zeitfenster_minuten * INTERVAL '1 minute'

    JOIN staging.bs_station bs1
        ON bs1.id = bf.id_startstation
    JOIN staging.bs_station bs2
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

        ce_veranstaltung_id_typ,
        ce_veranstaltung_id_veranstalter,
        ce_veranstaltungstermin_id_veranstaltung,

        ce_veranstalter_id_veranstaltungsort,
        ce_veranstalter_beginn_geplant,
        ce_veranstalter_ende_geplant,
        ce_veranstalter_beginn_tatsaechlich,
        ce_veranstalter_ende_tatsaechlich,

        ce_ticket_id_termin,
        ce_einlass_id_ticket,
        ce_einlass_einlass_status,
        ce_einlass_einlass_zeitpunkt,

        cm_fahrt_id_linie,
        cm_fahrt_fahrzeug,

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

        cm_haltestelle_name
    )
    SELECT
        t.id,
        tk.id,
        e.id,
        fh.id,
        fp.id,
        fg.id,

        v.id_typ,
        v.id_veranstalter,
        t.id_veranstaltung,

        t.id_veranstaltungsort,
        t.beginn_geplant,
        t.ende_geplant,
        t.beginn_tatsaechlich,
        t.ende_tatsaechlich,

        tk.id_termin,
        e.id_ticket,
        e.einlass_status,
        e.einlasszeitpunkt,

        f.id_linie,
        f.id_fahrzeug,

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

        h.name

    FROM staging.ce_veranstaltungstermin t
    JOIN staging.ce_veranstaltung v
        ON v.id = t.id_veranstaltung

    JOIN staging.ce_veranstaltungstyp vt
        ON vt.id = v.id_typ
    JOIN staging.ce_veranstalter va
        ON va.id = v.id_veranstalter
    JOIN staging.ce_veranstaltungsort ort
        ON ort.id = t.id_veranstaltungsort
    JOIN staging.ce_ticket tk
        ON tk.id_termin = t.id
    JOIN staging.ce_einlass e
        ON e.id_ticket = tk.id

    JOIN staging.cm_fahrt_haltestelle fh
        ON COALESCE(fh.ankunft_tatsaechlich, fh.abfahrt_tatsaechlich)
            <= COALESCE(t.ende_tatsaechlich, t.ende_geplant)
                + p_zeitfenster_minuten * INTERVAL '1 minute'
       AND COALESCE(fh.abfahrt_tatsaechlich, fh.ankunft_tatsaechlich)
            >= COALESCE(t.beginn_tatsaechlich, t.beginn_geplant)
                - p_zeitfenster_minuten * INTERVAL '1 minute'

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
        bs_station_Startstation_name,
        bs_station_Endstation_name,

        as_sensor_einheit,
        as_sensor_id_sensor,
        as_messung_messwert,

        cm_fahrt_id_linie,
        cm_fahrt_fahrzeug,

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

        cm_haltestelle_name
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
        bs1.name,
        bs2.name,

        s.einheit,
        s.id,
        m.messwert,

        f.id_linie,
        f.id_fahrzeug,

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

        h.name

    FROM staging.as_messung m
    JOIN staging.as_sensor s
        ON s.id = m.id_sensor
    JOIN staging.as_station ast
        ON ast.id = s.id_station

    JOIN staging.bs_fahrt bf
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

    JOIN staging.cm_fahrt_haltestelle fh
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

CREATE OR REPLACE PROCEDURE core.fill_dim_datum(
    IN p_start_jahr INTEGER,
    IN p_end_jahr   INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_anzahl BIGINT;
BEGIN
    -- Parameter prüfen
    IF p_start_jahr IS NULL OR p_end_jahr IS NULL THEN
        RAISE EXCEPTION 'Startjahr und Endjahr dürfen nicht NULL sein.';
    END IF;

    IF p_start_jahr > p_end_jahr THEN
        RAISE EXCEPTION
            'Das Startjahr (%) darf nicht größer als das Endjahr (%) sein.',
            p_start_jahr, p_end_jahr;
    END IF;

    IF p_start_jahr < 1 OR p_end_jahr > 9999 THEN
        RAISE EXCEPTION
            'Die Jahre müssen zwischen 1 und 9999 liegen.';
    END IF;

    -- Stundendatensätze erzeugen
    INSERT INTO core.DIM_Datum (
        Datum_Key,
        Stunde,
        Datum,
        Monat,
        Quartal,
        Jahr
    )
    SELECT
        TO_CHAR(ts, 'YYYYMMDDHH24')::BIGINT AS Datum_Key,
        EXTRACT(HOUR FROM ts)::SMALLINT     AS Stunde,
        ts::DATE                            AS Datum,
        EXTRACT(MONTH FROM ts)::SMALLINT    AS Monat,
        EXTRACT(QUARTER FROM ts)::SMALLINT  AS Quartal,
        EXTRACT(YEAR FROM ts)::SMALLINT     AS Jahr
    FROM generate_series(
        MAKE_TIMESTAMP(p_start_jahr, 1, 1, 0, 0, 0),
        MAKE_TIMESTAMP(p_end_jahr, 12, 31, 23, 0, 0),
        INTERVAL '1 hour'
    ) AS ts
    ON CONFLICT (Datum_Key) DO NOTHING;

    -- Anzahl der tatsächlich eingefügten Datensätze
    GET DIAGNOSTICS v_anzahl = ROW_COUNT;

    RAISE NOTICE
        'DIM_Datum: % neue Stunden für den Zeitraum % bis % eingefügt.',
        v_anzahl, p_start_jahr, p_end_jahr;
END;
$$;