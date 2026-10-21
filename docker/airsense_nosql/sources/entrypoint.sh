#!/bin/bash
set -Eeuo pipefail

echo "======================================"
echo "Starting AirSense source system"
echo "======================================"

# MongoDB starten
echo "Starting MongoDB..."

mongod \
    --dbpath /data/db \
    --bind_ip 127.0.0.1 \
    --port 27017 &

MONGO_PID=$!

# Auf MongoDB warten
echo "Waiting for MongoDB..."

until mongosh --quiet --eval 'db.adminCommand("ping").ok' \
    > /dev/null 2>&1
do
    if ! kill -0 "$MONGO_PID" 2>/dev/null; then
        echo "ERROR: MongoDB stopped unexpectedly."
        exit 1
    fi

    sleep 1
done

echo "MongoDB is ready."

# Initialdaten importieren, falls noch nicht erfolgt
echo "Checking AirSense initial data import..."

python /app/import_airsense_data.py

echo "AirSense data import check completed."

# FastAPI starten
echo "Starting AirSense API..."

uvicorn api.main:app \
    --host 0.0.0.0 \
    --port 8000 &

API_PID=$!

echo "AirSense API started on port 8000."
echo "AirSense source system is ready."

# Container beenden, wenn einer der beiden Prozesse beendet wird
cleanup() {
    echo "Stopping AirSense source system..."

    kill "$API_PID" "$MONGO_PID" 2>/dev/null || true

    wait "$API_PID" 2>/dev/null || true
    wait "$MONGO_PID" 2>/dev/null || true
}

trap cleanup EXIT TERM INT

# Auf beide Prozesse warten
wait -n "$MONGO_PID" "$API_PID"
EXIT_CODE=$?

exit "$EXIT_CODE"