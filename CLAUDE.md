# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Nomad Notes is a full-stack mobile application consisting of:
- **Flutter mobile app** (`nomad_notes/`) - Cross-platform iOS/Android note-taking client with **visual notes support**
- **Django REST backend** (`backend/`) - API server with JWT authentication, **OCR, and image analysis**
- **Docker Compose** setup for local development

### Recent Features

- **Visual Notes** (`VISUAL_NOTES_IMPLEMENTATION.md`): Photo attachments with OCR text extraction and object detection
- **Docker Commands** (`DOCKER_COMMANDS.md`): Reference for running Django commands in containers

## Architecture

### Flutter App (`nomad_notes/`)

The Flutter app follows a feature-based architecture with Riverpod for state management:

**Structure:**
- `lib/app/` - App-level configuration (router, theme)
- `lib/core/` - Shared infrastructure (API client, storage, config)
- `lib/features/` - Feature modules organized by domain

**Key Patterns:**
- **Riverpod providers** for dependency injection and state management
- **go_router** with authentication-aware redirects (see `lib/app/router.dart`)
- **Feature structure**: Each feature has `data/`, `application/`, `domain/`, `presentation/` layers
- **Token management**: JWT tokens stored via `flutter_secure_storage`, with automatic refresh on 401 responses (see `lib/features/auth/application/auth_controller.dart`)
- **API client**: Centralized Dio instance configured in `lib/core/network/api_client.dart`

**Authentication Flow:**
- App bootstraps by checking stored tokens in `AuthController._bootstrap()`
- Router redirects based on `AuthStatus` (unknown/signedOut/signedIn)
- Splash page shown during initial auth check
- Automatic token refresh attempted before signing out on 401 errors

### Backend (`backend/`)

Django REST Framework API with JWT authentication using SimpleJWT:

**Apps:**
- `apps.accounts` - Custom User model and authentication endpoints
- `apps.notes` - Note CRUD with per-user ownership filtering

**Key Configuration:**
- Custom `AUTH_USER_MODEL` (`apps.accounts.User`)
- Token rotation and blacklisting enabled for security
- CORS configured for development (localhost/127.0.0.1)
- SQLite default, PostgreSQL optional via `DATABASE_URL`
- Environment-based config via `django-environ`

**API Structure:**
- All endpoints under `/api/` prefix
- JWT tokens required except for signup/signin
- OpenAPI docs at `/api/docs/` via drf-spectacular

## Development Commands

### Flutter App

```bash
cd nomad_notes

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run

# Run with specific device
flutter devices
flutter run -d <device-id>

# Analyze code
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Format code
dart format .

# Build for release
flutter build apk        # Android
flutter build ios        # iOS
```

### Django Backend

```bash
cd backend

# Setup virtual environment (using uv)
uv venv .venv
uv sync

# Install dev dependencies
uv sync --group dev

# Run migrations
uv run python manage.py migrate

# Create superuser
uv run python manage.py createsuperuser

# Run development server
uv run python manage.py runserver 0.0.0.0:8000

# Run tests
uv run pytest

# Run specific test
uv run pytest tests/test_auth_flow.py

# Lint with Ruff
uv run ruff check .
uv run ruff format .

# Make migrations
uv run python manage.py makemigrations

# Access Django shell
uv run python manage.py shell
```

### Docker Compose

```bash
# Build and start backend + database
docker compose up

# Build backend only
docker compose build backend

# Run backend only (SQLite)
docker compose up backend

# Run detached
docker compose up -d

# View logs
docker compose logs -f backend

# Stop services
docker compose down
```

## Configuration

### Backend Environment

Create `backend/.env` for local configuration:

```
DJANGO_DEBUG=True
DJANGO_SECRET_KEY=your-secret-key
ALLOWED_HOSTS=localhost,127.0.0.1
DATABASE_URL=sqlite:///db.sqlite3
ACCESS_TOKEN_MINUTES=15
REFRESH_TOKEN_DAYS=7
CORS_ALLOW_ALL_ORIGINS=True
```

For PostgreSQL: `DATABASE_URL=postgres://nomad:nomad@localhost:5432/nomad_notes`

### Flutter API Configuration

Backend URL configured in `nomad_notes/lib/core/config/api_config.dart`. Update for different environments (local, staging, production).

## Testing

### Backend Tests

Django tests use pytest-django. Test files in `backend/tests/` and app-level `tests.py` files.

Example: `backend/tests/test_auth_flow.py` tests the complete signup/signin/refresh flow.

### Flutter Tests

Widget tests in `nomad_notes/test/`. Follow Flutter's testing conventions with `_test.dart` suffix.

## API Endpoints

**Authentication:**
- `POST /api/auth/signup/` - Create account (email, password, full_name)
- `POST /api/auth/signin/` - Login (email, password) → returns access/refresh tokens
- `POST /api/auth/refresh/` - Refresh token rotation
- `POST /api/auth/signout/` - Blacklist refresh token
- `GET /api/auth/me/` - Get current user profile

**Notes:**
- `GET /api/notes/` - List user's notes
- `POST /api/notes/` - Create note (title, body)
- `GET /api/notes/<uuid>/` - Get specific note
- `PATCH /api/notes/<uuid>/` - Update note
- `DELETE /api/notes/<uuid>/` - Delete note

All note endpoints require Bearer token authentication and automatically filter by owner.

## Code Style

**Flutter:**
- Follow `analysis_options.yaml` linting rules
- Use `dart format` for consistent formatting
- Prefer const constructors where possible
- Use Material 3 design system

**Python:**
- Ruff configured with 100 char line length
- Import sorting enabled (Ruff rule "I")
- Type hints preferred (see `from __future__ import annotations`)
- Django best practices (migrations, ORM usage)
