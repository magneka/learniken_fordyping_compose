#!/bin/bash
# SQL SELECT script for Linux/macOS - Reads from .env file

if [ -f .env ]; then
    set -a; source <(tr -d '\r' < .env); set +a
else
    echo "Error: .env file not found"
    exit 1
fi

echo "Running: SELECT * FROM $DB_TABLE_NAME"
echo "Database: $DB_DATABASE"
echo "User: $DB_USERNAME"
echo ""

# Run psql inside the postgres container (host "postgres" only resolves inside the Docker network)
docker compose --env-file .env exec -T postgres psql -U "$DB_USERNAME" -d "$DB_DATABASE" -c "SELECT * FROM $DB_TABLE_NAME;"
