#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Gemeinsames Wettermodell für Dresden (für AirSense, BikeShare, CityEvents ...).

Alle Skripte, die dieses Modul benutzen, bekommen für dasselbe Datum exakt
dasselbe Wetter (fester Seed + feste Startbasis), egal welchen Zeitraum man wählt.

Wichtig: WEATHER_SEED und WEATHER_ANCHOR nicht ändern, sonst passen die
Daten der verschiedenen Skripte nicht mehr zusammen.

Die Temperatur ist identisch mit dem Modell in airsense_generator.py.
Der Niederschlag nutzt einen eigenen Zufallsgenerator und verändert die
Temperaturen deshalb nicht.
"""

import math
import random
from collections import namedtuple
from datetime import date, timedelta

# Jahresmittel ~9.8 °C, kältester Tag ~20. Jan (~0.3 °C), wärmster ~20. Jul (~19.3 °C)
# -> passt zu den DWD-Normalwerten (Dresden-Klotzsche, 1991-2020).
ANNUAL_MEAN_TEMP = 9.8
ANNUAL_AMPLITUDE = 9.5
COLDEST_DOY = 20

WEATHER_ANCHOR = date(2000, 1, 1)
WEATHER_SEED = 20240601

# Niederschlag: Markov-Kette (nasse Tage kommen in Serien), ~130 Regentage/Jahr,
# ~600 mm/Jahr -> ähnlich wie Dresden.
P_WET_AFTER_DRY = 0.25
P_WET_AFTER_WET = 0.55
MEAN_RAIN_MM = 4.5

Day = namedtuple("Day", "t_anom stag rh_anom rain_mm rain_start rain_hours")

_days = {}
_built_until = None


def build_weather(end_day):
    """Berechnet das Wetter von WEATHER_ANCHOR bis end_day (nur bei Bedarf neu)."""
    global _built_until
    if _built_until is not None and end_day <= _built_until:
        return
    _days.clear()

    rng = random.Random(WEATHER_SEED)
    rng_rain = random.Random(WEATHER_SEED + 1)
    phi_t, std_t = 0.72, 4.0
    phi_s, std_s = 0.80, 0.45
    t_anom, stag, wet_prev = 0.0, 0.0, False

    day = WEATHER_ANCHOR
    while day <= end_day:
        t_anom = phi_t * t_anom + rng.gauss(0, std_t * math.sqrt(1 - phi_t ** 2))
        stag = phi_s * stag + rng.gauss(0, std_s * math.sqrt(1 - phi_s ** 2))
        rh_anom = -0.4 * t_anom + rng.gauss(0, 6)

        wet = rng_rain.random() < (P_WET_AFTER_WET if wet_prev else P_WET_AFTER_DRY)
        amount = 0.2 + rng_rain.expovariate(1 / MEAN_RAIN_MM)
        start = rng_rain.randint(0, 23)
        hours = rng_rain.randint(1, 10)
        wet_prev = wet

        _days[day] = Day(t_anom, stag, rh_anom,
                         round(amount, 1) if wet else 0.0, start, hours)
        day += timedelta(days=1)
    _built_until = end_day


def day_info(day):
    """Wetterlage eines Kalendertags (Namedtuple Day)."""
    if day < WEATHER_ANCHOR:
        raise ValueError(f"Datum {day} liegt vor {WEATHER_ANCHOR}.")
    build_weather(day)
    return _days[day]


def seasonal_mean(day):
    doy = day.timetuple().tm_yday
    return ANNUAL_MEAN_TEMP - ANNUAL_AMPLITUDE * math.cos(
        2 * math.pi * (doy - COLDEST_DOY) / 365.25)


def temperature(ts, offset=0.0):
    """Lufttemperatur (°C) zum Zeitpunkt ts (datetime), inkl. Tagesgang."""
    day = ts.date()
    info = day_info(day)
    doy = day.timetuple().tm_yday
    hour = ts.hour + ts.minute / 60
    year_phase = 2 * math.pi * (doy - COLDEST_DOY) / 365.25
    winter = 0.5 + 0.5 * math.cos(year_phase)
    daily_amp = 4.0 + 2.5 * (1 - winter)                # Winter 4 °C, Sommer 6.5 °C
    return (seasonal_mean(day) + info.t_anom
            + daily_amp * math.cos(2 * math.pi * (hour - 15) / 24) + offset)


def precipitation_mm_h(ts):
    """Niederschlagsintensität (mm/h) zum Zeitpunkt ts; 0 wenn es trocken ist."""
    info = day_info(ts.date())
    if info.rain_mm > 0 and info.rain_start <= ts.hour < info.rain_start + info.rain_hours:
        return info.rain_mm / info.rain_hours
    return 0.0


# ---------------------------------------------------------------------------
# Wirkung des Wetters auf das Verhalten der Menschen (gemeinsam für alle Systeme)
# ---------------------------------------------------------------------------
def temp_factor(temp):
    """Fahrrad-Nachfrage nach Temperatur: 6 °C ~50 %, 0 °C ~23 %, -5 °C ~10 %."""
    factor = 0.05 + 0.95 / (1 + math.exp(-(temp - 6) / 5))
    return factor * 0.7 if temp > 30 else factor


def rain_factor(ts, temp=None):
    """Fahrrad-Nachfrage nach Niederschlag (1.0 = trocken)."""
    temp = temperature(ts) if temp is None else temp
    mm = precipitation_mm_h(ts)
    if mm > 0:
        if temp < 1:
            return 0.20            # Schnee / Glätte
        return 0.15 if mm >= 2 else 0.35
    return 0.85 if day_info(ts.date()).rain_mm > 0 else 1.0


def bike_weather_factor(ts):
    """Faktor 0-1: wie gut ist das Wetter zum Radfahren."""
    temp = temperature(ts)
    return temp_factor(temp) * rain_factor(ts, temp)


def transit_weather_boost(ts, mode_share=1.0):
    """Mehr Fahrgäste bei Regen/Kälte (Umstieg vom Rad/Fuß auf Bus und Bahn).

    Bus: mode_share=1.0, Straßenbahn: ~0.7. Trockenes, mildes Wetter -> 1.0.
    Leichter Regen ~ +33 %, starker Regen ~ +43 %, 0 °C ~ +19 %.
    """
    temp = temperature(ts)
    boost = 1 + 0.5 * (1 - rain_factor(ts, temp)) + 0.25 * (1 - temp_factor(temp))
    return 1 + (boost - 1) * mode_share
