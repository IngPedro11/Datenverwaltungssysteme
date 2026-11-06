#!/usr/bin/env bash
set -Eeuo pipefail

# Smart City: fünf getrennte, OLAP-orientierte Grafana-Dashboards
# Voraussetzungen: bash, curl, python3, Grafana PostgreSQL-Datasource
# Aufruf: chmod +x create_dashboards.sh && ./create_dashboards.sh

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
GRAFANA_TOKEN="glsa_ieAyP0amlREgguPWwOMuHD93dTzj9ahv_f0bc1bca"
GRAFANA_USER="${GRAFANA_USER:-admin}"
GRAFANA_PASSWORD="${GRAFANA_PASSWORD:-admin}"
DATASOURCE_UID="${DATASOURCE_UID:-fg1oka4v27dvkd}"
SQL_DIR="${SQL_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sql}"
OUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dashboards"
mkdir -p "$OUT_DIR"

for f in 01_wetter_fahrrad.sql 02_veranstaltung_oepnv.sql 03_veranstaltung_fahrrad.sql 04_wetter_oepnv.sql 05_luftqualitaet_mobilitaet.sql; do
  [[ -s "$SQL_DIR/$f" ]] || { echo "FEHLER: SQL-Datei fehlt oder leer: $SQL_DIR/$f" >&2; exit 1; }
done
command -v python3 >/dev/null || { echo 'FEHLER: Python 3 fehlt.' >&2; exit 1; }
command -v curl >/dev/null || { echo 'FEHLER: curl fehlt.' >&2; exit 1; }

export SQL_DIR OUT_DIR DATASOURCE_UID
python3 <<'PY'
import os, re, json
from pathlib import Path

sql_dir, out_dir = Path(os.environ['SQL_DIR']), Path(os.environ['OUT_DIR'])
ds = os.environ['DATASOURCE_UID']
configs = [
 {'file':'01_wetter_fahrrad.sql','uid':'sc-wetter-fahrrad','title':'01 – Wetter und Fahrradnutzung','desc':'Einfluss von Wetterbedingungen auf die Nutzung des Fahrradverleihsystems.','vars':['stadtteil','sensortyp']},
 {'file':'02_veranstaltung_oepnv.sql','uid':'sc-veranstaltung-oepnv','title':'02 – Veranstaltungen und ÖPNV','desc':'Veränderung des Fahrgastaufkommens während und im Umfeld von Veranstaltungen.','vars':['veranstaltungstyp','stadtteil','verkehrsmittel']},
 {'file':'03_veranstaltung_fahrrad.sql','uid':'sc-veranstaltung-fahrrad','title':'03 – Veranstaltungen und Fahrradnutzung','desc':'Nutzung von Fahrradverleihstationen im Umfeld von Veranstaltungen.','vars':['veranstaltungstyp','stadtteil']},
 {'file':'04_wetter_oepnv.sql','uid':'sc-wetter-oepnv','title':'04 – Wetter und ÖPNV','desc':'Zusammenhang zwischen Wetterbedingungen und Fahrgastaufkommen.','vars':['sensortyp','verkehrsmittel','stadtteil']},
 {'file':'05_luftqualitaet_mobilitaet.sql','uid':'sc-luftqualitaet-mobilitaet','title':'05 – Luftqualität und Mobilität','desc':'Zusammenhang zwischen gemessener Luftqualität und Mobilitätsaufkommen.','vars':['stadtteil','sensortyp','verkehrsmittel']},
]
# Je Dashboard eigene, zur jeweiligen Reporting-Faktentabelle passende Variablen.
var_sql = {
 '01_wetter_fahrrad': {
  'stadtteil':('reporting.wetter_und_fahrradnutzung_fahradstation','fahrt_station_startstation_stadtteil'),
  'sensortyp':('reporting.wetter_und_fahrradnutzung_sensor','sensor_sensortyp')},
 '02_veranstaltung_oepnv': {
  'veranstaltungstyp':('reporting.veranstaltungen_und_oepnv_versanstaltung','veranstaltung_veranstaltungstyp'),
  'stadtteil':('reporting.veranstaltungen_und_oepnv_versanstaltung','veranstaltung_stadtteil'),
  'verkehrsmittel':('reporting.veranstaltungen_und_oepnv_linie','linie_verkehrsmittel')},
 '03_veranstaltung_fahrrad': {
  'veranstaltungstyp':('reporting.veranstaltungen_und_fahrradnutzung_versanstaltung','veranstaltung_veranstaltungstyp'),
  'stadtteil':('reporting.veranstaltungen_und_fahrradnutzung_versanstaltung','veranstaltung_stadtteil')},
 '04_wetter_oepnv': {
  'sensortyp':('reporting.wetter_und_oepnv_sensor','sensor_sensortyp'),
  'verkehrsmittel':('reporting.wetter_und_oepnv_linie','linie_verkehrsmittel'),
  'stadtteil':('reporting.wetter_und_oepnv_linie','linie_haltestelle_stadtteil')},
 '05_luftqualitaet_mobilitaet': {
  'stadtteil':('reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor','sensor_stadtteil'),
  'sensortyp':('reporting.luftqualitaet_und_mobilitaetsaufkommen_sensor','sensor_sensortyp'),
  'verkehrsmittel':('reporting.luftqualitaet_und_mobilitaetsaufkommen_linie','linie_verkehrsmittel')},
}

