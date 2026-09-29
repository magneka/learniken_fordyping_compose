#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

# shellcheck disable=SC1091
set -a && source .env && set +a

docker compose exec -T db /opt/mssql-tools18/bin/sqlcmd \
    -C -S localhost -U sa -P "$DB_PASSWORD" -d "$DB_DATABASE" \
    -Q "SELECT * FROM customer;"
