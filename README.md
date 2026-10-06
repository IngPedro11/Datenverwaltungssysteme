# Datenverwaltungssysteme – Smart City Data Warehouse

Dieses Repository enthält die Ergebnisse und die technische Umsetzung des Prüfungsprojekts im Modul **Datenverwaltungssysteme (DVS)**.

Im Rahmen des Projekts wird ein fiktives **Smart-City-Szenario** umgesetzt. Dabei werden Daten aus verschiedenen operativen Quellsystemen in einem zentralen **Data Warehouse (DWH)** integriert und für analytische Fragestellungen aufbereitet.

## 🌐 Projekt-Dokumentation

Die ausführliche Projektdokumentation, das Datenmodell sowie die Beschreibung der Analysefragen sind über die **GitHub Pages** verfügbar.

Die Dokumentation umfasst unter anderem:

* Beschreibung des Smart-City-Szenarios
* Beschreibung der Quellsysteme
* Datenmodelle und Beziehungen
* Analytische Fragestellungen
* Aufbau des Data Warehouse
* Staging-, Core- und Business-/Reporting-Schicht(Work in Progress)
* Technische Umsetzung und SQL-Skripte

## 🏙️ Projektszenario

Das Projekt verwendet mehrere fiktive Systeme einer Smart City, aus denen Daten für ein gemeinsames Data Warehouse bereitgestellt werden.

Zu den vorgesehenen Quellsystemen gehören:

* **CityMove** – öffentlicher Personennahverkehr
* **BikeShare** – Fahrradverleihsystem
* **AirSense** – Umwelt- und Wettersensorik
* **CityEvents** – Veranstaltungen und Besucherzahlen

Die Quellsysteme besitzen jeweils eigene relationale Datenmodelle. Im Data Warehouse werden die relevanten Informationen systemübergreifend zusammengeführt, sodass Analysen über mehrere Datenquellen hinweg möglich werden.

## 📊 Analytische Fragestellungen

Das Data Warehouse dient unter anderem zur Untersuchung von Zusammenhängen zwischen verschiedenen Bereichen der Smart City.

Beispiele für analytische Fragestellungen sind:

1. **Welchen Einfluss haben Wetterbedingungen auf die Nutzung des Fahrradverleihsystems?**
2. **Wie verändert sich das Fahrgastaufkommen des öffentlichen Nahverkehrs im Zusammenhang mit Veranstaltungen?**
3. Wie beeinflussen Veranstaltungen die Nutzung nahegelegener Fahrradstationen?
4. Welcher Zusammenhang besteht zwischen Wetterbedingungen und der Nutzung des öffentlichen Nahverkehrs?
5. Wie verändert sich das Verkehrsaufkommen in Abhängigkeit von der Größe einer Veranstaltung?(Work in Progress)
6. Welcher Zusammenhang besteht zwischen Mobilitätsaufkommen und Luftqualität?

Die konkreten Analysen werden im Rahmen der Projektdokumentation erläutert und über die entsprechenden Fakten und Dimensionen des Data Warehouse umgesetzt.

## 📁 Repository-Struktur

```text
.
├── tutorials/
│   ├── tutorial-1.qmd
│   └── tutorial-2.qmd
│
│
├── docker/
│   ├── ...
│   └── ...
│
├── dbml/
│   └── ...
│
├── index.qmd
├── _quarto.yml
├── dbml-visualizer.html
├── package.json
├── README.md
└── ...
```

Die genaue Struktur kann sich während der technischen Umsetzung weiterentwickeln.

## 🐳 Technische Umsetzung mit Docker

Für die technische Umsetzung der Quellsysteme und Datenbanken wird **Docker** verwendet.

Im Ordner

```text
docker/
```

befinden sich die benötigten Docker-Konfigurationen sowie die technische Implementierung der Quellsysteme.

Dadurch kann die Datenbankumgebung reproduzierbar erstellt werden, ohne dass alle Komponenten manuell auf dem lokalen Rechner installiert und konfiguriert werden müssen.

### Voraussetzungen

Für die lokale Ausführung werden grundsätzlich benötigt:

* Docker
* Docker Compose
* Git

Optional können PostgreSQL- und SQL-Tools wie beispielsweise pgAdmin oder DBeaver zur Verwaltung und Analyse der Datenbanken verwendet werden.

## ▶️ Projekt lokal ausführen

