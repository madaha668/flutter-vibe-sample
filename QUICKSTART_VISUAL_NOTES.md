# Quick Start: Visual Notes Feature

Get up and running with the new visual notes feature in 5 minutes!

## Prerequisites

- Docker and Docker Compose installed
- Flutter SDK installed (for mobile app)
- A mobile device or emulator

## Step 1: Start the Backend

```bash
# Navigate to project root
cd /path/to/flutter-vibe-sample

# Start backend (migrations run automatically)
docker compose up backend

# Wait for: "Listening at: http://0.0.0.0:8000"
```

**What happens:**
- Backend container builds with Tesseract OCR
- Database migrations run automatically (including new `NoteImage` table)
- Media directory created for image storage
- Server starts on port 8000

## Step 2: Create a User

```bash
# In a new terminal, create a superuser
docker compose exec -it backend uv run python manage.py createsuperuser

# Enter: email, password, full name
```

## Step 3: Configure Flutter App

Update the API URL for your environment:

**File:** `nomad_notes/lib/core/config/api_config.dart`

```dart
class ApiConfig {
  // Choose based on your setup:

  // Android Emulator
  static const String baseUrl = 'http://10.0.2.2:8000';

  // iOS Simulator
  // static const String baseUrl = 'http://localhost:8000';

  // Physical Device (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:8000';
}
```

**Update ALLOWED_HOSTS:**

Edit `docker-compose.yml` to include your IP:

```yaml
environment:
  - ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2,192.168.1.100
```

Restart backend: `docker compose restart backend`

## Step 4: Run Flutter App

```bash
cd nomad_notes

# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run
```

## Step 5: Test Visual Notes

1. **Sign in** with the user you created

2. **Create a note with photo:**
   - Tap the **"New note"** button
   - Enter a title (e.g., "My First Photo Note")
   - Optionally add body text
   - Tap **"Camera"** to take a photo or **"Gallery"** to select one
   - Review the image preview
   - Tap **"Save"**

3. **View the note:**
   - Note appears in the list with a thumbnail
   - Tap the note to see full details
   - Image displays with "Analyzing image..." status

4. **Wait for OCR processing:**
   - Pull down to refresh the list (or wait 5-10 seconds)
   - Tap the note again
   - You should now see:
     - **Extracted Text** (if image contained text)
     - **Detected Objects** as chips
     - Status changed to "completed"

## Verification Checklist

- [ ] Backend running on port 8000
- [ ] Flutter app connects to backend
- [ ] Can sign in successfully
- [ ] Camera/Gallery buttons work
- [ ] Image uploads successfully
- [ ] Thumbnail shows in note list
- [ ] Full image displays in detail view
- [ ] OCR text extracts (if image has text)
- [ ] Object labels appear

## Troubleshooting

### "Cannot connect to backend"

**Fix API URL:**
```bash
# Find your computer's IP
ipconfig getifaddr en0  # macOS
hostname -I             # Linux
ipconfig               # Windows

# Update nomad_notes/lib/core/config/api_config.dart
# Update docker-compose.yml ALLOWED_HOSTS
# Restart: docker compose restart backend
```

### "Image upload fails"

**Check file size:**
- Must be ≤10 MB
- Only jpeg, png, gif, webp supported

**Check logs:**
```bash
docker compose logs -f backend
```

### "OCR not working"

**Verify Tesseract installed:**
```bash
docker compose exec backend tesseract --version
# Should show: tesseract 4.x.x
```

**Check analysis status:**
```bash
docker compose exec -it backend uv run python manage.py shell

>>> from apps.notes.models import NoteImage
>>> img = NoteImage.objects.last()
>>> print(img.analysis_status)  # Should be 'completed'
>>> print(img.ocr_text)         # Should have extracted text
>>> print(img.analysis_error)   # Should be empty
```

### "Migrations not applied"

Migrations should run automatically, but if needed:
```bash
docker compose exec backend uv run python manage.py migrate
```

### Camera/Gallery permissions denied (iOS)

Edit `nomad_notes/ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Take photos for your notes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Select photos for your notes</string>
```

## Testing OCR with Sample Images

Try these for best OCR results:
- 📄 Screenshot of text document
- 📋 Photo of a receipt
- 📖 Picture of a book page
- 🪧 Sign or label with clear text

Avoid:
- ❌ Very blurry images
- ❌ Handwritten text (Tesseract struggles with cursive)
- ❌ Very small text
- ❌ Images with no text (OCR will be empty, which is expected)

## What's Next?

**Explore the code:**
- Backend: `backend/apps/notes/models.py` (NoteImage model)
- Backend: `backend/apps/notes/vision.py` (OCR logic)
- Flutter: `nomad_notes/lib/features/home/presentation/home_page.dart` (UI)

**Read detailed docs:**
- `VISUAL_NOTES_IMPLEMENTATION.md` - Full implementation guide
- `DOCKER_COMMANDS.md` - Docker command reference
- `VISUAL.md` - Original feature specification

**Extend the feature:**
- Add cloud vision services (Google Vision API)
- Support multiple images per note
- Add image compression
- Implement search by OCR text

## Quick Commands Reference

```bash
# Start backend
docker compose up backend

# View logs
docker compose logs -f backend

# Create user
docker compose exec -it backend uv run python manage.py createsuperuser

# Run Flutter app
cd nomad_notes && flutter run

# Check uploaded images
ls -lh media/notes/

# Access admin panel
open http://localhost:8000/admin/

# API documentation
open http://localhost:8000/api/docs/
```

## Support

- **Backend logs:** `docker compose logs -f backend`
- **Flutter logs:** Already shown in terminal
- **Database:** `docker compose exec -it backend uv run python manage.py dbshell`
- **Django shell:** `docker compose exec -it backend uv run python manage.py shell`

---

**Happy coding! 🚀📸**

Your visual notes feature is ready to capture, analyze, and organize images with powerful OCR and object detection!
