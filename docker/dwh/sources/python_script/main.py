import json

from worker import load_progress, save_progress, process_system


def main():
    with open("config.json", "r", encoding="utf-8") as file:
        config = json.load(file)

    progress = load_progress()

    for system_name, system_config in config["systems"].items():
        try:
            process_system(
                system_name,
                system_config,
                progress
            )

        except Exception as error:
            print(f"Fehler bei {system_name}: {error}")

            # Andere Systeme können trotzdem weiterlaufen.
            continue

    print("Verarbeitung abgeschlossen.")


if __name__ == "__main__":
    main()