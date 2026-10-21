#!/usr/bin/env bash
set -e

# Grafana-Konfiguration für die lokale Testumgebung
GRAFANA_URL="http://localhost:3000"
GRAFANA_TOKEN="glsa_ieAyP0amlREgguPWwOMuHD93dTzj9ahv_f0bc1bca"

DASHBOARD_UID="smart-city-wetter-fahrrad"

# ------------------------------------------------------------
# Dashboard-JSON erzeugen
# SQL-Abfragen absichtlich OHNE Dashboard-Variablen,
# damit keine __all-/All-Interpolationsfehler auftreten.
# ------------------------------------------------------------
cat > dashboard.json <<'JSON'
{
  "dashboard": {
    "id": null,
    "uid": "smart-city-wetter-fahrrad",
    "title": "Smart City Analytics – Wetter und Fahrradnutzung",
    "tags": ["Smart City", "Wetter", "Fahrrad"],
    "timezone": "browser",
    "schemaVersion": 41,
    "version": 0,
    "refresh": "5m",
    "time": {
      "from": "now-30d",
      "to": "now"
    },
    "panels": [
      {
        "id": 1,
        "title": "Verknüpfte Datensätze",
        "type": "stat",
        "datasource": {
          "type": "grafana-postgresql-datasource",
          "uid": "fg1oka4v27dvkd"
        },
        "gridPos": {"h": 5, "w": 8, "x": 0, "y": 0},
        "fieldConfig": {
          "defaults": {"decimals": 0},
          "overrides": []
        },
        "options": {
          "reduceOptions": {"calcs": ["lastNotNull"], "fields": "", "values": false},
          "orientation": "auto",
          "textMode": "auto",
          "colorMode": "value",
          "graphMode": "area",
          "justifyMode": "auto"
        },
        "targets": [
          {
            "refId": "A",
            "format": "table",
            "rawSql": "SELECT COUNT(DISTINCT core_id) AS verknuepfte_datensaetze FROM reporting.wetter_und_fahrradnutzung;"
          }
        ]
      },
      {
        "id": 2,
        "title": "Anzahl Fahrradstationen",
        "type": "stat",
        "datasource": {
          "type": "grafana-postgresql-datasource",
          "uid": "fg1oka4v27dvkd"
        },
        "gridPos": {"h": 5, "w": 8, "x": 8, "y": 0},
        "fieldConfig": {
          "defaults": {"decimals": 0},
          "overrides": []
        },
        "options": {
          "reduceOptions": {"calcs": ["lastNotNull"], "fields": "", "values": false},
          "orientation": "auto",
          "textMode": "auto",
          "colorMode": "value",
          "graphMode": "area",
          "justifyMode": "auto"
        },
        "targets": [
          {
            "refId": "A",
            "format": "table",
            "rawSql": "SELECT COUNT(DISTINCT fahrradstation_name) AS anzahl_fahrradstationen FROM reporting.wetter_und_fahrradnutzung;"
          }
        ]
      },
      {
        "id": 3,
        "title": "Durchschnittlicher Wetter-Messwert",
        "type": "stat",
        "datasource": {
          "type": "grafana-postgresql-datasource",
          "uid": "fg1oka4v27dvkd"
        },
        "gridPos": {"h": 5, "w": 8, "x": 16, "y": 0},
        "fieldConfig": {
          "defaults": {"decimals": 2},
          "overrides": []
        },
        "options": {
          "reduceOptions": {"calcs": ["lastNotNull"], "fields": "", "values": false},
          "orientation": "auto",
          "textMode": "auto",
          "colorMode": "value",
          "graphMode": "area",
          "justifyMode": "auto"
        },
        "targets": [
          {
            "refId": "A",
            "format": "table",
            "rawSql": "SELECT ROUND(AVG(wetterstation_messwert)::numeric, 2) AS durchschnittlicher_messwert FROM reporting.wetter_und_fahrradnutzung;"
          }
        ]
      },
      {
        "id": 4,
        "title": "Wetterverlauf im Zeitverlauf",
        "type": "timeseries",
        "datasource": {
          "type": "grafana-postgresql-datasource",
          "uid": "fg1oka4v27dvkd"
        },
        "gridPos": {"h": 9, "w": 12, "x": 0, "y": 5},
        "fieldConfig": {
          "defaults": {
            "custom": {
              "drawStyle": "line",
              "lineInterpolation": "smooth",
              "lineWidth": 2,
              "fillOpacity": 15,
              "showPoints": "auto",
              "spanNulls": false
            }
          },
          "overrides": []
        },
        "options": {
          "legend": {"displayMode": "list", "placement": "bottom"},
          "tooltip": {"mode": "single", "sort": "none"}
        },
        "targets": [
          {
            "refId": "A",
            "format": "time_series",
            "rawSql": "SELECT $__timeGroupAlias(wetterstation_messzeitpunkt, '1h'), AVG(wetterstation_messwert) AS durchschnittlicher_messwert FROM reporting.wetter_und_fahrradnutzung WHERE $__timeFilter(wetterstation_messzeitpunkt) GROUP BY 1 ORDER BY 1;"
          }
        ]
      },
      {
        "id": 5,
        "title": "Verknüpfte Datensätze nach Stadtteil",
        "type": "barchart",
        "datasource": {
          "type": "grafana-postgresql-datasource",
          "uid": "fg1oka4v27dvkd"
        },
        "gridPos": {"h": 9, "w": 12, "x": 12, "y": 5},
        "fieldConfig": {
          "defaults": {
            "custom": {
              "axisLabel": "Datensätze",
              "axisPlacement": "auto",
              "fillOpacity": 80,
              "gradientMode": "none",
              "lineWidth": 1
            }
          },
          "overrides": []
        },
        "options": {
          "orientation": "horizontal",
          "xTickLabelRotation": 0,
          "xTickLabelSpacing": 0,
          "showValue": "auto",
          "stacking": "none",
          "legend": {"showLegend": false}
        },
        "targets": [
          {
            "refId": "A",
            "format": "table",
            "rawSql": "SELECT fahrradstation_stadtteil AS stadtteil, COUNT(DISTINCT core_id) AS anzahl_datensaetze FROM reporting.wetter_und_fahrradnutzung WHERE fahrradstation_stadtteil IS NOT NULL GROUP BY fahrradstation_stadtteil ORDER BY anzahl_datensaetze DESC;"
          }
        ]
      },
      {
        "id": 6,
        "title": "Details: Fahrradstationen und Wetter",
        "type": "table",
        "datasource": {
          "type": "grafana-postgresql-datasource",
          "uid": "fg1oka4v27dvkd"
        },
        "gridPos": {"h": 10, "w": 24, "x": 0, "y": 14},
        "options": {
          "showHeader": true,
          "cellHeight": "sm",
          "footer": {"show": false}
        },
        "targets": [
          {
            "refId": "A",
            "format": "table",
            "rawSql": "SELECT core_id, fahrradstation_name, fahrradstation_stadtteil, fahrradstation_startzeit, wetterstation_sensortyp, wetterstation_messzeitpunkt, wetterstation_messwert FROM reporting.wetter_und_fahrradnutzung ORDER BY fahrradstation_startzeit DESC NULLS LAST LIMIT 500;"
          }
        ]
      }
    ]
  },
  "overwrite": true,
  "folderId": 0,
  "message": "Stabiles Dashboard ohne Variablenfilter importiert"
}
JSON

echo "Importiere Dashboard nach Grafana unter ${GRAFANA_URL} ..."

curl --fail-with-body --silent --show-error \
  -H "Authorization: Bearer $GRAFANA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  "${GRAFANA_URL}/api/dashboards/db" \
  --data-binary @dashboard.json

echo
echo
echo "Dashboard wurde importiert."
echo "URL: ${GRAFANA_URL}/d/${DASHBOARD_UID}"