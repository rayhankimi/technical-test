#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
docker compose up -d --wait db
docker compose exec -T db psql -U postgres -v ON_ERROR_STOP=1 < answers.sql