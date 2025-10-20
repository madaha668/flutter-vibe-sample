# Docker Commands Reference

Quick reference for running Django commands in Docker containers.

## Starting Services

```bash
# Start backend (migrations run automatically via entrypoint.sh)
docker compose up backend

# Start in detached mode
docker compose up -d backend

# Rebuild and start (after code changes)
docker compose up --build backend
```

## Running Django Management Commands

### Run Migrations

```bash
# Migrations run automatically on container start via entrypoint.sh
# But you can also run manually:

docker compose exec backend uv run python manage.py migrate
```

### Create Superuser

```bash
docker compose exec -it backend uv run python manage.py createsuperuser
```

### Make Migrations (after model changes)

```bash
docker compose exec backend uv run python manage.py makemigrations
```

### Django Shell

```bash
docker compose exec -it backend uv run python manage.py shell
```

### Collect Static Files

```bash
docker compose exec backend uv run python manage.py collectstatic --noinput
```

### Run Tests

```bash
docker compose exec backend uv run pytest
```

## Database Commands

### Access SQLite Database

```bash
# SQLite database is at ./sqlite-data/nomad.sqlite3
sqlite3 sqlite-data/nomad.sqlite3

# Or use the Django dbshell
docker compose exec -it backend uv run python manage.py dbshell
```

### Reset Database (WARNING: Deletes all data!)

```bash
# Stop containers
docker compose down

# Delete database
rm -rf sqlite-data/

# Restart (migrations will run automatically)
docker compose up backend
```

## Media Files

### View Uploaded Images

```bash
# Media files stored in ./media/
ls -lh media/notes/

# View specific note's images
ls -lh media/notes/<note-uuid>/
```

### Backup Media Files

```bash
# Create backup
tar -czf media-backup-$(date +%Y%m%d).tar.gz media/

# Restore from backup
tar -xzf media-backup-20251020.tar.gz
```

## Logs and Debugging

### View Logs

```bash
# Follow logs in real-time
docker compose logs -f backend

# View last 100 lines
docker compose logs --tail=100 backend
```

### Execute Shell in Container

```bash
# Bash shell
docker compose exec -it backend bash

# Run commands inside container
docker compose exec backend ls -la /app/media/
docker compose exec backend ps aux
```

### Check Environment Variables

```bash
docker compose exec backend env | grep DJANGO
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker compose logs backend

# Check if migrations failed
docker compose logs backend | grep migrate

# Rebuild image from scratch
docker compose build --no-cache backend
docker compose up backend
```

### Migrations Out of Sync

```bash
# Option 1: Fake migrations (if schema already correct)
docker compose exec backend uv run python manage.py migrate --fake

# Option 2: Reset migrations (WARNING: Data loss!)
docker compose down
rm -rf sqlite-data/
docker compose up backend
```

### Image Analysis Not Working

```bash
# Check if Tesseract is installed
docker compose exec backend which tesseract
docker compose exec backend tesseract --version

# Check Python packages
docker compose exec backend uv run pip list | grep -E "(pillow|pytesseract)"

# Test OCR manually
docker compose exec -it backend uv run python manage.py shell
>>> from apps.notes.vision import get_vision_provider
>>> provider = get_vision_provider()
>>> result = provider.analyze('/app/media/notes/.../image.jpg')
>>> print(result.ocr_text)
```

### Permission Issues with Media Files

```bash
# Check permissions
ls -la media/

# Fix permissions (if needed)
sudo chown -R $USER:$USER media/
chmod -R 755 media/
```

## Production Commands

### Using PostgreSQL Instead of SQLite

Update `docker-compose.yml` backend environment:

```yaml
environment:
  - DATABASE_URL=postgres://nomad:nomad@db:5432/nomad_notes
```

Then:

```bash
# Start both backend and PostgreSQL
docker compose up backend db

# Migrations run automatically
```

### Using Gunicorn (Production Server)

The Dockerfile default CMD already uses Gunicorn:

```bash
# Build and run in production mode
docker compose build backend
docker compose up -d backend

# Check it's running with Gunicorn
docker compose exec backend ps aux | grep gunicorn
```

### Health Check

```bash
# Check if backend is responding
curl http://localhost:8000/api/docs/

# Check database connection
docker compose exec backend uv run python manage.py check --database default
```

## Quick Cheat Sheet

| Task | Command |
|------|---------|
| Start backend | `docker compose up backend` |
| Run migrations | Automatic on start, or `docker compose exec backend uv run python manage.py migrate` |
| Create superuser | `docker compose exec -it backend uv run python manage.py createsuperuser` |
| View logs | `docker compose logs -f backend` |
| Shell access | `docker compose exec -it backend bash` |
| Stop services | `docker compose down` |
| Rebuild | `docker compose up --build backend` |
| Run tests | `docker compose exec backend uv run pytest` |

## First Time Setup

```bash
# 1. Build and start backend
docker compose up --build backend

# 2. Migrations run automatically via entrypoint.sh

# 3. Create admin user
docker compose exec -it backend uv run python manage.py createsuperuser

# 4. Access admin panel
# Open http://localhost:8000/admin/

# 5. Access API docs
# Open http://localhost:8000/api/docs/
```

## Development Workflow

```bash
# 1. Make code changes in backend/

# 2. Rebuild and restart
docker compose up --build backend

# 3. If you changed models:
docker compose exec backend uv run python manage.py makemigrations
# Migrations will apply automatically on next restart

# 4. View logs to debug
docker compose logs -f backend
```

## Notes

- **Migrations**: Run automatically on container start via `entrypoint.sh`
- **Media files**: Persisted in `./media/` directory on host
- **Database**: SQLite stored in `./sqlite-data/` directory on host
- **Logs**: Use `docker compose logs` to view Django output
- **Port**: Backend accessible at `http://localhost:8000`

## Integration with Flutter App

The Flutter app connects to the backend at the URL specified in:
- `nomad_notes/lib/core/config/api_config.dart`

For local development with device/emulator:
- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://<your-computer-ip>:8000`

Update `ALLOWED_HOSTS` in docker-compose.yml to include your computer's IP:

```yaml
environment:
  - ALLOWED_HOSTS=localhost,127.0.0.1,192.168.1.100,10.0.2.2
```
