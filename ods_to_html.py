import pandas as pd
from html import escape
from pathlib import Path
import re
import unicodedata

# --------------------------------------------------
# Einstellungen
# --------------------------------------------------

INPUT_FILE = "Tutorial001a_LogicalDataMap.ods"
OUTPUT_DIR = Path("tables")

# Es sollen die letzten fünf Themen exportiert werden.
NUMBER_OF_TOPICS = 5

OUTPUT_DIR.mkdir(exist_ok=True)


# --------------------------------------------------
# Hilfsfunktion: Dateinamen erzeugen
# --------------------------------------------------

def make_filename(text):
    """Erzeugt einen geeigneten Dateinamen aus einem Thema."""

    text = text.lower()
    text = text.replace("ä", "ae")
    text = text.replace("ö", "oe")
    text = text.replace("ü", "ue")
    text = text.replace("ß", "ss")

    text = unicodedata.normalize("NFKD", text)
    text = text.encode("ascii", "ignore").decode("ascii")
    text = re.sub(r"[^a-z0-9]+", "_", text)
    text = text.strip("_")

    return text


# --------------------------------------------------
# Daten einlesen und Themen gruppieren
# --------------------------------------------------

def load_topics(sheet_name, column_indices, column_names):
    """Liest ein Tabellenblatt ein und gruppiert die Zeilen nach Thema."""

    df = pd.read_excel(
        INPUT_FILE,
        sheet_name=sheet_name,
        dtype=str,
        engine="odf"
    ).fillna("")

    # Nur die benötigten Spalten auswählen
    df = df.iloc[:, column_indices].copy()
    df.columns = column_names

    # Leerzeichen entfernen
    df = df.map(
        lambda value: value.strip()
        if isinstance(value, str)
        else value
    )

    groups = []
    current_group = None

    for _, row in df.iterrows():

        thema = row["Thema"]

        # Eine neue Gruppe beginnt, sobald ein Thema eingetragen ist.
        if thema:
            current_group = {
                "thema": thema,
                "rows": []
            }
            groups.append(current_group)

        # Zeilen vor dem ersten Thema ignorieren.
        if current_group is None:
            continue

        # Vollständig leere Zeilen überspringen.
        if all(value == "" for value in row):
            continue

        current_group["rows"].append(row)

    # Nur die letzten fünf Themen behalten.
    return groups[-NUMBER_OF_TOPICS:]


# --------------------------------------------------
# HTML für ein Thema erzeugen
# --------------------------------------------------

def create_html(sheet_name, group, columns, header_groups):

    thema = group["thema"]
    rows = group["rows"]

    html = []

    '''html.append("<!DOCTYPE html>")
    html.append('<html lang="de">')
    html.append("<head>")
    html.append('<meta charset="UTF-8">')
    html.append(
        f"<title>{escape(sheet_name)} – {escape(thema)}</title>"
    )

    html.append("""
<style>
    body {
        font-family: Arial, sans-serif;
        margin: 30px;
    }

    h2 {
        margin-bottom: 20px;
    }

    table {
        border-collapse: collapse;
        width: 100%;
    }

    th, td {
        border: 1px solid #ccc;
        padding: 8px;
        text-align: left;
        vertical-align: top;
    }

    thead th {
        background-color: #f2f2f2;
    }

    td.grp {
        font-weight: bold;
        background-color: #fafafa;
    }
</style>
""")

    html.append("</head>")'''
    html.append("<body>")

    #html.append(f"<h2>{escape(thema)}</h2>")

    html.append("<table class=\"table table-sm table-bordered mapping\">")
    html.append("<thead>")

    # Erste Kopfzeile
    html.append("<tr>")
    html.append('<th rowspan="2">Thema</th>')

    for group_name, group_columns in header_groups:
        html.append(
            f'<th colspan="{len(group_columns)}">'
            f"{escape(group_name)}</th>"
        )

    html.append("</tr>")

    # Zweite Kopfzeile
    html.append("<tr>")

    for column in columns[1:]:
        html.append(f"<th>{escape(column)}</th>")

    html.append("</tr>")
    html.append("</thead>")

    # Tabelleninhalt
    html.append("<tbody>")

    rowspan = len(rows)

    for index, row in enumerate(rows):
        html.append("<tr>")

        # Thema nur in der ersten Zeile ausgeben.
        if index == 0:
            html.append(
                f'<td rowspan="{rowspan}" class="grp">'
                f"{escape(thema)}</td>"
            )

        for column in columns[1:]:
            html.append(
                f"<td>{escape(str(row[column]))}</td>"
            )

        html.append("</tr>")

    html.append("</tbody>")
    html.append("</table>")

    html.append("</body>")
    html.append("</html>")

    return "\n".join(html)


# --------------------------------------------------
# Export für ein Tabellenblatt
# --------------------------------------------------

def export_sheet(
    sheet_name,
    column_indices,
    columns,
    header_groups
):
    """Exportiert die letzten fünf Themen als einzelne HTML-Dateien."""

    groups = load_topics(
        sheet_name,
        column_indices,
        columns
    )

    print(f"\nTabellenblatt: {sheet_name}")
    print(f"Anzahl exportierter Themen: {len(groups)}")

    for group in groups:

        thema = group["thema"]

        filename = (
            f"{sheet_name}_"
            f"{make_filename(thema)}.html"
        )

        output_path = OUTPUT_DIR / filename

        html = create_html(
            sheet_name,
            group,
            columns,
            header_groups
        )

        output_path.write_text(
            html,
            encoding="utf-8"
        )

        print(f"Erstellt: {output_path}")


# --------------------------------------------------
# 1. Fakten
# --------------------------------------------------

export_sheet(
    sheet_name="Fakten",

    # Spalten aus dem Tabellenblatt Fakten
    column_indices=[0, 1, 2, 4, 5, 6, 8, 9, 10],

    columns=[
        "Thema",
        "Staging Tabelle",
        "Staging Spalte",
        "Staging Verarbeitung",
        "Core Tabelle",
        "Core Spalte",
        "Core Verarbeitung",
        "Reporting Tabelle",
        "Reporting Spalte"
    ],

    header_groups=[
        (
            "Staging",
            [
                "Staging Tabelle",
                "Staging Spalte",
                "Staging Verarbeitung"
            ]
        ),
        (
            "Core",
            [
                "Core Tabelle",
                "Core Spalte",
                "Core Verarbeitung"
            ]
        ),
        (
            "Reporting",
            [
                "Reporting Tabelle",
                "Reporting Spalte"
            ]
        )
    ]
)


# --------------------------------------------------
# 2. Dimensionen
# --------------------------------------------------

export_sheet(
    sheet_name="Dimensionen",

    # Spalten aus dem Tabellenblatt Dimensionen
    column_indices=[0, 1, 2, 3, 4, 5, 6, 7],

    columns=[
        "Thema",
        "Staging Tabelle",
        "Staging Spalte",
        "Staging Verarbeitung",
        "Core Tabelle",
        "Core Spalte",
        "Reporting Tabelle",
        "Reporting Spalte"
    ],

    header_groups=[
        (
            "Staging",
            [
                "Staging Tabelle",
                "Staging Spalte",
                "Staging Verarbeitung"
            ]
        ),
        (
            "Core",
            [
                "Core Tabelle",
                "Core Spalte"
            ]
        ),
        (
            "Reporting",
            [
                "Reporting Tabelle",
                "Reporting Spalte"
            ]
        )
    ]
)


print("\nExport abgeschlossen.")
print(f"Die HTML-Dateien liegen im Ordner: {OUTPUT_DIR.resolve()}")
