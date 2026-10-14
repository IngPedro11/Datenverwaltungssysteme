#!/bin/bash

set -e

echo "======================================"
echo "Starting DWH system"
echo "======================================"

# PostgreSQL starten
docker-entrypoint.sh postgres &

POSTGRES_PID=$!

echo "Waiting for PostgreSQL..."

until pg_isready -U "$DWH_USER" -d "$dwh" > /dev/null 2>&1
do
    sleep 1
done

echo "PostgreSQL is ready."

echo "CityMove source system is ready."

# Auf beide Prozesse warten
wait $POSTGRES_PID
