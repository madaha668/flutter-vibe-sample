# Nomad Notes Backend

## Quick start

```bash
# create and sync the virtual environment
uv venv .venv
uv sync

# apply migrations and start the API
uv run python manage.py migrate
uv run python manage.py runserver 0.0.0.0:8000
```

## API endpoints

- `POST /api/auth/signup/` – create an account and receive JWT tokens
- `POST /api/auth/signin/` – obtain access/refresh token pair (email + password)
- `POST /api/auth/refresh/` – rotate refresh token and get a new access token
- `POST /api/auth/signout/` – blacklist refresh token and end the session
- `GET /api/auth/me/` – fetch the current user profile
- `GET/POST /api/notes/` – list or create notes for the authenticated user
- `GET/PATCH/DELETE /api/notes/<id>/` – manage a specific note
- `GET /api/docs/` – interactive Swagger documentation (served by drf-spectacular)

## Environment

Copy `.env.example` to `.env` and adjust as needed. SQLite is used by default; set `DATABASE_URL` for PostgreSQL. Tokens inherit lifetimes from `ACCESS_TOKEN_MINUTES` and `REFRESH_TOKEN_DAYS`.

## Tooling

- Django + Django REST Framework for the HTTP layer
- SimpleJWT for access and refresh tokens (with blacklist enabled)
- drf-spectacular for OpenAPI schema and docs
- psycopg for PostgreSQL connectivity

Optional dev extras (`uv sync --group dev`) install Ruff and Pytest-Django.
