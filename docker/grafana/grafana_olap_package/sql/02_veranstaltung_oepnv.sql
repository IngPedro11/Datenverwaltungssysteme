-- 1) Kennzahlen: Veranstaltungen, Einsteiger und Aussteiger
SELECT
    COUNT(DISTINCT f.veranstaltung_key) AS anzahl_veranstaltungen,
    COALESCE(SUM(f.linie_einsteiger), 0) AS einsteiger,
    COALESCE(SUM(f.linie_aussteiger), 0) AS aussteiger
FROM reporting.veranstaltungen_und_oepnv f
LEFT JOIN reporting.veranstaltungen_und_oepnv_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
LEFT JOIN reporting.veranstaltungen_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE $__timeFilter(COALESCE(f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring});

-- 2) Ein- und Aussteiger im Zeitverlauf
SELECT
    $__timeGroupAlias(d.zeitpunkt, '1h'),
    SUM(d.einsteiger) AS einsteiger,
    SUM(d.aussteiger) AS aussteiger
FROM (
    SELECT
        COALESCE(
            f.linie_ankunft_tatsaechlich,
            f.linie_ankunft_geplant,
            f.linie_abfahrt_tatsaechlich,
            f.linier_abfahrt_geplant
        ) AS zeitpunkt,
        f.linie_einsteiger AS einsteiger,
        f.linie_aussteiger AS aussteiger,
        f.veranstaltung_key,
        f.linie_key
    FROM reporting.veranstaltungen_und_oepnv f
) d
LEFT JOIN reporting.veranstaltungen_und_oepnv_versanstaltung v
    ON v.veranstaltung_key = d.veranstaltung_key
LEFT JOIN reporting.veranstaltungen_und_oepnv_linie l
    ON l.linie_key = d.linie_key
WHERE $__timeFilter(d.zeitpunkt)
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
GROUP BY 1
ORDER BY 1;

-- 3) Fahrgastaufkommen nach Veranstaltungstyp
SELECT
    v.veranstaltung_veranstaltungstyp AS veranstaltungstyp,
    SUM(f.linie_einsteiger) AS einsteiger,
    SUM(f.linie_aussteiger) AS aussteiger
