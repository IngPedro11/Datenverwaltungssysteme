-- 1) Kennzahlen: Fahrten und Wetter-Messwert
SELECT
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten,
    ROUND(AVG(f.wetterstation_messwert)::numeric, 2) AS durchschnittlicher_messwert
FROM reporting.wetter_und_fahrradnutzung f
LEFT JOIN reporting.wetter_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
LEFT JOIN reporting.wetter_und_fahrradnutzung_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.wetter_und_fahrradnutzung_datum d
    ON d.datum_key = f.datum_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit, s.sensor_messzeitpunkt))
  AND st.fahrt_station_startstation_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring});

-- 2) Fahrradfahrten im Zeitverlauf (Zeitreihe)
SELECT
    $__timeGroupAlias(f.fahrradstation_startzeit, '1d'),
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.wetter_und_fahrradnutzung f
LEFT JOIN reporting.wetter_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
LEFT JOIN reporting.wetter_und_fahrradnutzung_sensor s
    ON s.sensor_key = f.sensor_key
WHERE f.fahrradstation_startzeit IS NOT NULL
  AND $__timeFilter(f.fahrradstation_startzeit)
  AND st.fahrt_station_startstation_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
GROUP BY 1
ORDER BY 1;

-- 3) Fahrradfahrten nach Start-Stadtteil (Slice/Dice)
SELECT
    st.fahrt_station_startstation_stadtteil AS stadtteil,
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.wetter_und_fahrradnutzung f
JOIN reporting.wetter_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
LEFT JOIN reporting.wetter_und_fahrradnutzung_sensor s
    ON s.sensor_key = f.sensor_key
WHERE st.fahrt_station_startstation_stadtteil IS NOT NULL
  AND $__timeFilter(COALESCE(f.fahrradstation_startzeit, s.sensor_messzeitpunkt))
  AND st.fahrt_station_startstation_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
GROUP BY 1
ORDER BY 2 DESC;

-- 4) Messwert und Fahrten nach Sensortyp/Einheit
-- Messwerte werden hier auf den mit der Fahrt verknüpften Datensätzen ausgewertet.
SELECT
    s.sensor_sensortyp,
    f.wetterstation_einheit,
    ROUND(AVG(f.wetterstation_messwert)::numeric, 2) AS durchschnittlicher_messwert,
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.wetter_und_fahrradnutzung f
LEFT JOIN reporting.wetter_und_fahrradnutzung_sensor s
    ON s.sensor_key = f.sensor_key
LEFT JOIN reporting.wetter_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
WHERE f.wetterstation_messwert IS NOT NULL
  AND st.fahrt_station_startstation_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
GROUP BY s.sensor_sensortyp, f.wetterstation_einheit
ORDER BY 1, 2;

-- 5) Pivot-Grundlage: Stadtteil als Zeile, Sensortyp als Spalte
-- In Grafana mit "Grouping to matrix" konfigurieren:
-- Row = stadtteil, Column = sensortyp, Cell = anzahl_fahrten.
SELECT
    st.fahrt_station_startstation_stadtteil AS stadtteil,
    COALESCE(s.sensor_sensortyp, 'Unbekannt') AS sensortyp,
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.wetter_und_fahrradnutzung f
JOIN reporting.wetter_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
LEFT JOIN reporting.wetter_und_fahrradnutzung_sensor s
    ON s.sensor_key = f.sensor_key
WHERE st.fahrt_station_startstation_stadtteil IS NOT NULL
  AND $__timeFilter(COALESCE(f.fahrradstation_startzeit, s.sensor_messzeitpunkt))
  AND st.fahrt_station_startstation_stadtteil IN (${stadtteil:sqlstring})
GROUP BY 1, 2
ORDER BY 1, 2;

-- 6) Detailtabelle
SELECT
    f.core_id,
    f.fahrradstation_startzeit,
    f.fahrradstation_endzeit,
    st.fahrt_station_startstation_stadtteil AS start_stadtteil,
    st.fahrt_station_endstation_stadtteil AS ziel_stadtteil,
    s.sensor_sensortyp,
    f.wetterstation_einheit,
    f.wetterstation_messwert
FROM reporting.wetter_und_fahrradnutzung f
LEFT JOIN reporting.wetter_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
LEFT JOIN reporting.wetter_und_fahrradnutzung_sensor s
    ON s.sensor_key = f.sensor_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit, s.sensor_messzeitpunkt))
  AND st.fahrt_station_startstation_stadtteil IN (${stadtteil:sqlstring})
  AND s.sensor_sensortyp IN (${sensortyp:sqlstring})
ORDER BY f.fahrradstation_startzeit DESC NULLS LAST
LIMIT 500;
