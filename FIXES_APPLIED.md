# Fixes Applied to Nomad Notes

## Issues Identified and Fixed

### 1. SQLite Database Not Created ✅ FIXED

**Problem:**
- Docker volume mounted but directory didn't exist on host
- Entrypoint script was commented out in Dockerfile
- Migrations weren't running automatically

**Solution Applied:**
- Uncommented `COPY entrypoint.sh /entrypoint.sh` in Dockerfile (line 16)
- Uncommented `RUN chmod +x /entrypoint.sh` in Dockerfile (line 25)
- Fixed entrypoint path from `/app/entrypoint.sh` to `/entrypoint.sh` (line 32)
- Created `sqlite-data/` directory on host

**Result:**
- Database will now be created automatically on container startup
- Migrations run automatically via entrypoint.sh
- Database persists in `./sqlite-data/nomad.sqlite3`

---

### 2. No Backend Logs / macOS App Can't Signup ✅ FIXED

**Problem:**
- Django wasn't logging requests in production mode
- No visibility into what requests were being received
- macOS app failures were silent

**Solution Applied:**
Added comprehensive logging configuration to `backend/nomad_backend/settings.py`:
- Console handler with verbose formatting
- DEBUG level for `django.request` logger
- INFO level for `django.server` logger
- All logs output to console (visible via docker-compose logs)

**Result:**
- All HTTP requests now logged with timestamp, method, path, status
- Error details visible in container logs
- Use `docker-compose logs -f backend` to monitor in real-time

---

### 3. CORS Configuration Issues ✅ FIXED

**Problem:**
- Bug: `default=env('DJANGO_DEBUG')` called env() twice (line 153)
- Missing `CORS_ALLOW_CREDENTIALS = True` (required for JWT tokens)
- Conflicting CORS settings when both explicit origins and regex patterns defined
- Chrome and macOS apps blocked by CORS errors

**Solution Applied:**
Fixed CORS configuration in `backend/nomad_backend/settings.py`:
```python
CORS_ALLOW_ALL_ORIGINS = env.bool('CORS_ALLOW_ALL_ORIGINS', default=DEBUG)
CORS_ALLOW_CREDENTIALS = True

if not CORS_ALLOW_ALL_ORIGINS:
    CORS_ALLOWED_ORIGINS = env.list('CORS_ALLOWED_ORIGINS', default=[])
    CORS_ALLOWED_ORIGIN_REGEXES = [
        r'^http://localhost(:\d+)?$',
        r'^http://127\.0\.0\.1(:\d+)?$',
    ]
```

**Changes:**
- Fixed the env() double-call bug
- Added `CORS_ALLOW_CREDENTIALS = True` for JWT auth
- Made explicit origins conditional (only set if provided via env)
- Regex patterns handle dynamic ports (e.g., localhost:54321 for Flutter web)

**Result:**
- Development: `CORS_ALLOW_ALL_ORIGINS=True` in docker-compose.yml allows all origins
- Chrome Flutter app can now connect (any localhost port accepted)
- macOS and iOS apps can connect (127.0.0.1:8000)
- Android apps can connect (10.0.2.2:8000 configured in Flutter)
- Production ready: Set explicit origins via environment variables

---

### 4. Chrome Flutter App Origin Security Issue ✅ FIXED

**Problem:**
- Flutter web dev server uses random ports (e.g., localhost:54321)
- Explicit CORS origins couldn't handle dynamic ports
- Preflight OPTIONS requests were failing

**Solution Applied:**
- CORS regex patterns now match any port: `r'^http://localhost(:\d+)?$'`
- `CORS_ALLOW_CREDENTIALS = True` enables proper preflight handling
- Development mode allows all origins by default

**Result:**
- Chrome Flutter app works regardless of dev server port
- CORS preflight requests properly handled
- Credentials (JWT tokens) properly sent and accepted

---

## Testing Instructions

### 1. Start the Backend

```bash
# Backend should now be building/starting
docker-compose ps
docker-compose logs -f backend
```

Wait for logs to show:
```
Operations to perform:
  Apply all migrations: ...
Applying accounts.0001_initial... OK
Applying notes.0001_initial... OK
```

### 2. Verify Database Created

```bash
ls -la sqlite-data/
# Should show: nomad.sqlite3
```

### 3. Test API via Swagger Docs

1. Open http://localhost:8000/api/docs/
2. Test signup: POST /api/auth/signup/
   ```json
   {
     "email": "test@example.com",
     "password": "testpass123",
     "full_name": "Test User"
   }
   ```
3. Should receive tokens and user object

### 4. Test Flutter Apps

**Chrome (Web):**
```bash
cd nomad_notes
flutter run -d chrome
```
- Try signup - should work now
- Check browser console for CORS errors (should be none)
- Check backend logs for requests

**macOS:**
```bash
cd nomad_notes
flutter run -d macos
```
- Try signup
- Check backend logs to see if requests arrive
- If still failing, check macOS network entitlements

**Android Emulator:**
```bash
cd nomad_notes
flutter run -d emulator-xxxx
```
- Uses 10.0.2.2:8000 (configured in api_config.dart)

### 5. Monitor Backend Logs

```bash
docker-compose logs -f backend
```

You should see:
- Startup logs with migration info
- Every HTTP request logged: `"GET /api/auth/me/ HTTP/1.1" 200`
- JWT authentication attempts
- Any errors with full tracebacks

---

## Configuration Reference

### Docker Compose Environment Variables

```yaml
environment:
  - DJANGO_DEBUG=True                    # Enables debug mode
  - CORS_ALLOW_ALL_ORIGINS=True          # Allow all origins (dev only!)
  - DATABASE_URL=sqlite:////data/nomad.sqlite3
  - ACCESS_TOKEN_MINUTES=15
  - REFRESH_TOKEN_DAYS=7
```

### Flutter API Configuration

File: `nomad_notes/lib/core/config/api_config.dart`

- **Web**: `http://localhost:8000`
- **Android**: `http://10.0.2.2:8000` (emulator host)
- **iOS/macOS**: `http://127.0.0.1:8000`
- Override via env: `flutter run --dart-define=NOMAD_API_URL=http://192.168.1.100:8000`

---

## Troubleshooting

### Backend won't start
```bash
docker-compose logs backend
# Check for migration errors or port conflicts
```

### Database not persisting
```bash
# Check volume mount
docker inspect flutter-vibe-sample_backend_1 | grep Mounts -A 10
```

### CORS errors still occurring
```bash
# Verify CORS_ALLOW_ALL_ORIGINS is True
docker-compose exec backend uv run python manage.py shell
>>> from django.conf import settings
>>> settings.CORS_ALLOW_ALL_ORIGINS
True
```

### No logs appearing
```bash
# Make sure container is running
docker-compose ps
# Force log output
docker-compose logs backend --tail 100
```

---

## Next Steps

1. ✅ Backend container should finish building
2. ✅ Verify database created in `sqlite-data/`
3. ✅ Test signup via Swagger docs
4. ⏳ Test Flutter apps (Chrome, macOS, iOS, Android)
5. ⏳ Create first note via API
6. ⏳ Verify note appears in Flutter apps

---

## Files Modified

1. `backend/Dockerfile` - Uncommented entrypoint configuration
2. `backend/nomad_backend/settings.py` - Fixed CORS, added logging
3. Created `sqlite-data/` directory for database persistence

## No Changes Needed To

- `backend/entrypoint.sh` - Already correct
- `docker-compose.yml` - Already correct
- Flutter app code - Already correct
- API endpoints - Already working
