-- 1) Kennzahlen
SELECT
    COALESCE(SUM(f.linie_einsteiger), 0) AS einsteiger,
    COALESCE(SUM(f.linie_aussteiger), 0) AS aussteiger,
    ROUND(AVG(f.wetterstation_messwert)::numeric, 2) AS durchschnittlicher_messwert
FROM reporting.wetter_und_oepnv f
LEFT JOIN reporting.wetter_und_oepnv_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.wetter_und_oepnv_linie l
    ON l.linie_key = f.linie_key
LEFT JOIN reporting.wetter_und_oepnv_datum d
    ON d.datum_key = f.datum_key
WHERE $__timeFilter(COALESCE(f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant,
                              s.sensor_messzeitpunkt))
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
  AND l.linie_haltestelle_stadtteil IN (${stadtteil:sqlstring});

-- 2) Wetter und Fahrgastaufkommen im Zeitverlauf
SELECT
    $__timeGroupAlias(d.zeitpunkt, '1h'),
    SUM(d.linie_einsteiger) AS einsteiger,
    SUM(d.linie_aussteiger) AS aussteiger,
    AVG(d.wetterstation_messwert) AS wetter_messwert

FROM (
    SELECT
        COALESCE(
            f.linie_ankunft_tatsaechlich,
            f.linie_ankunft_geplant,
            f.linie_abfahrt_tatsaechlich,
            f.linier_abfahrt_geplant
        ) AS zeitpunkt,

        f.linie_einsteiger,
        f.linie_aussteiger,
        f.wetterstation_messwert,
        f.sensor_key,
        f.linie_key

    FROM reporting.wetter_und_oepnv f
) d

LEFT JOIN reporting.wetter_und_oepnv_sensor s
    ON s.sensor_key = d.sensor_key

LEFT JOIN reporting.wetter_und_oepnv_linie l
    ON l.linie_key = d.linie_key

WHERE $__timeFilter(d.zeitpunkt)

  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})

  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})

  AND l.linie_haltestelle_stadtteil IN (${stadtteil:sqlstring})

GROUP BY 1
ORDER BY 1;

-- 3) Streudiagramm: Wetter-Messwert gegen Einsteiger
SELECT
    f.wetterstation_messwert AS wetter_messwert,
    f.linie_einsteiger AS einsteiger,
    s.sensor_sensortyp,
    f.wetterstation_einheit
FROM reporting.wetter_und_oepnv f
LEFT JOIN reporting.wetter_und_oepnv_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.wetter_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE f.wetterstation_messwert IS NOT NULL
  AND f.linie_einsteiger IS NOT NULL
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
LIMIT 5000;

-- 4) Fahrgastaufkommen nach Verkehrsmittel und Sensortyp
SELECT
    l.linie_verkehrsmittel AS verkehrsmittel,
    s.sensor_sensortyp,
    f.wetterstation_einheit,
    ROUND(AVG(f.wetterstation_messwert)::numeric, 2) AS durchschnittlicher_messwert,
    SUM(f.linie_einsteiger) AS einsteiger
FROM reporting.wetter_und_oepnv f
LEFT JOIN reporting.wetter_und_oepnv_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.wetter_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
  AND l.linie_haltestelle_stadtteil IN (${stadtteil:sqlstring})
GROUP BY 1, 2, 3
ORDER BY 1, 2;

-- 5) Pivot-Grundlage: Verkehrsmittel x Sensortyp
-- Grafana Grouping to matrix: Row=verkehrsmittel,
-- Column=sensortyp, Cell=einsteiger.
SELECT
    l.linie_verkehrsmittel AS verkehrsmittel,
    COALESCE(s.sensor_sensortyp, 'Unbekannt') AS sensortyp,
    SUM(f.linie_einsteiger) AS einsteiger
FROM reporting.wetter_und_oepnv f
LEFT JOIN reporting.wetter_und_oepnv_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.wetter_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
GROUP BY 1, 2
ORDER BY 1, 2;

-- 6) Detailtabelle
SELECT
    f.core_id,
    COALESCE(f.linie_ankunft_tatsaechlich, f.linie_ankunft_geplant) AS ankunft,
    COALESCE(f.linier_abfahrt_geplant, f.linie_abfahrt_tatsaechlich) AS abfahrt,
    l.linie_liniennummer,
    l.linie_verkehrsmittel,
    l.linie_haltestelle_name,
    l.linie_haltestelle_stadtteil,
    s.sensor_name,
    s.sensor_sensortyp,
    f.wetterstation_einheit,
    f.wetterstation_messwert,
    f.linie_einsteiger,
    f.linie_aussteiger
FROM reporting.wetter_und_oepnv f
LEFT JOIN reporting.wetter_und_oepnv_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.wetter_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE $__timeFilter(COALESCE(f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant))
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
  AND l.linie_haltestelle_stadtteil IN (${stadtteil:sqlstring})
ORDER BY ankunft DESC NULLS LAST
LIMIT 500;
