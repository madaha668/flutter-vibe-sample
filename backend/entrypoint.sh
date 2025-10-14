#!/usr/bin/env sh
set -e

cd /app
mkdir -p /data
uv run python manage.py migrate --noinput
exec "$@"
