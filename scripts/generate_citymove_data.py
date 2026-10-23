#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generador de datos sintéticos para el sistema CityMove (Dresden, Sajonia).

Pensado para un schema Postgres `citymove` con columnas
`GENERATED ALWAYS AS IDENTITY`: los IDs los genera Postgres solo. El script
vacía las tablas con `TRUNCATE ... RESTART IDENTITY CASCADE` y luego inserta
las filas en el mismo orden en que se generaron en Python (sin la columna id),
así los IDs de la IDENTITY coinciden con los que usamos para las FK.

Rellena las tablas: Modell, Fahrzeug, Linie, Haltestelle, Linien_Haltestelle,
Fahrt, Fahrplan, Fahrt_Haltestelle, Fahrgastaufkommen, Stoerung.

NOVEDADES
    - Fecha de inicio y de fin elegibles. El estado de la Fahrt depende de "ahora":
      fechas pasadas -> durchgeführt / ausgefallen, fechas futuras -> geplant.
    - Clima (módulo compartido dresden_weather.py, el mismo que AirSense,
      BikeShare y CityEvents): con lluvia, nieve o frío sube el número de
      pasajeros (más en Bus que en Straßenbahn), hay más retrasos y más
      Störungen "Wetterbedingt".
    - Eventos: si existen los CSV de CityEvents (cityevents_veranstaltungstermin.csv
      y cityevents_veranstaltungsort.csv en la misma carpeta):
        * suben los pasajeros que BAJAN en las paradas del barrio del evento
          antes del comienzo, y los que SUBEN después del final;
        * se añaden viajes de refuerzo (Verstärkerfahrten) de las líneas que
          pasan por ese barrio, hacia el evento y de vuelta;
        * más retrasos en esas paradas.
      Ejecutá primero generate_cityevents_data.py con las MISMAS fechas.

