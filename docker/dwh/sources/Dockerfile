FROM postgres:18

# Python installieren
RUN apt-get update \
    && apt-get install -y python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python-Abhängigkeiten
COPY requirements.txt .
RUN pip3 install --break-system-packages --no-cache-dir -r requirements.txt

# Python-Skripte
COPY python_script/ ./python_script/

# SQL-Skripte
COPY sql/ /docker-entrypoint-initdb.d/

COPY call_python.sh ./call_python.sh

RUN chmod +x ./call_python.sh

# Eigenes Entrypoint-Skript
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5432

ENTRYPOINT ["/entrypoint.sh"]