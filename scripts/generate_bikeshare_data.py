#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generador de datos sintéticos para el sistema BikeShare (Dresden, Sajonia).

Pensado para un schema Postgres `bikeshare` con columnas
`GENERATED ALWAYS AS IDENTITY`: los IDs los genera Postgres solo (no se
fuerzan con OVERRIDING SYSTEM VALUE). Para que las FK sigan cuadrando,
el script primero vacía las tablas con `TRUNCATE ... RESTART IDENTITY
CASCADE` y luego inserta las filas exactamente en el mismo orden en que
se generaron en Python (sin incluir la columna id) — así el ID que
asigna la IDENTITY coincide con el que usamos internamente para las
referencias.

NOVEDADES
    - Fecha de inicio y de fin elegibles (todo cae dentro de ese rango).
    - Las Fahrten dependen del clima (módulo compartido dresden_weather.py,
      el mismo que usa AirSense): con frío o lluvia/nieve hay muchos menos
      viajes; además hay horas punta (días laborables) y patrón de fin de semana.

Necesita dresden_weather.py en la misma carpeta. Solo usa la librería estándar.
Genera CSV (uno por tabla) + un script SQL listo para Postgres.
"""

import csv
import random
from collections import Counter
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
# 2. CATÁLOGOS PARA GENERAR DATOS COHERENTES
# ---------------------------------------------------------------------------
FAHRRAD_HERSTELLER = ["Trek", "Cube", "Giant", "Riese & Müller", "Diamant",
                       "Kalkhoff", "Winora", "Bergamont"]
FAHRRAD_BEZEICHNUNGEN = ["CityCruiser", "UrbanRide", "StreetLine", "EcoMove",
                          "PowerPedal", "FlexiBike", "MetroGlide", "ActiveLine"]
FAHRRADTYPEN = ["Stadtrad", "E-Bike", "Mountainbike", "Lastenrad", "Rennrad", "Klapprad"]

STATUS_FAHRRAD = ["aktiv", "aktiv", "aktiv", "wartung", "defekt", "ausgemustert"]
KUNDENTYP = ["Privatperson", "Privatperson", "Privatperson", "Student", "Firma", "Tourist"]

ZAHLUNGSARTEN = ["Kreditkarte", "PayPal", "Lastschrift", "App-Guthaben"]
STATUS_ZAHLUNG_WEIGHTS = [("bezahlt", 85), ("ausstehend", 8), ("fehlgeschlagen", 7)]

# Probabilidad de que una Fahrt se cancele (con lluvia/nieve se cancela más)
P_STORNO_TROCKEN = 0.07
P_STORNO_REGEN = 0.20

WARTUNGSARTEN = ["Reparatur", "Inspektion", "Reinigung", "Ersatzteiltausch"]

# Catálogo fijo de Tarife: bezeichnung, grundgebuehr, preis_pro_minute,
# gueltig_ab (días ANTES del Startdatum), gueltig_bis
TARIFE_CATALOGO = [
    ("Kurzzeittarif", 1.00, 0.12, 1500, None),
    ("Tagestarif",    8.00, 0.00, 1500, None),
    ("Wochentarif",  18.00, 0.00, 1200, None),
    ("Monatsabo",    24.90, 0.00, 900, None),
    ("Jahresabo",   180.00, 0.00, 600, None),
]

# ---------------------------------------------------------------------------
# 3. MODELO DE DEMANDA (clima + hora + día de la semana)
# ---------------------------------------------------------------------------
# Demanda relativa por hora del día (0-23)
PERFIL_LABORABLE = [0.03, 0.02, 0.02, 0.02, 0.03, 0.08, 0.25, 0.70, 1.00, 0.60, 0.40, 0.45,
                    0.55, 0.50, 0.45, 0.55, 0.80, 1.00, 0.80, 0.50, 0.30, 0.20, 0.12, 0.06]
PERFIL_FINDE = [0.05, 0.03, 0.02, 0.02, 0.02, 0.03, 0.05, 0.10, 0.20, 0.40, 0.60, 0.80,
                0.90, 1.00, 1.00, 0.95, 0.90, 0.80, 0.60, 0.40, 0.30, 0.20, 0.12, 0.08]


def factor_demanda(ts):
    """Factor 0-1: cuánta gente usa la bici en ese momento según hora y clima."""
    perfil = PERFIL_FINDE if ts.weekday() >= 5 else PERFIL_LABORABLE
    return perfil[ts.hour] * weather.bike_weather_factor(ts)


def tiempos_con_demanda(n, start_dt, end_dt):
    """n instantes de inicio de viaje distribuidos según la demanda (ordenados)."""
    horas, pesos = [], []
    h = start_dt.replace(minute=0, second=0)
    while h <= end_dt:
        horas.append(h)
        pesos.append(factor_demanda(h + timedelta(minutes=30)))
        h += timedelta(hours=1)
    elegidas = random.choices(horas, weights=pesos, k=n)
    tiempos = []
    for h in elegidas:
        t = h + timedelta(seconds=random.randint(0, 3599))
        tiempos.append(min(max(t, start_dt), end_dt))
    tiempos.sort()
    return tiempos


# ---------------------------------------------------------------------------
# 4. HELPERS
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


def elegir_con_peso(pares):
    valores = [v for v, _ in pares]
    pesos = [w for _, w in pares]
    return random.choices(valores, weights=pesos, k=1)[0]


def fecha_aleatoria(inicio, fin):
    """datetime aleatorio entre inicio y fin (inclusive)."""
    segundos = int((fin - inicio).total_seconds())
    return (inicio + timedelta(seconds=random.randint(0, max(0, segundos)))).replace(microsecond=0)


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
            f.write(f"INSERT INTO bikeshare.{tabla} ({cols_sql}) VALUES ({valores});\n")


def escribir_truncate(nombre_archivo, tablas):
    tablas_qualificadas = ", ".join(f"bikeshare.{t}" for t in tablas)
    with open(nombre_archivo, "w", encoding="utf-8") as f:
        f.write("-- Vaciar tablas y reiniciar las IDENTITY antes de cargar los datos\n")
        f.write(f"TRUNCATE TABLE {tablas_qualificadas} RESTART IDENTITY CASCADE;\n")


# ---------------------------------------------------------------------------
# 5. GENERACIÓN DE DATOS
# ---------------------------------------------------------------------------
def generar_datos(n_modelle, n_fahrraeder, n_stationen, n_kunden, n_fahrten,
                  start_date, end_date):
    start_dt = datetime.combine(start_date, time(0, 0, 0))
    end_dt = datetime.combine(end_date, time(23, 59, 59))
    ahora = datetime.now().replace(microsecond=0)
    if start_dt < ahora < end_dt:        # no generar viajes en el futuro
        end_dt = ahora
    weather.build_weather(end_dt.date())

    # --- Fahrradmodell ---
    modelle = []
    for i in range(1, n_modelle + 1):
        hersteller = random.choice(FAHRRAD_HERSTELLER)
        bezeichnung = random.choice(FAHRRAD_BEZEICHNUNGEN)
        typ = random.choice(FAHRRADTYPEN)
        baujahr = random.randint(2018, 2026)
        modelle.append((i, hersteller, bezeichnung, typ, baujahr))

    # --- Fahrrad (comprada antes del Startdatum) ---
    fahrraeder = []
    for i in range(1, n_fahrraeder + 1):
        id_modell, *_ = random.choice(modelle)
        inventarnummer = f"BS-{i:05d}"
        anschaffung = start_date - timedelta(days=random.randint(30, 1800))
        status = random.choice(STATUS_FAHRRAD)
        fahrraeder.append((i, id_modell, inventarnummer, anschaffung, status))
    fahrraeder_aktiv = [f for f in fahrraeder if f[4] == "aktiv"] or fahrraeder

    # --- Station ---
    stationen = []
    for i in range(1, n_stationen + 1):
        stadtteil = random.choice(STADTTEIL_NOMBRES)
        lat, lon = coordenada_unica(stadtteil)
        nombre = f"BikeShare Station {stadtteil} {i}"
        kapazitaet = random.choice([10, 15, 20, 25, 30, 40])
        stationen.append((i, nombre, stadtteil, lat, lon, kapazitaet))

    # --- Kunde: 85 % ya registrados antes del Startdatum, 15 % se registran en el periodo ---
    kunden = []
    dias_periodo = (end_dt.date() - start_date).days
    for i in range(1, n_kunden + 1):
        if i == 1 or random.random() < 0.85:
            registrierung = start_date - timedelta(days=random.randint(1, 1800))
        else:
            registrierung = start_date + timedelta(days=random.randint(0, max(0, dias_periodo)))
        kundentyp = random.choice(KUNDENTYP)
        kunden.append((i, registrierung, kundentyp))

    def kunde_para(dia):
        """Cliente ya registrado en la fecha del viaje."""
        for _ in range(30):
            k = random.choice(kunden)
            if k[1] <= dia:
                return k[0]
        return kunden[0][0]

    # --- Tarif (catálogo fijo) ---
    tarife = []
    for i, (bezeichnung, grundgebuehr, preis_min, dias_ab, dias_bis) in enumerate(
            TARIFE_CATALOGO, start=1):
        gueltig_ab = start_date - timedelta(days=dias_ab)
        gueltig_bis = None if dias_bis is None else start_date - timedelta(days=dias_bis)
        tarife.append((i, bezeichnung, grundgebuehr, preis_min, gueltig_ab, gueltig_bis))

    # --- Fahrt: instantes según demanda (clima + hora) ---
    fahrten = []
    tiempos = tiempos_con_demanda(n_fahrten, start_dt, end_dt)
    for i, startzeit in enumerate(tiempos, start=1):
        id_kunde = kunde_para(startzeit.date())
        id_fahrrad, *_ = random.choice(fahrraeder_aktiv)
        id_startstation, *_ = random.choice(stationen)
        id_zielstation, *_ = random.choice(stationen)
        while id_zielstation == id_startstation and len(stationen) > 1:
            id_zielstation, *_ = random.choice(stationen)
        id_tarif, *_ = random.choice(tarife)

        llueve = weather.precipitation_mm_h(startzeit) > 0
        fahrtdauer = random.randint(3, 90)
        endzeit = startzeit + timedelta(minutes=fahrtdauer)
        if random.random() < (P_STORNO_REGEN if llueve else P_STORNO_TROCKEN):
            status = "storniert"
        elif endzeit > end_dt:           # al cierre de los datos aún no terminó
            status, fahrtdauer, endzeit = "laufend", None, None
        else:
            status = "abgeschlossen"

        fahrten.append((i, id_kunde, id_fahrrad, id_startstation, id_zielstation,
                         id_tarif, startzeit, endzeit, fahrtdauer, status))

    # --- Zahlung (solo para Fahrten abgeschlossen) ---
    zahlungen = []
    tarif_por_id = {t[0]: t for t in tarife}
    zahlung_id = 1
    for fahrt in fahrten:
        (f_id, _, _, _, _, id_tarif, _, endzeit, fahrtdauer, status) = fahrt
        if status == "abgeschlossen":
            _, _, grundgebuehr, preis_min, _, _ = tarif_por_id[id_tarif]
            betrag = round(float(grundgebuehr) + float(preis_min) * fahrtdauer, 2)
            zahlungszeitpunkt = endzeit + timedelta(minutes=random.uniform(0, 5))
            zahlungsart = random.choice(ZAHLUNGSARTEN)
            status_zahlung = elegir_con_peso(STATUS_ZAHLUNG_WEIGHTS)
            zahlungen.append((zahlung_id, f_id, zahlungszeitpunkt, betrag,
                               zahlungsart, status_zahlung))
            zahlung_id += 1

    # --- Wartung (0 a 3 por Fahrrad, entre la compra y el fin del periodo) ---
    wartungen = []
    wartung_id = 1
    for fahrrad in fahrraeder:
        (f_id, _, _, anschaffung, _) = fahrrad
        desde = datetime.combine(anschaffung, time(0, 0, 0))
        for _ in range(random.randint(0, 3)):
            beginn = fecha_aleatoria(desde, end_dt)
            ende = min(end_dt, beginn + timedelta(hours=random.randint(1, 24)))
            wartungsart = random.choice(WARTUNGSARTEN)
            kosten = round(random.uniform(15, 500), 2)
            beschreibung = f"{wartungsart} an Fahrrad {f_id}"
            wartungen.append((wartung_id, f_id, beginn, ende, wartungsart, kosten, beschreibung))
            wartung_id += 1

    return modelle, fahrraeder, stationen, kunden, tarife, fahrten, zahlungen, wartungen


def resumen_clima(fahrten, start_date, end_date):
    """Muestra cuántos viajes/día hay según lluvia y temperatura (para comprobar el modelo)."""
    por_dia = Counter(f[6].date() for f in fahrten)
    grupos = {"día seco": [], "día con lluvia/nieve": [],
              "< 0 °C": [], "0–10 °C": [], "10–20 °C": [], "> 20 °C": []}
    dia = start_date
    while dia <= end_date:
        n = por_dia.get(dia, 0)
        media = sum(weather.temperature(datetime.combine(dia, time(h))) for h in range(24)) / 24
        grupos["día con lluvia/nieve" if weather.day_info(dia).rain_mm > 0 else "día seco"].append(n)
        if media < 0:
            grupos["< 0 °C"].append(n)
        elif media < 10:
            grupos["0–10 °C"].append(n)
        elif media < 20:
            grupos["10–20 °C"].append(n)
        else:
            grupos["> 20 °C"].append(n)
        dia += timedelta(days=1)
    print("\nFahrten por día según clima (promedio):")
    for nombre, valores in grupos.items():
        if valores:
            print(f"  {nombre:<22} {sum(valores) / len(valores):7.1f}   ({len(valores)} días)")


# ---------------------------------------------------------------------------
# 6. MAIN INTERACTIVO
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

    print("=== Generador de datos sintéticos — BikeShare (Dresden) ===\n")

    n_modelle = _ask("¿Cuántos Fahrradmodelle querés generar?", 8)
    n_fahrraeder = _ask("¿Cuántos Fahrräder querés generar?", 150)
    n_stationen = _ask("¿Cuántas Stationen querés generar?", 25)
    n_kunden = _ask("¿Cuántos Kunden querés generar?", 300)
    n_fahrten = _ask("¿Cuántas Fahrten en total querés generar?", 1000)

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

    print("\nGenerando datos...\n")
    (modelle, fahrraeder, stationen, kunden, tarife, fahrten, zahlungen,
     wartungen) = generar_datos(n_modelle, n_fahrraeder, n_stationen, n_kunden,
                                n_fahrten, start_date, end_date)

    print("Escribiendo archivos CSV:")
    escribir_csv("bikeshare_fahrradmodell.csv",
                 ["id", "hersteller", "bezeichnung", "fahrradtyp", "baujahr"], modelle)
    escribir_csv("bikeshare_fahrrad.csv",
                 ["id", "id_modell", "inventarnummer", "anschaffungsdatum", "status"], fahrraeder)
    escribir_csv("bikeshare_station.csv",
                 ["id", "name", "stadtteil", "latitude", "longitude", "kapazitaet"], stationen)
    escribir_csv("bikeshare_kunde.csv",
                 ["id", "registrierungsdatum", "kundentyp"], kunden)
    escribir_csv("bikeshare_tarif.csv",
                 ["id", "bezeichnung", "grundgebuehr", "preis_pro_minute",
                  "gueltig_ab", "gueltig_bis"], tarife)
    escribir_csv("bikeshare_fahrt.csv",
                 ["id", "id_kunde", "id_fahrrad", "id_startstation", "id_zielstation",
                  "id_tarif", "startzeit", "endzeit", "fahrtdauer_min", "status"], fahrten)
    escribir_csv("bikeshare_zahlung.csv",
                 ["id", "id_fahrt", "zahlungszeitpunkt", "betrag", "zahlungsart", "status"],
                 zahlungen)
    escribir_csv("bikeshare_wartung.csv",
                 ["id", "id_fahrrad", "beginn", "ende", "wartungsart", "kosten", "beschreibung"],
                 wartungen)

    sql_file = "bikeshare_inserts.sql"
    tablas_en_orden = ["Fahrradmodell", "Fahrrad", "Station", "Kunde", "Tarif",
                        "Fahrt", "Zahlung", "Wartung"]
    escribir_truncate(sql_file, list(reversed(tablas_en_orden)))
    print(f"\nEscribiendo script SQL: {sql_file}")
    escribir_sql(sql_file, "Fahrradmodell",
                 ["id", "hersteller", "bezeichnung", "fahrradtyp", "baujahr"], modelle)
    escribir_sql(sql_file, "Fahrrad",
                 ["id", "id_modell", "inventarnummer", "anschaffungsdatum", "status"], fahrraeder)
    escribir_sql(sql_file, "Station",
                 ["id", "name", "stadtteil", "latitude", "longitude", "kapazitaet"], stationen)
    escribir_sql(sql_file, "Kunde",
                 ["id", "registrierungsdatum", "kundentyp"], kunden)
    escribir_sql(sql_file, "Tarif",
                 ["id", "bezeichnung", "grundgebuehr", "preis_pro_minute",
                  "gueltig_ab", "gueltig_bis"], tarife)
    escribir_sql(sql_file, "Fahrt",
                 ["id", "id_kunde", "id_fahrrad", "id_startstation", "id_zielstation",
                  "id_tarif", "startzeit", "endzeit", "fahrtdauer_min", "status"], fahrten)
    escribir_sql(sql_file, "Zahlung",
                 ["id", "id_fahrt", "zahlungszeitpunkt", "betrag", "zahlungsart", "status"],
                 zahlungen)
    escribir_sql(sql_file, "Wartung",
                 ["id", "id_fahrrad", "beginn", "ende", "wartungsart", "kosten", "beschreibung"],
                 wartungen)

    print("\n¡Listo! Resumen:")
    print(f"  Periodo:        {start_date:%d.%m.%Y} – {end_date:%d.%m.%Y}")
    print(f"  Fahrradmodelle: {len(modelle)}")
    print(f"  Fahrräder:      {len(fahrraeder)}")
    print(f"  Stationen:      {len(stationen)}")
    print(f"  Kunden:         {len(kunden)}")
    print(f"  Tarife:         {len(tarife)}")
    print(f"  Fahrten:        {len(fahrten)}")
    print(f"  Zahlungen:      {len(zahlungen)}")
    print(f"  Wartungen:      {len(wartungen)}")
    print(f"  Coordenadas únicas usadas: {len(coordenadas_usadas)}")

    resumen_clima(fahrten, start_date, min(end_date, datetime.now().date())
                  if end_date >= datetime.now().date() >= start_date else end_date)


if __name__ == "__main__":
    main()