Solo usa la librería estándar (más dresden_weather.py en la misma carpeta).
Genera CSV (uno por tabla) + un script SQL listo para Postgres.
"""

import csv
import math
import os
import random
from collections import defaultdict
from datetime import datetime, timedelta, time

import dresden_weather as weather

# ---------------------------------------------------------------------------
# 1. STADTTEILE REALES DE DRESDEN CON BOUNDING BOX APROXIMADO (lat/lon)
# ---------------------------------------------------------------------------
STADTTEILE = {
    "Altstadt":          (51.045, 51.060, 13.725, 13.745),
    "Innere Neustadt":   (51.058, 51.068, 13.735, 13.755),
    "Äußere Neustadt":   (51.063, 51.075, 13.735, 13.758),
    "Pieschen":          (51.075, 51.090, 13.700, 13.730),
    "Trachau":           (51.085, 51.100, 13.700, 13.730),
    "Klotzsche":         (51.110, 51.135, 13.750, 13.800),
    "Loschwitz":         (51.055, 51.075, 13.790, 13.830),
    "Blasewitz":         (51.035, 51.055, 13.775, 13.810),
    "Striesen":          (51.030, 51.050, 13.760, 13.790),
    "Gruna":             (51.020, 51.035, 13.760, 13.790),
    "Seidnitz":          (51.020, 51.035, 13.790, 13.820),
    "Johannstadt":       (51.040, 51.055, 13.745, 13.770),
    "Südvorstadt":       (51.020, 51.040, 13.720, 13.745),
    "Plauen":            (51.010, 51.030, 13.700, 13.725),
    "Löbtau":            (51.035, 51.050, 13.680, 13.705),
    "Cotta":             (51.045, 51.065, 13.670, 13.700),
    "Leuben":            (51.005, 51.025, 13.800, 13.830),
    "Prohlis":           (50.995, 51.015, 13.780, 13.805),
    "Cossebaude":        (51.075, 51.095, 13.620, 13.660),
    "Weixdorf":          (51.130, 51.155, 13.800, 13.840),
}
STADTTEIL_NOMBRES = list(STADTTEILE.keys())

# ---------------------------------------------------------------------------
# 2. CATÁLOGOS
# ---------------------------------------------------------------------------
FAHRZEUG_HERSTELLER = ["Bombardier", "Siemens", "Alstom", "Mercedes-Benz",
                        "MAN", "Solaris", "Iveco"]
FAHRZEUGTYPEN = ["Straßenbahn", "Bus", "Gelenkbus", "Niederflurbus"]
STATUS_FAHRZEUG = ["aktiv", "aktiv", "aktiv", "wartung", "außer Betrieb"]

LINIENNUMMERN_TRAM = ["1", "2", "3", "4", "6", "7", "8", "9", "10", "11", "12", "13"]
LINIENNUMMERN_BUS = ["61", "62", "64", "70", "74", "75", "76", "80", "85", "86", "87", "90", "94", "97"]

FAHRTRICHTUNGEN = ["Hinfahrt", "Rückfahrt"]
STOERUNG_TYPEN = ["Verspätung", "Technischer Defekt", "Unfall", "Wetterbedingt", "Signalstörung"]

# Probabilidad de que una Fahrt pasada haya sido ausgefallen
P_AUSFALL_BASIS = 0.06
P_AUSFALL_REGEN = 0.02      # se suma con lluvia
P_AUSFALL_SCHNEE = 0.08     # se suma con nieve / helada

# Oferta (nº de viajes) y demanda base de pasajeros por hora del día (0-23)
PERFIL_LABORABLE = [0, 0, 0, 0, 0, 0.5, 1.0, 1.5, 1.5, 1.0, 0.8, 0.8, 0.9, 0.9, 0.9,
                    1.1, 1.5, 1.5, 1.2, 0.8, 0.6, 0.5, 0.4, 0.3]
PERFIL_FINDE = [0, 0, 0, 0, 0, 0.2, 0.3, 0.4, 0.6, 0.8, 0.9, 1.0, 1.0, 1.0, 1.0,
                1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2]

# Eventos (CSV de CityEvents)
CSV_TERMIN = "cityevents_veranstaltungstermin.csv"
CSV_ORT = "cityevents_veranstaltungsort.csv"
AFORO_ESTIMADO = 0.6          # % del aforo del recinto que se supone asiste
MAX_REFUERZO = 0.30           # como mucho 30 % de las Fahrten son refuerzos

# ---------------------------------------------------------------------------
# 3. HELPERS
# ---------------------------------------------------------------------------
coordenadas_usadas = set()


def coordenada_unica(stadtteil):
    lat_min, lat_max, lon_min, lon_max = STADTTEILE[stadtteil]
    for _ in range(200):
        lat = round(random.uniform(lat_min, lat_max), 6)
        lon = round(random.uniform(lon_min, lon_max), 6)
        if (lat, lon) not in coordenadas_usadas:
            coordenadas_usadas.add((lat, lon))
            return lat, lon
    raise RuntimeError(
        f"No se pudo generar una coordenada única para '{stadtteil}' tras 200 intentos."
    )


def sql_escape(valor):
    if valor is None:
        return "NULL"
    if isinstance(valor, bool):
        return "TRUE" if valor else "FALSE"
    if isinstance(valor, (int, float)):
        return str(valor)
    if isinstance(valor, datetime):
        return f"'{valor.strftime('%Y-%m-%d %H:%M:%S')}'"
    texto = str(valor).replace("'", "''")
    return f"'{texto}'"


def escribir_csv(nombre_archivo, columnas, filas):
    with open(nombre_archivo, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(columnas)
        writer.writerows(filas)
    print(f"  -> {nombre_archivo} ({len(filas)} filas)")


def escribir_sql(nombre_archivo, tabla, columnas, filas):
    """INSERT sin columna id: la asigna GENERATED ALWAYS AS IDENTITY."""
    columnas_sin_id = columnas[1:]
    with open(nombre_archivo, "a", encoding="utf-8") as f:
        f.write(f"\n-- {tabla} ({len(filas)} filas)\n")
        cols_sql = ", ".join(columnas_sin_id)
        for fila in filas:
            valores = ", ".join(sql_escape(v) for v in fila[1:])
            f.write(f"INSERT INTO citymove.{tabla} ({cols_sql}) VALUES ({valores});\n")


def escribir_truncate(nombre_archivo, tablas):
    tablas_qualificadas = ", ".join(f"citymove.{t}" for t in tablas)
    with open(nombre_archivo, "w", encoding="utf-8") as f:
        f.write("-- Vaciar tablas y reiniciar las IDENTITY antes de cargar los datos\n")
        f.write(f"TRUNCATE TABLE {tablas_qualificadas} RESTART IDENTITY CASCADE;\n")


def muestrear(media):
    """Nº de pasajeros ~ Poisson (aprox. normal), nunca negativo."""
    return max(0, round(random.gauss(media, math.sqrt(media) + 0.5)))


def cargar_eventos():
    """Lee los CSV de CityEvents. Devuelve lista de eventos (sin los abgesagt)."""
    if not (os.path.exists(CSV_TERMIN) and os.path.exists(CSV_ORT)):
        return []
    with open(CSV_ORT, encoding="utf-8") as f:
        orte = {int(r["id"]): r for r in csv.DictReader(f)}
    eventos = []
    with open(CSV_TERMIN, encoding="utf-8") as f:
        for r in csv.DictReader(f):
            ort = orte.get(int(r["id_veranstaltungsort"]))
            if r["status"] == "abgesagt" or ort is None:
                continue
            eventos.append({
                "stadtteil": ort["stadtteil"],
                "beginn": datetime.fromisoformat(r["beginn_tatsaechlich"] or r["beginn_geplant"]),
                "ende": datetime.fromisoformat(r["ende_tatsaechlich"] or r["ende_geplant"]),
                "asistentes": int(ort["kapazitaet"]) * AFORO_ESTIMADO,
            })
    return eventos


def evento_boost(stadtteil, ts, eventos_por_stadtteil):
    """(boost subidas, boost bajadas) en una parada de ese barrio en el instante ts.

    Antes del comienzo (90 min antes .. 15 min después) bajan más pasajeros
    (van al evento); tras el final (10 min antes .. 75 min después) suben más.
    """
    b_ein = b_aus = 1.0
    for ev in eventos_por_stadtteil.get(stadtteil, ()):
        fuerza = min(4.0, ev["asistentes"] / 200)
        if ev["beginn"] - timedelta(minutes=90) <= ts <= ev["beginn"] + timedelta(minutes=15):
            b_aus += fuerza
        if ev["ende"] - timedelta(minutes=10) <= ts <= ev["ende"] + timedelta(minutes=75):
            b_ein += fuerza
    return b_ein, b_aus


# ---------------------------------------------------------------------------
# 4. GENERACIÓN DE DATOS
# ---------------------------------------------------------------------------
def generar_datos(n_haltestellen, n_linien, n_modelle, n_fahrzeuge, n_fahrten,
                  start_date, end_date, eventos):
    start_dt = datetime.combine(start_date, time(0, 0, 0))
    end_dt = datetime.combine(end_date, time(23, 59, 59))
    ahora = datetime.now().replace(microsecond=0)
    weather.build_weather(end_date)
    stats = defaultdict(lambda: [0, 0])     # (modo, condición) -> [suma pasajeros, nº paradas]

    # --- Haltestelle ---
    haltestellen = []
    for i in range(1, n_haltestellen + 1):
        stadtteil = random.choice(STADTTEIL_NOMBRES)
        lat, lon = coordenada_unica(stadtteil)
        haltestellen.append((i, f"Haltestelle {stadtteil} {i}", stadtteil, lat, lon))
    stadtteil_de = {h[0]: h[2] for h in haltestellen}

    # --- Linie (+ secuencia de paradas por línea, sin repetir) ---
    linien = []
    ruta_por_linie = {}
    liniennummern_usadas = set()
    for i in range(1, n_linien + 1):
        verkehrsmittel = "Straßenbahn" if i <= n_linien // 2 else "Bus"
        pool = LINIENNUMMERN_TRAM if verkehrsmittel == "Straßenbahn" else LINIENNUMMERN_BUS
        candidatos = [n for n in pool if n not in liniennummern_usadas]
        liniennummer = random.choice(candidatos) if candidatos else str(100 + i)
        liniennummern_usadas.add(liniennummer)

        n_paradas = min(len(haltestellen), random.randint(6, 14))
        paradas = random.sample(range(1, n_haltestellen + 1), k=n_paradas)
        ruta_por_linie[i] = paradas

        origen = haltestellen[paradas[0] - 1][2]
        destino = haltestellen[paradas[-1] - 1][2]
        bezeichnung = f"Linie {liniennummer}: {origen} – {destino}"
        gueltig_ab = start_date - timedelta(days=900)
        linien.append((i, liniennummer, bezeichnung, verkehrsmittel, gueltig_ab, None))

    # --- Linien_Haltestelle (Hinfahrt + Rückfahrt) ---
    linien_haltestelle = []
    lh_id = 1
    for id_linie, paradas in ruta_por_linie.items():
        for idx, id_h in enumerate(paradas, start=1):
            linien_haltestelle.append((lh_id, id_linie, id_h, idx, "Hinfahrt"))
            lh_id += 1
        for idx, id_h in enumerate(reversed(paradas), start=1):
            linien_haltestelle.append((lh_id, id_linie, id_h, idx, "Rückfahrt"))
            lh_id += 1

    linien_por_stadtteil = defaultdict(list)
    for id_linie, paradas in ruta_por_linie.items():
        for st in {stadtteil_de[p] for p in paradas}:
            linien_por_stadtteil[st].append(id_linie)

    # --- Modell (vehículo) ---
    modelle = []
    for i in range(1, n_modelle + 1):
        hersteller = random.choice(FAHRZEUG_HERSTELLER)
        typ = random.choice(FAHRZEUGTYPEN)
        bezeichnung = f"{hersteller.split()[0]} {typ} {random.choice(['S', 'X', 'C'])}{random.randint(1,9)}"
        modelle.append((i, hersteller, bezeichnung, typ, random.randint(2005, 2026)))

    # --- Fahrzeug ---
    fahrzeuge = []
    for i in range(1, n_fahrzeuge + 1):
        id_modell, _, _, typ_modell, _ = random.choice(modelle)
        if typ_modell == "Straßenbahn":
            kapazitaet, antriebsart = random.randint(150, 220), "Strom"
        elif typ_modell == "Gelenkbus":
            kapazitaet, antriebsart = random.randint(100, 160), random.choice(["Diesel", "Hybrid", "Elektro"])
        else:
            kapazitaet, antriebsart = random.randint(60, 110), random.choice(["Diesel", "Hybrid", "Elektro"])
        inbetriebnahme = start_date - timedelta(days=random.randint(200, 2500))
        fahrzeuge.append((i, id_modell, f"CM-{i:04d}", kapazitaet, antriebsart,
                           inbetriebnahme, random.choice(STATUS_FAHRZEUG)))

    modell_typ = {m[0]: m[3] for m in modelle}
    kapazitaet_de = {f[0]: f[3] for f in fahrzeuge}
    aktiv = [f for f in fahrzeuge if f[6] == "aktiv"] or fahrzeuge
    fahrzeuge_tram = [f for f in aktiv if modell_typ[f[1]] == "Straßenbahn"] or aktiv
    fahrzeuge_bus = [f for f in aktiv if modell_typ[f[1]] != "Straßenbahn"] or aktiv

    # -----------------------------------------------------------------
    # Viajes: refuerzos por eventos + viajes base según la oferta horaria
    # -----------------------------------------------------------------
    def viaje_refuerzo(ev, tipo):
        id_linie = random.choice(linien_por_stadtteil[ev["stadtteil"]])
        paradas = ruta_por_linie[id_linie]
        opciones = []
        for richtung in FAHRTRICHTUNGEN:
            seq = paradas if richtung == "Hinfahrt" else paradas[::-1]
            for idx, h in enumerate(seq):
                if stadtteil_de[h] == ev["stadtteil"]:
                    opciones.append((richtung, idx))
                    break
        richtung, idx = random.choice(opciones)
        offset = timedelta(minutes=idx * 4)          # tiempo hasta llegar a esa parada
        if tipo == "llegada":
            t = ev["beginn"] - timedelta(minutes=random.randint(30, 90)) - offset
        else:
            t = ev["ende"] + timedelta(minutes=random.randint(-10, 50)) - offset
        return t.replace(second=0, microsecond=0), id_linie, richtung

    candidatos_refuerzo = []
    for ev in eventos:
        if ev["ende"] < start_dt or ev["beginn"] > end_dt or not linien_por_stadtteil.get(ev["stadtteil"]):
            continue
        for _ in range(min(8, max(1, round(ev["asistentes"] / 300)))):
            candidatos_refuerzo.append((ev, "llegada"))
            candidatos_refuerzo.append((ev, "salida"))
    max_ref = int(n_fahrten * MAX_REFUERZO)
    if len(candidatos_refuerzo) > max_ref:
        candidatos_refuerzo = random.sample(candidatos_refuerzo, max_ref)
    viajes = []
    for ev, tipo in candidatos_refuerzo:
        t, id_linie, richtung = viaje_refuerzo(ev, tipo)
        if start_dt <= t <= end_dt:
            viajes.append((t, id_linie, richtung))
    n_refuerzos = len(viajes)

    horas, pesos = [], []
    dia = start_date
    while dia <= end_date:
        perfil = PERFIL_FINDE if dia.weekday() >= 5 else PERFIL_LABORABLE
        for h in range(24):
            if perfil[h] > 0:
                horas.append(datetime.combine(dia, time(h)))
                pesos.append(perfil[h])
        dia += timedelta(days=1)
    n_base = max(0, n_fahrten - n_refuerzos)
    for h in random.choices(horas, weights=pesos, k=n_base):
        t = h.replace(minute=random.choice([0, 10, 15, 20, 30, 40, 45, 50]))
        viajes.append((t, random.randint(1, n_linien), random.choice(FAHRTRICHTUNGEN)))
    viajes.sort(key=lambda v: v[0])

    eventos_por_stadtteil = defaultdict(list)
    for ev in eventos:
        eventos_por_stadtteil[ev["stadtteil"]].append(ev)

    # --- Fahrt + Fahrplan + Fahrt_Haltestelle + Fahrgastaufkommen + Stoerung ---
    fahrten, fahrplan, fahrt_haltestelle, fahrgastaufkommen, stoerungen = [], [], [], [], []
    fahrplan_id = fh_id = fga_id = stoerung_id = 1

    for i, (hora_inicio, id_linie, fahrtrichtung) in enumerate(viajes, start=1):
        _, liniennummer, _, verkehrsmittel, _, _ = linien[id_linie - 1]
        es_bus = verkehrsmittel == "Bus"
        mode_share = 1.0 if es_bus else 0.7
        pool_fahrzeuge = fahrzeuge_bus if es_bus else fahrzeuge_tram
        id_fahrzeug = random.choice(pool_fahrzeuge)[0]

        precip = weather.precipitation_mm_h(hora_inicio)
        temp = weather.temperature(hora_inicio)
        if hora_inicio > ahora:
            status_fahrt = "geplant"
        else:
            p_aus = P_AUSFALL_BASIS
            if precip > 0:
                p_aus += P_AUSFALL_SCHNEE if temp < 1 else P_AUSFALL_REGEN
            status_fahrt = "ausgefallen" if random.random() < p_aus else "durchgeführt"
        fahrten.append((i, id_linie, id_fahrzeug, hora_inicio.date(), fahrtrichtung, status_fahrt))

        paradas = ruta_por_linie[id_linie]
        secuencia = paradas if fahrtrichtung == "Hinfahrt" else list(reversed(paradas))
        tiempo_actual = hora_inicio
        total_paradas = len(secuencia)

        for idx, id_haltestelle in enumerate(secuencia):
            if idx > 0:
                tiempo_actual += timedelta(minutes=random.randint(2, 6))
            ankunft_geplant = tiempo_actual
            dwell_min = 0 if idx in (0, total_paradas - 1) else random.choice([0, 1, 1, 2])
            abfahrt_geplant = ankunft_geplant + timedelta(minutes=dwell_min)
            tiempo_actual = abfahrt_geplant

            fahrplan.append((fahrplan_id, i, id_haltestelle, ankunft_geplant, abfahrt_geplant))
            fahrplan_id += 1
            if status_fahrt != "durchgeführt":
                continue

            ts = ankunft_geplant
            lluvia_parada = weather.precipitation_mm_h(ts) > 0
            ein_ev, aus_ev = evento_boost(stadtteil_de[id_haltestelle], ts, eventos_por_stadtteil)
            hay_evento = ein_ev > 1 or aus_ev > 1

            # Retrasos: más con lluvia/nieve y con mucha gente por un evento
            opciones = [0, 0, 1, 2, 3, 5, 8, 10] if lluvia_parada else [0, 0, 0, 1, 2, 3, 5, 8]
            retraso_min = random.choice(opciones) if random.random() > 0.05 else random.randint(10, 25)
            if ein_ev + aus_ev > 2.5:
                retraso_min += random.choice([0, 1, 2, 3])
            ankunft_tat = ankunft_geplant + timedelta(minutes=retraso_min)
            abfahrt_tat = abfahrt_geplant + timedelta(minutes=retraso_min)
            if ankunft_tat > ahora:              # esa parada aún no se alcanzó
                continue
            fahrt_haltestelle.append((fh_id, i, id_haltestelle, ankunft_tat, abfahrt_tat))
            fh_id += 1

            # Pasajeros: perfil horario x clima x evento
            perfil = PERFIL_FINDE if ts.weekday() >= 5 else PERFIL_LABORABLE
            media = (2 + 12 * perfil[ts.hour] / 1.5) * weather.transit_weather_boost(ts, mode_share)
            cap = kapazitaet_de[id_fahrzeug]
            einsteiger = 0 if idx == total_paradas - 1 else min(cap, muestrear(media * ein_ev))
            aussteiger = 0 if idx == 0 else min(cap, muestrear(media * aus_ev))
            fahrgastaufkommen.append((fga_id, i, id_haltestelle, einsteiger, aussteiger))
            fga_id += 1

            if hay_evento:
                stats[(verkehrsmittel, "mit Veranstaltung")][0] += einsteiger + aussteiger
                stats[(verkehrsmittel, "mit Veranstaltung")][1] += 1
            else:
                clave = "Regen" if lluvia_parada else "trocken"
                stats[(verkehrsmittel, clave)][0] += einsteiger + aussteiger
                stats[(verkehrsmittel, clave)][1] += 1

        # --- Stoerung: ocasional (más con mal tiempo), casi segura si "ausgefallen" ---
        mal_tiempo = precip > 0 or temp < -5
        if status_fahrt == "ausgefallen":
            probabilidad = 0.9
        else:
            probabilidad = 0.08 + (0.06 if mal_tiempo else 0)
        if status_fahrt != "geplant" and random.random() < probabilidad:
            id_haltestelle_stoerung = random.choice(secuencia)
            if status_fahrt == "ausgefallen":
                typ = "Ausfall"
            else:
                typ = random.choices(STOERUNG_TYPEN,
                                     weights=[1, 1, 1, 5 if mal_tiempo else 1, 1], k=1)[0]
            beginn = hora_inicio + timedelta(minutes=random.uniform(0, 30))
            dauer_min = random.randint(5, 45)
            ende = beginn + timedelta(minutes=dauer_min)
            stoerungen.append((stoerung_id, i, id_haltestelle_stoerung, typ,
                                beginn.replace(microsecond=0), ende.replace(microsecond=0),
                                dauer_min, f"{typ} auf Linie {liniennummer} ({fahrtrichtung})"))
            stoerung_id += 1

    return (haltestellen, linien, linien_haltestelle, modelle, fahrzeuge,
            fahrten, fahrplan, fahrt_haltestelle, fahrgastaufkommen, stoerungen,
            n_refuerzos, stats)


def resumen_clima_eventos(stats):
    print("\nFahrgäste pro Halt (Einsteiger + Aussteiger, promedio):")
    for modo in ("Bus", "Straßenbahn"):
        partes = []
        for clave in ("trocken", "Regen", "mit Veranstaltung"):
            suma, n = stats.get((modo, clave), (0, 0))
            partes.append(f"{clave}: {suma / n:5.1f}" if n else f"{clave}:   -  ")
        print(f"  {modo:<12} " + "   ".join(partes))


# ---------------------------------------------------------------------------
# 5. MAIN INTERACTIVO
# ---------------------------------------------------------------------------
def pedir_entero(mensaje, valor_default):
    entrada = input(f"{mensaje} [{valor_default}]: ").strip()
    if entrada == "":
        return valor_default
    try:
        return max(1, int(entrada))
    except ValueError:
        print("  Valor no válido, se usará el valor por defecto.")
        return valor_default


def pedir_fecha(mensaje, valor_default):
    """Fecha como DD.MM.AAAA o AAAA-MM-DD."""
    while True:
        entrada = input(f"{mensaje} [{valor_default.strftime('%d.%m.%Y')}]: ").strip()
        if entrada == "":
            return valor_default
        for formato in ("%d.%m.%Y", "%Y-%m-%d"):
            try:
                return datetime.strptime(entrada, formato).date()
            except ValueError:
                pass
        print("  Fecha no válida. Formato: DD.MM.AAAA o AAAA-MM-DD.")


def main(config=None):
    """config (opcional, lo usa main.py): start_date, end_date, seed, defaults (usar cantidades
    por defecto), csv. Lo que falte en config se pregunta como siempre."""
    config = config or {}
    _ask = (lambda mensaje, valor: valor) if config.get("defaults") else pedir_entero

    print("=== Generador de datos sintéticos — CityMove (Dresden) ===\n")
    print("Nota: cada 'Fahrt' genera automáticamente varias filas hijas")
    print("(Fahrplan, Fahrt_Haltestelle, Fahrgastaufkommen), así que con")
    print("pocos viajes ya se generan miles de filas en total.\n")

    n_haltestellen = _ask("¿Cuántas Haltestellen querés generar?", 40)
    n_linien = _ask("¿Cuántas Linien querés generar?", 10)
    n_modelle = _ask("¿Cuántos Fahrzeugmodelle querés generar?", 8)
    n_fahrzeuge = _ask("¿Cuántos Fahrzeuge querés generar?", 60)
    n_fahrten = _ask("¿Cuántas Fahrten (viajes concretos) querés generar?", 300)

    hoy = datetime.now().date()
    if "start_date" in config and "end_date" in config:
        start_date, end_date = config["start_date"], config["end_date"]
    else:
        while True:
            start_date = pedir_fecha("Fecha de inicio", hoy - timedelta(days=180))
            end_date = pedir_fecha("Fecha de fin", hoy)
            if start_date <= end_date:
                break
            print("  La fecha de fin debe ser igual o posterior a la de inicio.")

    seed = str(config["seed"]) if "seed" in config else input("Seed aleatorio (vacío = aleatorio): ").strip()
    if seed:
        random.seed(seed)

    eventos = cargar_eventos()
    en_rango = [e for e in eventos
                if e["ende"].date() >= start_date and e["beginn"].date() <= end_date]
    if eventos:
        print(f"\nCityEvents: {len(eventos)} Veranstaltungstermine encontrados, "
              f"{len(en_rango)} dentro del periodo -> se tendrán en cuenta.")
    else:
        print(f"\nAviso: no se encontraron {CSV_TERMIN} / {CSV_ORT}. "
              "Se genera sin efecto de eventos.\n"
              "      (Ejecutá antes generate_cityevents_data.py con las mismas fechas.)")

    print("\nGenerando datos...\n")
    (haltestellen, linien, linien_haltestelle, modelle, fahrzeuge, fahrten,
     fahrplan, fahrt_haltestelle, fahrgastaufkommen, stoerungen,
     n_refuerzos, stats) = generar_datos(
        n_haltestellen, n_linien, n_modelle, n_fahrzeuge, n_fahrten,
        start_date, end_date, eventos)

    print("Escribiendo archivos CSV:")
    escribir_csv("citymove_haltestelle.csv",
                 ["id", "name", "stadtteil", "latitude", "longitude"], haltestellen)
    escribir_csv("citymove_linie.csv",
                 ["id", "liniennummer", "bezeichnung", "verkehrsmittel",
                  "gueltig_ab", "gueltig_bis"], linien)
    escribir_csv("citymove_linien_haltestelle.csv",
                 ["id", "id_linie", "id_haltestelle", "reihenfolge", "fahrtrichtung"],
                 linien_haltestelle)
    escribir_csv("citymove_modell.csv",
                 ["id", "hersteller", "bezeichnung", "fahrzeugtyp", "baujahr"], modelle)
    escribir_csv("citymove_fahrzeug.csv",
                 ["id", "id_modell", "fahrzeugnummer", "kapazitaet", "antriebsart",
                  "inbetriebnahme", "status"], fahrzeuge)
    escribir_csv("citymove_fahrt.csv",
                 ["id", "id_linie", "id_fahrzeug", "datum", "fahrtrichtung", "fahrten_status"],
                 fahrten)
    escribir_csv("citymove_fahrplan.csv",
                 ["id", "id_fahrt", "id_haltestelle", "ankunft_geplant", "abfahrt_geplant"],
                 fahrplan)
    escribir_csv("citymove_fahrt_haltestelle.csv",
                 ["id", "id_fahrt", "id_haltestelle", "ankunft_tatsaechlich",
                  "abfahrt_tatsaechlich"], fahrt_haltestelle)
    escribir_csv("citymove_fahrgastaufkommen.csv",
                 ["id", "id_fahrt", "id_haltestelle", "einsteiger", "aussteiger"],
                 fahrgastaufkommen)
    escribir_csv("citymove_stoerung.csv",
                 ["id", "id_fahrt", "id_haltestelle", "typ", "beginn", "ende",
                  "dauer_min", "beschreibung"], stoerungen)

    sql_file = "citymove_inserts.sql"
    tablas_en_orden = ["Haltestelle", "Linie", "Linien_Haltestelle", "Modell", "Fahrzeug",
                        "Fahrt", "Fahrplan", "Fahrt_Haltestelle", "Fahrgastaufkommen", "Stoerung"]
    escribir_truncate(sql_file, list(reversed(tablas_en_orden)))
    print(f"\nEscribiendo script SQL: {sql_file}")
    escribir_sql(sql_file, "Haltestelle",
                 ["id", "name", "stadtteil", "latitude", "longitude"], haltestellen)
    escribir_sql(sql_file, "Linie",
                 ["id", "liniennummer", "bezeichnung", "verkehrsmittel",
                  "gueltig_ab", "gueltig_bis"], linien)
    escribir_sql(sql_file, "Linien_Haltestelle",
                 ["id", "id_linie", "id_haltestelle", "reihenfolge", "fahrtrichtung"],
                 linien_haltestelle)
    escribir_sql(sql_file, "Modell",
                 ["id", "hersteller", "bezeichnung", "fahrzeugtyp", "baujahr"], modelle)
    escribir_sql(sql_file, "Fahrzeug",
                 ["id", "id_modell", "fahrzeugnummer", "kapazitaet", "antriebsart",
                  "inbetriebnahme", "status"], fahrzeuge)
    escribir_sql(sql_file, "Fahrt",
                 ["id", "id_linie", "id_fahrzeug", "datum", "fahrtrichtung", "fahrten_status"],
                 fahrten)
    escribir_sql(sql_file, "Fahrplan",
                 ["id", "id_fahrt", "id_haltestelle", "ankunft_geplant", "abfahrt_geplant"],
                 fahrplan)
    escribir_sql(sql_file, "Fahrt_Haltestelle",
                 ["id", "id_fahrt", "id_haltestelle", "ankunft_tatsaechlich",
                  "abfahrt_tatsaechlich"], fahrt_haltestelle)
    escribir_sql(sql_file, "Fahrgastaufkommen",
                 ["id", "id_fahrt", "id_haltestelle", "einsteiger", "aussteiger"],
                 fahrgastaufkommen)
    escribir_sql(sql_file, "Stoerung",
                 ["id", "id_fahrt", "id_haltestelle", "typ", "beginn", "ende",
                  "dauer_min", "beschreibung"], stoerungen)

    print("\n¡Listo! Resumen:")
    print(f"  Periodo:             {start_date:%d.%m.%Y} – {end_date:%d.%m.%Y}")
    print(f"  Haltestellen:        {len(haltestellen)}")
    print(f"  Linien:              {len(linien)}")
    print(f"  Linien_Haltestelle:  {len(linien_haltestelle)}")
    print(f"  Modelle:             {len(modelle)}")
    print(f"  Fahrzeuge:           {len(fahrzeuge)}")
    print(f"  Fahrten:             {len(fahrten)}  (de ellas {n_refuerzos} refuerzos por eventos)")
    print(f"  Fahrplan:            {len(fahrplan)}")
    print(f"  Fahrt_Haltestelle:   {len(fahrt_haltestelle)}")
    print(f"  Fahrgastaufkommen:   {len(fahrgastaufkommen)}")
    print(f"  Stoerungen:          {len(stoerungen)}")
    print(f"  Coordenadas únicas usadas: {len(coordenadas_usadas)}")
    resumen_clima_eventos(stats)


if __name__ == "__main__":
    main()
