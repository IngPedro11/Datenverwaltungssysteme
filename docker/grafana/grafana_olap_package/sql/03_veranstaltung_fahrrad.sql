-- 1) Kennzahlen
SELECT
    COUNT(DISTINCT f.veranstaltung_key) AS anzahl_veranstaltungen,
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.veranstaltungen_und_fahrradnutzung f
LEFT JOIN reporting.veranstaltungen_und_fahrradnutzung_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
LEFT JOIN reporting.veranstaltungen_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit,
                              f.veranstaltung_beginn_tatsaechlich,
                              f.veranstaltung_beginn_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring});

-- 2) Fahrradfahrten im Zeitverlauf
SELECT
    $__timeGroupAlias(f.fahrradstation_startzeit, '1h'),
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.veranstaltungen_und_fahrradnutzung f
LEFT JOIN reporting.veranstaltungen_und_fahrradnutzung_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
LEFT JOIN reporting.veranstaltungen_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
WHERE f.fahrradstation_startzeit IS NOT NULL
  AND $__timeFilter(f.fahrradstation_startzeit)
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
GROUP BY 1
ORDER BY 1;

-- 3) Fahrradnutzung nach Veranstaltungstyp
SELECT
    v.veranstaltung_veranstaltungstyp AS veranstaltungstyp,
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.veranstaltungen_und_fahrradnutzung f
JOIN reporting.veranstaltungen_und_fahrradnutzung_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
LEFT JOIN reporting.veranstaltungen_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit,
                              f.veranstaltung_beginn_tatsaechlich,
                              f.veranstaltung_beginn_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
GROUP BY 1
ORDER BY 2 DESC;

-- 4) Fahrradfahrten nach Veranstaltungsort
SELECT
    v.veranstaltung_veranstaltungsort_name AS veranstaltungsort,
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.veranstaltungen_und_fahrradnutzung f
JOIN reporting.veranstaltungen_und_fahrradnutzung_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit,
                              f.veranstaltung_beginn_tatsaechlich,
                              f.veranstaltung_beginn_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
GROUP BY 1
ORDER BY 2 DESC;

-- 5) Räumliche Nähe: Distanz zwischen Veranstaltungsort und Startstation
-- Die Abfrage liefert Fahrten mit Entfernung in km; im Dashboard
-- optional auf einen Radius (z.B. 2 km) filtern.
SELECT
    v.veranstaltung_name,
    v.veranstaltung_veranstaltungsort_name,
    st.fahrt_station_startstation_stadtteil AS stadtteil,
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten,
    ROUND((
        6371 * ACOS(LEAST(1.0, GREATEST(-1.0,
            COS(RADIANS(v.veranstaltung_latitude::double precision))
            * COS(RADIANS(st.fahrt_station_startstation_latitude::double precision))
            * COS(RADIANS(
                st.fahrt_station_startstation_longitude::double precision
                - v.veranstaltung_longitude::double precision
            ))
            + SIN(RADIANS(v.veranstaltung_latitude::double precision))
            * SIN(RADIANS(st.fahrt_station_startstation_latitude::double precision))
        )))
    )::numeric, 2) AS entfernung_km
FROM reporting.veranstaltungen_und_fahrradnutzung f
JOIN reporting.veranstaltungen_und_fahrradnutzung_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
JOIN reporting.veranstaltungen_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
WHERE v.veranstaltung_latitude IS NOT NULL
  AND v.veranstaltung_longitude IS NOT NULL
  AND st.fahrt_station_startstation_latitude IS NOT NULL
  AND st.fahrt_station_startstation_longitude IS NOT NULL
  AND $__timeFilter(COALESCE(f.fahrradstation_startzeit,
                              f.veranstaltung_beginn_tatsaechlich,
                              f.veranstaltung_beginn_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
GROUP BY
    v.veranstaltung_name,
    v.veranstaltung_veranstaltungsort_name,
    st.fahrt_station_startstation_stadtteil,
    v.veranstaltung_latitude,
    v.veranstaltung_longitude,
    st.fahrt_station_startstation_latitude,
    st.fahrt_station_startstation_longitude
ORDER BY entfernung_km;

-- 6) Pivot-Grundlage: Veranstaltungstyp x Start-Stadtteil
-- Grafana Grouping to matrix: Row=veranstaltungstyp,
-- Column=stadtteil, Cell=anzahl_fahrten.
SELECT
    v.veranstaltung_veranstaltungstyp AS veranstaltungstyp,
    st.fahrt_station_startstation_stadtteil AS stadtteil,
    COUNT(DISTINCT f.fahrt_key) AS anzahl_fahrten
FROM reporting.veranstaltungen_und_fahrradnutzung f
JOIN reporting.veranstaltungen_und_fahrradnutzung_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
JOIN reporting.veranstaltungen_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit,
                              f.veranstaltung_beginn_tatsaechlich,
                              f.veranstaltung_beginn_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND st.fahrt_station_startstation_stadtteil IN (${stadtteil:sqlstring})
GROUP BY 1, 2
ORDER BY 1, 2;

-- 7) Detailtabelle
SELECT
    v.veranstaltung_name,
    v.veranstaltung_veranstaltungstyp,
    v.veranstaltung_veranstaltungsort_name,
    v.veranstaltung_stadtteil,
    f.fahrradstation_startzeit,
    f.fahrradstation_endzeit,
    st.fahrt_station_startstation_stadtteil,
    st.fahrt_station_endstation_stadtteil,
    f.fahrradstation_startstation_name,
    f.fahrradstation_endstation_name
FROM reporting.veranstaltungen_und_fahrradnutzung f
LEFT JOIN reporting.veranstaltungen_und_fahrradnutzung_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
LEFT JOIN reporting.veranstaltungen_und_fahrradnutzung_fahradstation st
    ON st.fahrt_key = f.fahrt_key
WHERE $__timeFilter(COALESCE(f.fahrradstation_startzeit,
                              f.veranstaltung_beginn_tatsaechlich,
                              f.veranstaltung_beginn_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
ORDER BY f.fahrradstation_startzeit DESC NULLS LAST
LIMIT 500;