def split_queries(text):
    # SQL-Dateien markieren jeden eigenständigen Panel-Queryblock mit -- N) Titel.
    chunks = re.split(r'^--\s*(\d+)\)\s*(.*?)\s*$', text, flags=re.M)
    result=[]
    for i in range(1,len(chunks),3):
        num,title,body=chunks[i],chunks[i+1],chunks[i+2]
        body=re.sub(r'^--.*$', '', body, flags=re.M).strip()
        body=body.rstrip().rstrip(';').strip()
        if body:
            result.append((int(num),title,body))
    return result

def variable(name, table, col):
    q=f'SELECT DISTINCT {col} AS "__text", {col} AS "__value" FROM {table} WHERE {col} IS NOT NULL ORDER BY 1'
    return {'name':name,'label':name.replace('_',' ').title(),'type':'query','datasource':{'type':'postgres','uid':ds},
      'definition':q,'query':q,'refresh':1,'sort':1,'multi':True,'includeAll':True,'allValue':'',
      'current':{'selected':True,'text':['All'],'value':['$__all']},'options':[],'hide':0,
      'skipUrlSync':False,'regex':'','allowCustomValue':False}

for cfg in configs:
    key=cfg['file'].replace('.sql','')
    raw=(sql_dir/cfg['file']).read_text(encoding='utf-8')
    blocks=split_queries(raw)
    if not blocks: raise SystemExit(f"Keine Query-Blöcke in {cfg['file']} gefunden")
    panels=[]
    y=0
    for num,title,query in blocks:
        low=title.lower()
        if num==1:
            ptype='stat'; fmt='table'; w,h,x=24,5,0
        elif 'zeitverlauf' in low or 'zeitreihe' in low:
            ptype='timeseries'; fmt='time_series'; w,h,x=24,9,0
        elif 'pivot-grundlage' in low:
            ptype='table'; fmt='table'; w,h,x=12,9,0
        elif 'detailtabelle' in low:
            ptype='table'; fmt='table'; w,h,x=24,9,0
        elif 'streudiagramm' in low:
            # Tabellenformat bleibt bewusst kompatibel; Scatter-Panel kann nach Prüfung
            # der Feldtypen in Grafana auf XY chart umgestellt werden.
            ptype='table'; fmt='table'; w,h,x=12,8,0
        else:
            ptype='barchart'; fmt='table'; w,h,x=12,8,0
        transformations=[]
        if 'pivot-grundlage' in low:
            # Grafana Grouping to matrix: Felder werden anhand der Aliase der SQL-Grundlage
            # als Zeile/Spalte/Wert zugeordnet. Options bleiben als Anleitung leer,
            # da Feldnamen pro Forschungsfrage verschieden sind.
            pivot_fields = {
                '01_wetter_fahrrad': ('stadtteil','sensortyp','anzahl_fahrten'),
                '02_veranstaltung_oepnv': ('veranstaltungstyp','verkehrsmittel','einsteiger'),
                '03_veranstaltung_fahrrad': ('veranstaltungstyp','stadtteil','anzahl_fahrten'),
                '04_wetter_oepnv': ('verkehrsmittel','sensortyp','einsteiger'),
                '05_luftqualitaet_mobilitaet': ('stadtteil','mobilitaetsart','anzahl'),
            }
            row_field, col_field, value_field = pivot_fields[key]
            transformations=[{'id':'groupingToMatrix','options':{
                'rowField':row_field,'columnField':col_field,'valueField':value_field
            }}]
        panel={'id':len(panels)+1,'title':f'{num}. {title}','description':title,
          'type':ptype,'datasource':{'type':'postgres','uid':ds},
          'gridPos':{'h':h,'w':w,'x':x,'y':y},
          'targets':[{'refId':'A','format':fmt,'rawSql':query,'datasource':{'type':'postgres','uid':ds},'editorMode':'code'}],
          'fieldConfig':{'defaults':{'custom':{'align':'auto','cellOptions':{'type':'auto'},'inspect':False},'mappings':[]},'overrides':[]},
          'options':{'xTickLabelRotation': 45},'transformations':transformations,'transparent':False}
        panels.append(panel)
        if w==12:
            # Folgepanel in derselben Reihe rechts platzieren, falls links belegt.
            if x==0: x=12
            else: y+=h; x=0
        else:
            y+=h; x=0
    templ=[]
    for name in cfg['vars']:
        table,col=var_sql[key][name]
        templ.append(variable(name,table,col))
    dashboard={'uid':cfg['uid'],'title':cfg['title'],'description':cfg['desc'],
      'tags':['Smart City','OLAP','PostgreSQL'], 'timezone':'browser','schemaVersion':39,'version':0,
      'refresh':'5m','editable':True,'graphTooltip':1,'panels':panels,
      'templating':{'list':templ},'time':{'from':'2026-01-01T00:00:00.000Z','to':'2026-12-31T23:59:59.999Z'},
      'timepicker':{'refresh_intervals':['30s','1m','5m','15m','30m','1h'],'time_options':['6h','12h','24h','7d','30d','90d','1y']},
      'annotations':{'list':[{'builtIn':1,'datasource':{'type':'grafana','uid':'-- Grafana --'},'enable':True,'hide':True,'iconColor':'rgba(0,211,255,1)','name':'Annotations & Alerts','type':'dashboard'}]}}
    payload={'dashboard':dashboard,'overwrite':True,'message':'Smart City OLAP Dashboard automatisch erstellt'}
    (out_dir/f'{key}.json').write_text(json.dumps(payload,ensure_ascii=False,indent=2),encoding='utf-8')
    print(f"Erstellt: {cfg['uid']} ({len(panels)} Panels, {len(templ)} Variablen)")
