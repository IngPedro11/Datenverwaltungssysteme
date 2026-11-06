#!/bin/bash

set -ex

echo "======================================"
echo "Starting DWH system"
echo "======================================"

# PostgreSQL starten
docker-entrypoint.sh postgres &

POSTGRES_PID=$!

echo "Waiting for PostgreSQL initialization..."

# Warten, bis PostgreSQL bereit ist UND die Initialisierung abgeschlossen wurde
until ! kill -0 "$POSTGRES_PID" 2>/dev/null
do
    if pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; then

        # Prüfen, ob die Initialisierungstabellen vorhanden sind
        if psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -tAc \
            "SELECT EXISTS (
                SELECT FROM information_schema.tables
                WHERE table_schema = 'public'
            );" | grep -q t; then

            break
        fi
    fi

    sleep 1
done

echo "PostgreSQL initialization completed."

echo "DWH system is ready."

wait "$POSTGRES_PID"