FROM reporting.veranstaltungen_und_oepnv f
JOIN reporting.veranstaltungen_und_oepnv_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
LEFT JOIN reporting.veranstaltungen_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE $__timeFilter(COALESCE(f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
GROUP BY 1
ORDER BY 2 DESC;

-- 4) Fahrgastaufkommen nach Verkehrsmittel und Haltestelle
SELECT
    l.linie_verkehrsmittel AS verkehrsmittel,
    COALESCE(l.linie_haltestelle_name, f.linie_haltestelle_name) AS haltestelle,
    SUM(f.linie_einsteiger) AS einsteiger,
    SUM(f.linie_aussteiger) AS aussteiger
FROM reporting.veranstaltungen_und_oepnv f
LEFT JOIN reporting.veranstaltungen_und_oepnv_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
JOIN reporting.veranstaltungen_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE $__timeFilter(COALESCE(f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 5) Pivot-Grundlage: Veranstaltungstyp x Verkehrsmittel
-- Grafana Grouping to matrix: Row=veranstaltungstyp,
-- Column=verkehrsmittel, Cell=einsteiger.
SELECT
    v.veranstaltung_veranstaltungstyp AS veranstaltungstyp,
    l.linie_verkehrsmittel AS verkehrsmittel,
    SUM(f.linie_einsteiger) AS einsteiger
FROM reporting.veranstaltungen_und_oepnv f
JOIN reporting.veranstaltungen_und_oepnv_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
JOIN reporting.veranstaltungen_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE $__timeFilter(COALESCE(f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
GROUP BY 1, 2
ORDER BY 1, 2;

-- 6) Veranstaltungsphasen: Vorher / Während / Nachher
-- Zeitfenster hier beispielhaft: 2 Stunden vor/nach dem Veranstaltungszeitraum.
-- Klassifizierung anhand des ÖPNV-Ereigniszeitpunkts.
WITH basis AS (
    SELECT
        v.veranstaltung_name,
        v.veranstaltung_veranstaltungstyp,
        v.veranstaltung_stadtteil,

        COALESCE(
            f.linie_ankunft_tatsaechlich,
            f.linie_ankunft_geplant,
            f.linie_abfahrt_tatsaechlich,
            f.linier_abfahrt_geplant
        ) AS verkehrszeitpunkt,

        COALESCE(
            f.veranstaltung_beginn_tatsaechlich,
            f.veranstaltung_beginn_geplant
        ) AS beginn,

        COALESCE(
            f.veranstaltung_ende_tatsaechlich,
            f.veranstaltung_ende_geplant
        ) AS ende,

        f.linie_einsteiger,
        f.linie_aussteiger

    FROM reporting.veranstaltungen_und_oepnv f

    JOIN reporting.veranstaltungen_und_oepnv_versanstaltung v
        ON v.veranstaltung_key = f.veranstaltung_key

    WHERE COALESCE(
              f.linie_ankunft_tatsaechlich,
              f.linie_ankunft_geplant,
              f.linie_abfahrt_tatsaechlich,
              f.linier_abfahrt_geplant
          ) IS NOT NULL

      AND COALESCE(
              f.veranstaltung_beginn_tatsaechlich,
              f.veranstaltung_beginn_geplant
          ) IS NOT NULL

      AND COALESCE(
              f.veranstaltung_ende_tatsaechlich,
              f.veranstaltung_ende_geplant
          ) IS NOT NULL

      AND $__timeFilter(
          COALESCE(
              f.linie_ankunft_tatsaechlich,
              f.linie_ankunft_geplant,
              f.linie_abfahrt_tatsaechlich,
              f.linier_abfahrt_geplant
          )
      )

      AND v.veranstaltung_veranstaltungstyp
          IN (${veranstaltungstyp:sqlstring})

      AND v.veranstaltung_stadtteil
          IN (${stadtteil:sqlstring})
)

SELECT
    veranstaltung_name,

    CASE
        WHEN verkehrszeitpunkt < beginn
         AND verkehrszeitpunkt >= beginn - INTERVAL '2 hours'
            THEN 'Vorher'

        WHEN verkehrszeitpunkt BETWEEN beginn AND ende
            THEN 'Während'

        WHEN verkehrszeitpunkt > ende
         AND verkehrszeitpunkt <= ende + INTERVAL '2 hours'
            THEN 'Nachher'

        ELSE 'Außerhalb'
    END AS veranstaltungsphase,

    SUM(linie_einsteiger) AS einsteiger,
    SUM(linie_aussteiger) AS aussteiger

FROM basis

GROUP BY
    veranstaltung_name,
    veranstaltungsphase

ORDER BY
    veranstaltung_name,
    veranstaltungsphase;

-- 7) Detailtabelle
SELECT
    v.veranstaltung_name,
    v.veranstaltung_veranstaltungstyp,
    v.veranstaltung_stadtteil,
    l.linie_verkehrsmittel,
    COALESCE(l.linie_haltestelle_name, f.linie_haltestelle_name) AS haltestelle,
    COALESCE(f.linie_ankunft_tatsaechlich, f.linie_ankunft_geplant) AS ankunft,
    COALESCE(f.linier_abfahrt_geplant, f.linie_abfahrt_tatsaechlich) AS abfahrt,
    f.linie_einsteiger,
    f.linie_aussteiger
FROM reporting.veranstaltungen_und_oepnv f
LEFT JOIN reporting.veranstaltungen_und_oepnv_versanstaltung v
    ON v.veranstaltung_key = f.veranstaltung_key
LEFT JOIN reporting.veranstaltungen_und_oepnv_linie l
    ON l.linie_key = f.linie_key
WHERE $__timeFilter(COALESCE(f.linie_ankunft_tatsaechlich,
                              f.linie_ankunft_geplant,
                              f.linie_abfahrt_tatsaechlich,
                              f.linier_abfahrt_geplant))
  AND v.veranstaltung_veranstaltungstyp IN (${veranstaltungstyp:sqlstring})
  AND v.veranstaltung_stadtteil IN (${stadtteil:sqlstring})
  AND l.linie_verkehrsmittel IN (${verkehrsmittel:sqlstring})
ORDER BY ankunft DESC NULLS LAST
LIMIT 500;
