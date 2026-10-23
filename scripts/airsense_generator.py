#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generate synthetic AirSense data as MongoDB-ready JSON (no SQL output).

Neu:
  * Start- und Enddatum frei wählbar (alle Zeitstempel liegen in diesem Zeitraum)
  * Realistische Messwerte für Dresden (Klimamodell auf Basis der DWD-Normalwerte
    von Dresden-Klotzsche, Tages-/Jahresgang, Wetterlagen, Verkehrszeiten)
  * Das Wetter kommt aus dresden_weather.py (gemeinsam mit BikeShare, CityMove,
    CityEvents): gleiches Datum = gleiches Wetter in allen Systemen.
  * Regen wirkt auf die Werte: mehr Luftfeuchte, weniger Feinstaub (Auswaschung).
"""

import csv
import json
import math
import random
from datetime import datetime, timedelta, date, time

import dresden_weather as weather

DISTRICTS = {
    "Altstadt": (51.045, 51.060, 13.725, 13.745),
    "Innere Neustadt": (51.058, 51.068, 13.735, 13.755),
    "Äußere Neustadt": (51.063, 51.075, 13.735, 13.758),
    "Pieschen": (51.075, 51.090, 13.700, 13.730),
    "Trachau": (51.085, 51.100, 13.700, 13.730),
    "Klotzsche": (51.110, 51.135, 13.750, 13.800),
    "Loschwitz": (51.055, 51.075, 13.790, 13.830),
    "Blasewitz": (51.035, 51.055, 13.775, 13.810),
    "Striesen": (51.030, 51.050, 13.760, 13.790),
    "Gruna": (51.020, 51.035, 13.760, 13.790),
    "Seidnitz": (51.020, 51.035, 13.790, 13.820),
    "Johannstadt": (51.040, 51.055, 13.745, 13.770),
    "Südvorstadt": (51.020, 51.040, 13.720, 13.745),
    "Plauen": (51.010, 51.030, 13.700, 13.725),
    "Löbtau": (51.035, 51.050, 13.680, 13.705),
    "Cotta": (51.045, 51.065, 13.670, 13.700),
    "Leuben": (51.005, 51.025, 13.800, 13.830),
    "Prohlis": (50.995, 51.015, 13.780, 13.805),
    "Cossebaude": (51.075, 51.095, 13.620, 13.660),
    "Weixdorf": (51.130, 51.155, 13.800, 13.840),
}
DISTRICT_NAMES = list(DISTRICTS)

STATION_TYPES = ["Traffic", "Background", "Industrial", "Residential", "Park"]
STATION_STATUS = ["active", "active", "active", "maintenance", "inactive"]
SENSOR_TYPES = {
    "PM2.5": ("µg/m³", 0, 150), "PM10": ("µg/m³", 0, 200),
    "NO2": ("µg/m³", 0, 120), "O3": ("µg/m³", 0, 180),
    "CO2": ("ppm", 350, 1200), "Temperature": ("°C", -10, 36),
    "Humidity": ("%", 20, 100), "Noise": ("dB", 30, 95),
}
SENSOR_MANUFACTURERS = [
    "Vaisala", "Aeroqual", "Sensirion", "Bosch Sensortec",
    "Thermo Fisher", "Envea", "OTT HydroMet", "Testo",
]
SENSOR_STATUS = ["active", "active", "active", "faulty", "maintenance"]
QUALITY_STATUS = ["verified", "verified", "verified", "preliminary", "faulty"]
MAINTENANCE_TYPES = ["Calibration", "Cleaning", "Repair", "Replacement", "Inspection"]

used_coordinates = set()


# ---------------------------------------------------------------------------
# Realistische Messwerte (Wetter aus dresden_weather.py)
# ---------------------------------------------------------------------------
# Temperaturoffset (°C) je Stationstyp (städtische Wärmeinsel / Park kühler)
TYPE_TEMP_OFFSET = {"Traffic": 0.8, "Industrial": 0.6, "Residential": 0.4,
                    "Background": 0.0, "Park": -0.6}
TYPE_PM = {"Traffic": 1.3, "Industrial": 1.2, "Residential": 1.0, "Background": 0.85, "Park": 0.8}
TYPE_NO2 = {"Traffic": 1.9, "Industrial": 1.3, "Residential": 1.0, "Background": 0.7, "Park": 0.55}
TYPE_O3 = {"Traffic": 0.7, "Industrial": 0.85, "Residential": 1.0, "Background": 1.05, "Park": 1.1}
TYPE_CO2 = {"Traffic": 60, "Industrial": 40, "Residential": 25, "Background": 5, "Park": 0}
TYPE_NOISE = {"Traffic": 10, "Industrial": 6, "Residential": 0, "Background": -3, "Park": -8}


def clip(value, low, high):
    return max(low, min(high, value))


def realistic_value(sensor_type, station_type, ts):
    """Plausibler Messwert für Sensortyp, Stationstyp und Zeitpunkt."""
    day = ts.date()
    info = weather.day_info(day)
    stag, rh_anom, t_anom = info.stag, info.rh_anom, info.t_anom
    doy = day.timetuple().tm_yday
    hour = ts.hour + ts.minute / 60
    winter = 0.5 + 0.5 * math.cos(2 * math.pi * (doy - weather.COLDEST_DOY) / 365.25)

    temp = weather.temperature(ts, TYPE_TEMP_OFFSET[station_type])
    raining = weather.precipitation_mm_h(ts) > 0
    wet_day = info.rain_mm > 0
    # Regen wäscht Feinstaub und Stickoxide aus der Luft
    wash_pm = 0.55 if raining else (0.85 if wet_day else 1.0)
    wash_no2 = 0.85 if raining else 1.0

    # Verkehrsspitzen (7-9 Uhr, 16-19 Uhr), am Wochenende schwächer
    rush = (math.exp(-((hour - 8) / 1.5) ** 2 / 2) + math.exp(-((hour - 17.5) / 2) ** 2 / 2))
    rush *= 1.0 if ts.weekday() < 5 else 0.5
    traffic_boost = 1.0 if station_type == "Traffic" else 0.5
    stag_eff = stag - 0.02 * t_anom                     # Kälte -> eher Inversion

    if sensor_type == "Temperature":
        value = temp + random.gauss(0, 0.3)
    elif sensor_type == "Humidity":
        if raining:
            value = 90 + random.gauss(0, 4)
        else:
            value = 75 - 1.5 * (temp - 10) + rh_anom + (8 if wet_day else 0) + random.gauss(0, 2)
    elif sensor_type == "PM2.5":
        value = (8 + 8 * winter) * math.exp(stag_eff) * TYPE_PM[station_type] * wash_pm
        value *= (1 + 0.25 * rush * traffic_boost) * random.lognormvariate(0, 0.2)
    elif sensor_type == "PM10":
        value = (8 + 8 * winter) * math.exp(stag_eff) * TYPE_PM[station_type] * 1.6 * wash_pm
        value *= (1 + 0.25 * rush * traffic_boost) * random.lognormvariate(0, 0.22)
    elif sensor_type == "NO2":
        value = (14 + 10 * winter) * math.exp(0.8 * stag_eff) * TYPE_NO2[station_type] * wash_no2
        value *= (1 + 0.6 * rush) * random.lognormvariate(0, 0.2)
    elif sensor_type == "O3":
        sun = max(0.0, math.cos(2 * math.pi * (hour - 14) / 24))
        value = (30 + 70 * (1 - winter) * sun + 1.5 * max(t_anom, 0)) * TYPE_O3[station_type]
        value *= (0.8 if raining else 1.0) * random.lognormvariate(0, 0.1)
    elif sensor_type == "CO2":
        value = 415 + 25 * winter + TYPE_CO2[station_type] * (1 + rush)
        value += (20 if hour < 6 else 0) + 20 * stag_eff + random.gauss(0, 15)
    elif sensor_type == "Noise":
        value = (52 if 7 <= hour < 22 else 40) + TYPE_NOISE[station_type]
        value += 5 * rush + (2.5 if raining else 0) + random.gauss(0, 3)   # nasse Straßen
    else:
        raise ValueError(f"Unbekannter Sensortyp: {sensor_type}")

    _, minimum, maximum = SENSOR_TYPES[sensor_type]
    return round(clip(value, minimum, maximum), 2)


# ---------------------------------------------------------------------------
# Hilfsfunktionen
# ---------------------------------------------------------------------------
def generate_unique_coordinate(district):
    lat_min, lat_max, lon_min, lon_max = DISTRICTS[district]
    for _ in range(200):
        coord = (round(random.uniform(lat_min, lat_max), 6),
                 round(random.uniform(lon_min, lon_max), 6))
        if coord not in used_coordinates:
            used_coordinates.add(coord)
            return coord
    raise RuntimeError(f"Could not generate a unique coordinate for {district!r}.")


def random_datetime(start_dt, end_dt):
    """Zufälliger Zeitpunkt im Intervall [start_dt, end_dt]."""
    seconds = int((end_dt - start_dt).total_seconds())
    return start_dt + timedelta(seconds=random.randint(0, max(0, seconds)))


def json_default(value):
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    raise TypeError(f"Object of type {type(value).__name__} is not JSON serializable")


def generate_data(number_of_stations, number_of_measurements, start_date, end_date):
    start_dt = datetime.combine(start_date, time(0, 0, 0))
    end_dt = datetime.combine(end_date, time(23, 59, 59))
    weather.build_weather(end_date)

    stations, measurements, maintenances = [], [], []
    sensor_id = 1
    district_counts = {}
    sensor_station_type = {}

    for station_id in range(1, number_of_stations + 1):
        district = random.choice(DISTRICT_NAMES)
        district_counts[district] = district_counts.get(district, 0) + 1
        latitude, longitude = generate_unique_coordinate(district)
        # Station wird vor dem Startdatum installiert -> Messungen immer gültig
        installation_date = start_date - timedelta(days=random.randint(200, 1800))
        name = f"Measurement Station {district} {district_counts[district]}"
        station_type = random.choice(STATION_TYPES)

        station = {
            "_id": station_id, "name": name, "stadtteil": district,
            "latitude": latitude, "longitude": longitude,
            "stations_typ": station_type,
            "installationsdatum": installation_date,
            "status": random.choice(STATION_STATUS), "sensoren": [],
        }

        count = random.randint(2, 5)
        chosen_types = random.sample(list(SENSOR_TYPES), k=min(count, len(SENSOR_TYPES)))
        for sensor_type in chosen_types:
            unit, _, _ = SENSOR_TYPES[sensor_type]
            manufacturer = random.choice(SENSOR_MANUFACTURERS)
            # Sensor-Installation: zwischen Stationsinstallation und Startdatum
            sensor_installation = installation_date + timedelta(
                days=random.randint(0, (start_date - installation_date).days)
            )

            sensor = {
                "sensor_id": sensor_id, "sensortyp": sensor_type,
                "hersteller": manufacturer, "modell":
                    f"{manufacturer.split()[0][:3].upper()}-{random.randint(100, 999)}",
                "einheit": unit, "installationsdatum": sensor_installation,
                "status": random.choice(SENSOR_STATUS),
            }
            station["sensoren"].append(sensor)
            sensor_station_type[sensor_id] = station_type

            for _ in range(random.randint(0, 3)):
                start = random_datetime(start_dt, end_dt)
                end = min(end_dt, start + timedelta(hours=random.randint(1, 12)))
                maintenance_type = random.choice(MAINTENANCE_TYPES)
                maintenances.append({
                    "_id": len(maintenances) + 1, "sensor_id": sensor_id,
                    "beginn": start, "ende": end, "wartungsart": maintenance_type,
                    "kosten": round(random.uniform(50, 1800), 2),
                    "beschreibung": f"{maintenance_type} of {sensor_type} sensor at station {name}",
                })
            sensor_id += 1
        stations.append(station)


    # Alle sensoren 10 minuten messen
    all_sensors = [
        sensor
        for station in stations
        for sensor in station["sensoren"]
    ]

    measurement_id = 1
    interval = timedelta(minutes=10)

    # generate messungen bis ende
    current_time = start_dt

    while current_time <= end_dt:
        for sensor in all_sensors:
            sensor_type = sensor["sensortyp"]
            station_type = sensor_station_type[sensor["sensor_id"]]

            measurement = {
                "_id": measurement_id,
                "sensor_id": sensor["sensor_id"],
                "messzeitpunkt": current_time,
                "messwert": realistic_value(
                    sensor_type,
                    station_type,
                    current_time
                ),
                "qualitaetsstatus": random.choice(QUALITY_STATUS),
            }

            measurements.append(measurement)
            measurement_id += 1

        current_time += interval

    return stations, measurements, maintenances




def write_csv(filename, columns, rows):
    with open(filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(columns)
        writer.writerows(rows)
    print(f"  -> {filename} ({len(rows)} rows)")


def export_csv(stations, measurements, maintenances):
    station_rows, sensor_rows = [], []
    for station in stations:
        station_rows.append((
            station["_id"], station["name"], station["stadtteil"], station["latitude"],
            station["longitude"], station["stations_typ"],
            station["installationsdatum"].isoformat(), station["status"],
        ))
        for sensor in station["sensoren"]:
            sensor_rows.append((
                sensor["sensor_id"], station["_id"], sensor["sensortyp"],
                sensor["hersteller"], sensor["modell"], sensor["einheit"],
                sensor["installationsdatum"].isoformat(), sensor["status"],
            ))
    write_csv("airsense_station.csv",
        ["id", "name", "district", "latitude", "longitude", "station_type", "installation_date", "status"],
        station_rows)
    write_csv("airsense_sensor.csv",
        ["id", "station_id", "sensor_type", "manufacturer", "model", "unit", "installation_date", "status"],
        sensor_rows)
    write_csv("airsense_measurement.csv",
        ["id", "sensor_id", "measurement_time", "measurement_value", "quality_status"],
        [(m["_id"], m["sensor_id"], m["messzeitpunkt"].isoformat(), m["messwert"], m["qualitaetsstatus"])
         for m in measurements])
    write_csv("airsense_sensor_maintenance.csv",
        ["id", "sensor_id", "start", "end", "maintenance_type", "cost", "description"],
        [(m["_id"], m["sensor_id"], m["beginn"].isoformat(), m["ende"].isoformat(),
          m["wartungsart"], m["kosten"], m["beschreibung"]) for m in maintenances])


def ask_integer(message, default_value):
    entry = input(f"{message} [{default_value}]: ").strip()
    if not entry:
        return default_value
    try:
        return max(1, int(entry))
    except ValueError:
        print("Ungültige Eingabe; Standardwert wird verwendet.")
        return default_value


def ask_date(message, default_value):
    """Datum als TT.MM.JJJJ oder JJJJ-MM-TT einlesen."""
    while True:
        entry = input(f"{message} [{default_value.strftime('%d.%m.%Y')}]: ").strip()
        if not entry:
            return default_value
        for fmt in ("%d.%m.%Y", "%Y-%m-%d"):
            try:
                return datetime.strptime(entry, fmt).date()
            except ValueError:
                pass
        print("Ungültiges Datum. Format: TT.MM.JJJJ oder JJJJ-MM-TT.")


def main(config=None):
    """config (opcional, lo usa main.py): start_date, end_date, seed, defaults (usar cantidades
    por defecto), csv. Lo que falte en config se pregunta como siempre."""
    config = config or {}
    _ask = (lambda mensaje, valor: valor) if config.get("defaults") else ask_integer

    print("=== Synthetic Data Generator — AirSense (Dresden) ===\n")
    number_of_stations = _ask("Wie viele Stationen sollen erzeugt werden?", 25)
    number_of_measurements = _ask("Wie viele Messungen insgesamt?", 1000)

    today = date.today()
    if "start_date" in config and "end_date" in config:
        start_date, end_date = config["start_date"], config["end_date"]
    else:
        while True:
            start_date = ask_date("Startdatum", today - timedelta(days=180))
            end_date = ask_date("Enddatum", today)
            if start_date <= end_date:
                break
            print("Das Enddatum muss am oder nach dem Startdatum liegen.")

    seed_entry = str(config["seed"]) if "seed" in config else input("Zufalls-Seed (leer = zufällig): ").strip()
    if seed_entry:
        random.seed(seed_entry)

    used_coordinates.clear()
    stations, measurements, maintenances = generate_data(
        number_of_stations, number_of_measurements, start_date, end_date
    )
    output = {
        "stations": stations,
        "messungen": measurements,
        "sensorwartungen": maintenances,
    }
    filename = "airsense_mongodb.json"
    with open(filename, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2, default=json_default)

    print(f"\nMongoDB-JSON geschrieben: {filename}")
    print(f"  Zeitraum:        {start_date:%d.%m.%Y} – {end_date:%d.%m.%Y}")
    print(f"  Stationen:       {len(stations)}")
    print(f"  Sensoren:        {sum(len(s['sensoren']) for s in stations)}")
    print(f"  Messungen:       {len(measurements)}")
    print(f"  Wartungen:       {len(maintenances)}")
    print(f"  Eindeutige Koordinaten: {len(used_coordinates)}")

    if "csv" in config:
        choice = "j" if config["csv"] else "n"
    else:
        choice = input("\nZusätzlich CSV-Dateien exportieren? [J/n]: ").strip().lower()
    if choice in ("", "j", "ja", "y", "yes"):
        export_csv(stations, measurements, maintenances)


if __name__ == "__main__":
    main()
