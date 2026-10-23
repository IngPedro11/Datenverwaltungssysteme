#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
main.py — Runs the Dresden synthetic data generators step by step.

The period (start and end dates) is requested ONCE and used across all
systems so that the data remains consistent
(same weather, same events).

Execution order (important):

    1. CityEvents -> PostgreSQL   (events; CityMove reads its CSV files)
    2. CityMove   -> PostgreSQL   (public transport; uses events and weather)
    3. BikeShare  -> PostgreSQL   (bicycles; uses weather)
    4. AirSense   -> MongoDB JSON (sensors; uses weather)

All generated files are saved in the ./output directory.

Usage:

    python3 main.py

Required files in the same directory:

    main.py, dresden_weather.py, generate_cityevents_data.py,
    generate_citymove_data.py, generate_bikeshare_data.py, airsense_generator.py
"""

import importlib
import os
import sys
import traceback
from datetime import datetime, timedelta

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(BASE_DIR, "output")
sys.path.insert(0, BASE_DIR)

# (Name, module, output format)
PASOS = [
    ("CityEvents  (events)",               "generate_cityevents_data", "SQL + CSV"),
    ("CityMove    (public transport)",     "generate_citymove_data",   "SQL + CSV"),
    ("BikeShare   (bicycles)",              "generate_bikeshare_data",  "SQL + CSV"),
    ("AirSense    (sensors)",               "airsense_generator",       "MongoDB JSON (+ optional CSV)"),
]

ARCHIVOS_NECESARIOS = ["dresden_weather"] + [p[1] for p in PASOS]


def linea(texto="", caracter="="):
    print(caracter * 66 if not texto else f"{caracter * 3} {texto} {caracter * (62 - len(texto))}")


def pedir_fecha(mensaje, valor_default):
    """Enter a date as DD.MM.YYYY or YYYY-MM-DD (Enter = default value)."""
    while True:
        entrada = input(f"{mensaje} [{valor_default.strftime('%d.%m.%Y')}]: ").strip()
        if entrada == "":
            return valor_default
        for formato in ("%d.%m.%Y", "%Y-%m-%d"):
            try:
                return datetime.strptime(entrada, formato).date()
            except ValueError:
                pass
        print("  Invalid date. Format: DD.MM.YYYY or YYYY-MM-DD.")


def si_no(mensaje, default=True):
    """Prompts the user with a yes/no question."""
    sufijo = "[Y/n]" if default else "[y/N]"
    entrada = input(f"{mensaje} {sufijo}: ").strip().lower()
    if entrada == "":
        return default
    return entrada in ("s", "si", "sí", "y", "yes", "j", "ja")


def comprobar_archivos():
    """Checks whether all required Python files are present."""
    faltan = [
        m for m in ARCHIVOS_NECESARIOS
        if not os.path.exists(os.path.join(BASE_DIR, f"{m}.py"))
    ]
    if faltan:
        print("The following files are missing from the main.py directory:")
        for m in faltan:
            print(f"  - {m}.py")
        sys.exit(1)


def elegir_pasos():
    """Allows the user to select which systems to run."""
    print("\nSystems to generate:")
    for i, (nombre, _, salida) in enumerate(PASOS, start=1):
        print(f"  {i}. {nombre}  [{salida}]")

    entrada = input("Enter numbers separated by commas (Enter = all): ").strip()

    if not entrada:
        return list(range(len(PASOS)))

    try:
        elegidos = sorted({
            int(x) - 1
            for x in entrada.replace(" ", "").split(",")
            if x
        })
        if elegidos and all(0 <= e < len(PASOS) for e in elegidos):
            return elegidos
    except ValueError:
        pass

    print("  Invalid input. All systems will be generated.")
    return list(range(len(PASOS)))


def main():
    linea()
    print("  Synthetic Data Generator — Dresden (all systems)")
    linea()

    comprobar_archivos()

    # --- 1. Period (requested once for all systems) ---
    hoy = datetime.now().date()
    print("\nSTEP 1 — Data period")

    while True:
        start_date = pedir_fecha(
            "  Start date",
            hoy - timedelta(days=180)
        )
        end_date = pedir_fecha("  End date", hoy)

        if start_date <= end_date:
            break

        print("  The end date must be equal to or later than the start date.")

    if end_date < hoy:
        print(
            "  Note: The entire period is in the past, so no rows with "
            "'planned' or 'ongoing' status will be generated."
        )

    # --- 2. General options ---
    print("\nSTEP 2 — Options")

    seed = input(
        "  Random seed (empty = random, same seed = same data): "
    ).strip()

    usar_defaults = si_no(
        "  Use the default quantities for all systems?\n"
        "  (If you answer No, each system will ask for its quantities)",
        True
    )

    pasos = elegir_pasos()

    csv_airsense = None
    if len(PASOS) - 1 in pasos:
        csv_airsense = si_no(
            "  AirSense: Also export CSV files?",
            False
        )

    config = {
        "start_date": start_date,
        "end_date": end_date,
        "defaults": usar_defaults,
    }

    config["seed"] = seed if seed else ""

    if csv_airsense is not None:
        config["csv"] = csv_airsense

    # --- Summary and confirmation ---
    print()
    linea("Summary")

    print(
        f"  Period:       {start_date:%d.%m.%Y} – {end_date:%d.%m.%Y} "
        f"({(end_date - start_date).days + 1} days)"
    )
    print(f"  Seed:         {seed or 'random'}")
    print(
        f"  Quantities:   "
        f"{'default values' if usar_defaults else 'prompt for each system'}"
    )
    print(
        "  Systems:      "
        + ", ".join(PASOS[i][0].split()[0] for i in pasos)
    )
    print(f"  Output directory: {OUTPUT_DIR}")

    linea()

    if not si_no("Start generation?", True):
        print("Cancelled.")
        return

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.chdir(OUTPUT_DIR)  # Scripts write here, and CityMove reads files from here.

    # --- 3. Run systems one by one ---
    resultados = []

    for numero, indice in enumerate(pasos, start=1):
        nombre, modulo, _ = PASOS[indice]

        print()
        linea(f"[{numero}/{len(pasos)}] {nombre.strip()}", "#")

        inicio = datetime.now()

        try:
            importlib.import_module(modulo).main(config)
            resultados.append(
                (nombre, "OK", (datetime.now() - inicio).total_seconds())
            )

        except Exception:  # noqa: BLE001
            traceback.print_exc()
            resultados.append(
                (nombre, "ERROR", (datetime.now() - inicio).total_seconds())
            )
            print(
                f"\nError in {nombre.strip()}! "
                "Execution will be stopped."
            )
            break

    # --- 4. Final summary ---
    print()
    linea("Result")

    for nombre, estado, segundos in resultados:
        print(f"  {estado:<6} {nombre}   ({segundos:.1f} s)")

    archivos = sorted(os.listdir(OUTPUT_DIR))

    print(f"\n  Files in {OUTPUT_DIR}:")
    for a in archivos:
        groesse = os.path.getsize(os.path.join(OUTPUT_DIR, a)) / 1024
        print(f"    {a:<42} {groesse:9.1f} KB")

    print(
        "\n  To load data into PostgreSQL: run each *_inserts.sql file "
        "in its corresponding schema"
    )
    print(
        "  (cityevents, citymove, bikeshare). For MongoDB: airsense_mongodb.json."
    )


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nInterrupted.")
