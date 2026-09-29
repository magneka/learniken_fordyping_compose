#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

usage() {
  echo "Usage: $0 {up|down}"
  exit 1
}

[[ $# -eq 1 ]] || usage

case "$1" in
  up)
    docker compose up -d
    ;;
  down)
    # -v removes the named volume, --rmi local removes the pulled/built image
    docker compose down -v --rmi local
    ;;
  *)
    usage
    ;;
esac