Repository klonen:

```bash
git clone https://github.com/IngPedro11/Datenverwaltungssysteme-test.git
cd Datenverwaltungssysteme-test
```

Anschließend kann die technische Umgebung über Docker gestartet werden:

```bash
docker compose up -d
```

Die konkreten Startparameter und Datenbankverbindungen werden in der technischen Dokumentation beschrieben.

## 🧱 Datenbanken

Die Datenhaltung wird in getrennte Bereiche aufgeteilt.

Die Quellsysteme stellen die operativen Daten bereit. Das Data Warehouse bildet davon getrennt die analytische Datenbasis.

Die Datenbanken bzw. Schemas werden über SQL-Skripte erstellt und mit Testdaten befüllt.

Damit ist die Datenbankstruktur nicht an eine einzelne lokale Installation gebunden. Die benötigten SQL-Skripte können auf einem geeigneten PostgreSQL-System ausgeführt werden.

## 📜 SQL-Skripte

Die SQL-Skripte enthalten unter anderem:

* Erstellung der Tabellen
* Definition von Primär- und Fremdschlüsseln
* Erstellung der Datenbankschemas
* Einfügen von Testdaten
* Aufbau der Staging-Schicht
* Transformation und Integration der Daten
* Aufbau der Core-Schicht
* Erstellung der Business-/Reporting-Strukturen
* Beispielabfragen für die analytischen Fragestellungen

> Nicht alle von diesen Features sind implementiert!

Die Skripte dienen damit gleichzeitig als technische Dokumentation und zur reproduzierbaren Erstellung der Datenbankumgebung.

## 📐 Datenmodellierung

Für die Modellierung der Datenbanken wird unter anderem **DBML (Database Markup Language)** verwendet.

Die Modelle zeigen:

* Tabellen und Attribute
* Primärschlüssel
* Fremdschlüssel
* Beziehungen zwischen Tabellen

Für das Data Warehouse werden insbesondere **Fakten** und **Dimensionen** unterschieden.

### Dimensionen

Dimensionen beschreiben die Eigenschaften, nach denen Daten analysiert werden können, beispielsweise:

* Zeit
* Ort
* Verkehrslinie
* Fahrrad
* Veranstaltung
* Wetter

### Fakten

Fakten enthalten messbare Werte bzw. Kennzahlen, beispielsweise:

* Anzahl der Fahrgäste
* Anzahl der Fahrradfahrten
* Fahrtdauer
* Verspätungsdauer
* Besucherzahl
* Temperatur
* Niederschlagsmenge

## 🔄 ETL-Prozess

Die Daten werden aus den Quellsystemen übernommen und für die Analyse aufbereitet.

Der grundsätzliche Ablauf ist:

```text
Quellsysteme
     │
     ▼
  Extract
     │
     ▼
  Staging
     │
     ▼
 Transform
     │
     ▼
    Core
     │
     ▼
    Load
     │
     ▼
Business / Reporting
     │
     ▼
   Analyse
```

Dadurch wird die Trennung zwischen operativen Quellsystemen und analytischer Datenhaltung gewährleistet.

## 🎓 Bezug zur Prüfungsleistung

Das Repository dokumentiert die praktische Umsetzung der im Modul **Datenverwaltungssysteme** behandelten Konzepte.

Insbesondere werden folgende Aspekte umgesetzt:

* mehrere relationale Quellsysteme
* Integration heterogener Datenquellen
* Data-Warehouse-Architektur
* Staging-, Core- und Business-/Reporting-Schicht
* Dimensions- und Faktenmodellierung
* analytische Fragestellungen
* Kennzahlen und KPIs
* SQL-basierte Datenhaltung und Transformation
* reproduzierbare technische Umgebung
* Dokumentation mit Quarto
* technische Bereitstellung über GitHub

## 📚 Dokumentation

Die vollständige fachliche und technische Dokumentation befindet sich in den Quarto-Dateien des Projekts und wird über GitHub Pages veröffentlicht.

Die Dokumentation dient dabei als Ergänzung zur technischen Implementierung im Repository.

---

**Projekt:** Datenverwaltungssysteme (DVS)
**Szenario:** Smart City Data Warehouse
**Institution:** Berufsakademie Dresden
**Technologien:** PostgreSQL · SQL · Docker · Docker Compose · Quarto · DBML · GitHub Pages