PY

# API-Authentifizierung
AUTH_ARGS=()
if [[ -n "$GRAFANA_TOKEN" ]]; then AUTH_ARGS=(-H "Authorization: Bearer $GRAFANA_TOKEN"); else AUTH_ARGS=(-u "$GRAFANA_USER:$GRAFANA_PASSWORD"); fi

shopt -s nullglob
files=("$OUT_DIR"/*.json)
((${#files[@]} == 5)) || { echo 'FEHLER: Es wurden nicht genau fünf Dashboard-Dateien erzeugt.' >&2; exit 1; }
for file in "${files[@]}"; do
  echo "Importiere $(basename "$file") ..."
  tmp=$(mktemp)
  code=$(curl -sS -o "$tmp" -w '%{http_code}' -X POST "$GRAFANA_URL/api/dashboards/db" \
    -H "Authorization: Bearer $GRAFANA_TOKEN" -H 'Content-Type: application/json' --data-binary "@$file") || { cat "$tmp"; rm -f "$tmp"; exit 1; }
  if [[ "$code" =~ ^2 ]]; then
    python3 - "$tmp" <<'PY'
import json,sys
try:
 d=json.load(open(sys.argv[1])); print('  OK:',d.get('url',d.get('status','importiert')))
except Exception: print('  OK')
PY
  else
    echo "  FEHLER HTTP $code"; cat "$tmp"; rm -f "$tmp"; exit 1
  fi
  rm -f "$tmp"
done

echo
echo 'Alle fünf Dashboards wurden an Grafana übergeben.'
echo "Öffne Grafana: $GRAFANA_URL"
