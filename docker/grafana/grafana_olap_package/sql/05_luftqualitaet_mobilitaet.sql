-- 1) Kennzahlen: Fahrrad, ÖPNV und Sensor-Messwert
SELECT
    COUNT(DISTINCT f.fahrt_key) AS fahrradfahrten,
    COALESCE(SUM(f.linie_einsteiger), 0) AS oepnv_einsteiger,
    COALESCE(SUM(f.linie_aussteiger), 0) AS oepnv_aussteiger,
    ROUND(AVG(f.wetterstation_messwert)::numeric, 2) AS durchschnittlicher_messwert
FROM reporting.luftqualitaet_und_mobilitaetsaufkommen f
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_fahradstation st
    ON st.fahrt_key = f.fahrt_key
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_linie l
    ON l.linie_key = f.linie_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit,
                              f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant,
                              s.sensor_messzeitpunkt))
  AND s.sensor_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring});

-- 2) Mobilitätsaufkommen im Zeitverlauf
SELECT
    $__timeGroupAlias(d.zeitpunkt, '1d'),

    COUNT(DISTINCT d.fahrt_key) AS fahrradfahrten,

    SUM(d.linie_einsteiger) AS oepnv_einsteiger,

    SUM(d.linie_aussteiger) AS oepnv_aussteiger

FROM (
    SELECT
        COALESCE(
            f.fahrradstation_startzeit,
            f.linie_ankunft_tatsaechlich,
            f.linie_ankunft_geplant,
            f.linie_abfahrt_tatsaechlich,
            f.linier_abfahrt_geplant,
            s.sensor_messzeitpunkt
        ) AS zeitpunkt,

        f.fahrt_key,
        f.linie_einsteiger,
        f.linie_aussteiger,
        f.sensor_key,
        f.linie_key

    FROM reporting.luftqualitaet_und_mobilitaetsaufkommen f

    LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor s
        ON s.sensor_key = f.sensor_key
) d

LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor s
    ON s.sensor_key = d.sensor_key

LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_linie l
    ON l.linie_key = d.linie_key

WHERE $__timeFilter(d.zeitpunkt)

  AND s.sensor_stadtteil IN (${stadtteil:sqlstring})

  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})

  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})

GROUP BY 1
ORDER BY 1;

-- 3) Mobilitätsaufkommen nach Sensor-Stadtteil
SELECT
    s.sensor_stadtteil AS stadtteil,
    COUNT(DISTINCT f.fahrt_key) AS fahrradfahrten,
    SUM(f.linie_einsteiger) AS oepnv_einsteiger,
    SUM(f.linie_aussteiger) AS oepnv_aussteiger,
    ROUND(AVG(f.wetterstation_messwert)::numeric, 2) AS durchschnittlicher_messwert
FROM reporting.luftqualitaet_und_mobilitaetsaufkommen f
JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_linie l
    ON l.linie_key = f.linie_key
WHERE s.sensor_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
GROUP BY 1
ORDER BY 1;

-- 4) Streudiagramm: Sensor-Messwert und Mobilitätskennzahlen
SELECT
    f.wetterstation_messwert AS messwert,
    COUNT(DISTINCT f.fahrt_key) AS fahrradfahrten,
    SUM(f.linie_einsteiger) AS oepnv_einsteiger,
    s.sensor_stadtteil,
    s.sensor_sensortyp
FROM reporting.luftqualitaet_und_mobilitaetsaufkommen f
JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_linie l
    ON l.linie_key = f.linie_key
WHERE f.wetterstation_messwert IS NOT NULL
  AND s.sensor_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
GROUP BY
    f.wetterstation_messwert,
    s.sensor_stadtteil,
    s.sensor_sensortyp
ORDER BY 1
LIMIT 5000;

-- 5) Pivot-Grundlage: Stadtteil x Mobilitätsart
-- Grafana Grouping to matrix: Row=stadtteil,
-- Column=mobilitaetsart, Cell=anzahl.
SELECT
    s.sensor_stadtteil AS stadtteil,
    mobilitaet.mobilitaetsart,
    SUM(mobilitaet.anzahl) AS anzahl

FROM reporting.luftqualitaet_und_mobilitaetsaufkommen f

JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor s
    ON s.sensor_key = f.sensor_key

LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_linie l
    ON l.linie_key = f.linie_key

CROSS JOIN LATERAL (
    VALUES
        ('Fahrradfahrten',
            CASE WHEN f.fahrt_key IS NOT NULL THEN 1 ELSE 0 END::numeric),

        ('ÖPNV-Einsteiger',
            COALESCE(f.linie_einsteiger, 0)::numeric),

        ('ÖPNV-Aussteiger',
            COALESCE(f.linie_aussteiger, 0)::numeric)

) AS mobilitaet(mobilitaetsart, anzahl)

WHERE s.sensor_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})

GROUP BY
    s.sensor_stadtteil,
    mobilitaet.mobilitaetsart

ORDER BY
    s.sensor_stadtteil,
    mobilitaet.mobilitaetsart;

-- 6) Detailtabelle
SELECT
    f.core_id,
    d.datum,
    s.sensor_name,
    s.sensor_stadtteil,
    s.sensor_sensortyp,
    f.wetterstation_einheit,
    f.wetterstation_messwert,
    f.fahrradstation_startzeit,
    st.fahrt_station_startstation_stadtteil,
    l.linie_verkehrsmittel,
    l.linie_haltestelle_name,
    f.linie_einsteiger,
    f.linie_aussteiger
FROM reporting.luftqualitaet_und_mobilitaetsaufkommen f
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_fahradstation st
    ON st.fahrt_key = f.fahrt_key
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_linie l
    ON l.linie_key = f.linie_key
LEFT JOIN reporting.luftqualitaet_und_mobilitaetsaufkommen_datum d
    ON d.datum_key = f.datum_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit,
                              f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant,
                              s.sensor_messzeitpunkt))
  AND s.sensor_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
ORDER BY d.datum DESC NULLS LAST
LIMIT 500;
