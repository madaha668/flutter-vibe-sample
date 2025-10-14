# syntax=docker/dockerfile:1.7

FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# Install uv
RUN pip install --no-cache-dir uv

# Copy project metadata for dependency resolution
COPY pyproject.toml uv.lock /app/
#COPY entrypoint.sh /entrypoint.sh

# Sync dependencies (system packages may be needed for psycopg)
RUN apt-get update && apt-get install -y --no-install-recommends build-essential libpq-dev && \
    uv sync --frozen --no-dev && \
    apt-get purge -y build-essential && apt-get auto-remove -y && rm -rf /var/lib/apt/lists/*

# Copy application code
COPY . /app
#RUN chmod +x /entrypoint.sh

# Create directory for static if needed
RUN mkdir -p /app/static /data

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["uv", "run", "gunicorn", "nomad_backend.wsgi:application", "--bind", "0.0.0.0:8000"]
