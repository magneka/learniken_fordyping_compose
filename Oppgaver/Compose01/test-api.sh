#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-http://localhost:8085}"

echo "Testing $HOST/weatherforecast"
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' "$HOST/weatherforecast"
