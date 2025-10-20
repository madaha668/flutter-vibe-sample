# Visual Notes Implementation Guide

This document describes the implementation of the visual notes feature in Nomad Notes, which allows users to attach photos to notes with automatic OCR (text extraction) and object detection.

## Features

- **Photo attachment**: Attach one photo per note (≤10 MB) from camera or gallery
- **OCR processing**: Automatic text extraction using Tesseract OCR
- **Object detection**: Identifies objects/labels in images (extensible to cloud AI services)
- **Async processing**: Images analyzed in background without blocking user
- **Status tracking**: Real-time analysis status (pending → processing → completed/failed)

## Backend Implementation

### Models (`backend/apps/notes/models.py`)

**NoteImage Model:**
- `note`: OneToOneField to Note (enforces one image per note)
- `image`: ImageField with dynamic upload path (`notes/<note_id>/<filename>`)
- `file_size`: Size in bytes
- `checksum`: SHA256 hash for integrity
- `analysis_status`: pending/processing/completed/failed
- `ocr_text`: Extracted text from image
- `object_labels`: JSON array of detected objects
- `analysis_error`: Error message if analysis fails

### API Changes

**Note Serializer** (`backend/apps/notes/serializers.py`):
- Added `image` field (read-only, nested NoteImageSerializer)
- Added `image_file` field (write-only, for multipart uploads)
- Returns full image URL, OCR results, and object labels

**Note ViewSet** (`backend/apps/notes/views.py`):
- Accepts `multipart/form-data` with optional `image_file`
- Validates image size (≤10 MB) and type (jpeg, png, gif, webp)
- Enforces one-image-per-note rule (replaces existing on update)
- Triggers async analysis after upload
- Calculates SHA256 checksum

### Vision Processing (`backend/apps/notes/vision.py`)

**VisionProvider Protocol:**
- Pluggable interface for AI vision services
- `analyze(image_path) -> VisionResult`
- Returns OCR text and object labels

**Implementations:**
- `DummyVisionProvider`: Returns placeholder results (no dependencies)
- `TesseractVisionProvider`: Uses Tesseract OCR + Pillow (local processing)
- `CompositeVisionProvider`: Combines multiple providers

**Extensibility:**
Update `get_vision_provider()` to use cloud services:
```python
# Example: Google Vision API, AWS Rekognition, etc.
return GoogleVisionProvider(api_key=settings.GOOGLE_VISION_KEY)
```

### Async Processing (`backend/apps/notes/tasks.py`)

**Background Analysis:**
- `analyze_note_image_async()`: Launches analysis in background thread
- Updates `NoteImage.analysis_status` through workflow
- Stores results or error message
- Thread-based (can be upgraded to Celery for production)

### Dependencies

**Required packages** (`backend/pyproject.toml`):
- `pillow>=10.0`: Image processing
- `pytesseract>=0.3`: Tesseract OCR Python wrapper

**System requirements** (Dockerfile):
- `tesseract-ocr`: OCR engine
- `libtesseract-dev`: Development headers

### Storage

**Media configuration** (`backend/nomad_backend/settings.py`):
```python
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'
```

**Docker volume** (`docker-compose.yml`):
```yaml
volumes:
  - $PWD/media:/app/media  # Persists uploaded images
```

Images stored at: `backend/media/notes/<note_id>/<filename>`

## Flutter Implementation

### Domain Model (`nomad_notes/lib/features/notes/domain/note.dart`)

**NoteImage class:**
- `imageUrl`: Full URL to image
- `fileSize`: Size in bytes
- `checksum`: SHA256 hash
- `analysisStatus`: pending/processing/completed/failed
- `ocrText`: Extracted text
- `objectLabels`: List of detected objects

**Note class:**
- Added optional `image` field

### Repository (`nomad_notes/lib/features/notes/data/notes_repository.dart`)

**Image upload support:**
- `createNote()` accepts optional `File? imageFile`
- Builds `FormData` with multipart/form-data
- Sends `image_file` field with proper MIME type
- Supports: jpeg, png, gif, webp

### UI Features

**Note Creation Dialog** (`nomad_notes/lib/features/home/presentation/home_page.dart`):
- Camera button: Captures photo using `ImagePicker`
- Gallery button: Selects from photo library
- Image preview with remove option
- Shows selected image before upload

**Note List:**
- Shows thumbnail for notes with images
- Photo icon indicator for visual notes
- Tap to view full note details

**Note Detail Dialog:**
- Full-size image display
- OCR text in highlighted box
- Object labels as chips
- Processing status indicator
- Error handling for failed loads

### Dependencies

**Required packages** (`nomad_notes/pubspec.yaml`):
- `image_picker: ^1.1.2`: Camera and gallery access
- `http_parser: ^4.0.2`: MIME type handling for uploads

### Platform Permissions

**iOS** (`nomad_notes/ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Take photos for your notes</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Select photos for your notes</string>
```

**Android** (`nomad_notes/android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

## API Endpoints

### Create Note with Image

```http
POST /api/notes/
Content-Type: multipart/form-data
Authorization: Bearer <access_token>

title=My Photo Note
body=Description of the photo
image_file=<binary image data>
```

**Response:**
```json
{
  "id": "uuid",
  "title": "My Photo Note",
  "body": "Description",
  "created_at": "2025-10-20T...",
  "updated_at": "2025-10-20T...",
  "image": {
    "id": "uuid",
    "image_url": "http://localhost:8000/media/notes/uuid/image.jpg",
    "file_size": 524288,
    "checksum": "sha256...",
    "analysis_status": "pending",
    "ocr_text": "",
    "object_labels": [],
    "uploaded_at": "2025-10-20T..."
  }
}
```

### Get Note (after analysis completes)

```http
GET /api/notes/<uuid>/
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "id": "uuid",
  "title": "My Photo Note",
  "body": "Description",
  "image": {
    "analysis_status": "completed",
    "ocr_text": "Extracted text from the image...",
    "object_labels": ["document", "text", "paper"],
    ...
  }
}
```

## Development Workflow

### Run Backend with Image Support

```bash
cd backend

# Install dependencies
uv sync

# Run migrations
uv run python manage.py migrate

# Start server
uv run python manage.py runserver 0.0.0.0:8000
```

**Note:** Tesseract must be installed on your system:
- **macOS**: `brew install tesseract`
- **Ubuntu/Debian**: `apt-get install tesseract-ocr`
- **Windows**: Download from [GitHub](https://github.com/UB-Mannheim/tesseract/wiki)

### Run Flutter App

```bash
cd nomad_notes

# Get dependencies
flutter pub get

# Run on device
flutter run

# For iOS simulator permissions, grant camera/photos access in Settings
```

### Docker Deployment

```bash
# Build and start (includes Tesseract in container)
docker compose up --build backend

# Media files persisted to ./media/
# Database at ./sqlite-data/
```

## Testing

### Manual Testing

1. **Create note with image:**
   - Tap "New note"
   - Add title and body
   - Tap "Camera" or "Gallery"
   - Select/capture image
   - Tap "Save"

2. **Verify upload:**
   - Note appears in list with thumbnail
   - Tap note to view details
   - Image loads successfully

3. **Check OCR processing:**
   - Wait a few seconds
   - Refresh notes list (pull down)
   - View note detail
   - OCR text should appear if image contains text

4. **Test validation:**
   - Try uploading >10 MB image (should fail)
   - Try invalid file type (should fail)

### Backend Tests

Create tests in `backend/tests/test_visual_notes.py`:

```python
def test_upload_image_with_note(authenticated_client):
    # Test image upload, validation, and analysis
    pass

def test_image_size_validation(authenticated_client):
    # Test 10 MB limit enforcement
    pass

def test_ocr_processing(authenticated_client):
    # Test Tesseract integration
    pass
```

## Troubleshooting

### Image Upload Fails

- **Check file size**: Must be ≤10 MB
- **Check file type**: Only jpeg, png, gif, webp
- **Check permissions**: Ensure media directory is writable

### OCR Not Working

- **Tesseract not installed**: Install via package manager
- **pytesseract not found**: Check `pip list | grep pytesseract`
- **Check logs**: Look for errors in Django console

### Images Not Loading in Flutter

- **CORS issues**: Ensure `CORS_ALLOW_ALL_ORIGINS=True` in dev
- **Network**: Check API URL in `lib/core/config/api_config.dart`
- **HTTPS**: If using HTTPS backend, ensure valid certificate

## Future Enhancements

1. **Cloud Vision Services:**
   - Integrate Google Vision API, AWS Rekognition, or Azure Computer Vision
   - Better object detection and scene understanding
   - Face detection, landmark recognition

2. **Image Compression:**
   - Client-side compression before upload
   - Reduce bandwidth and storage

3. **Multiple Images:**
   - Support multiple images per note
   - Gallery view for note images

4. **Search by OCR:**
   - Full-text search across OCR text
   - Filter notes by detected objects

5. **Image Editing:**
   - Crop, rotate, filters before upload
   - Annotations and drawings

6. **Storage Optimization:**
   - Move to cloud storage (S3, GCS)
   - Image CDN for faster loading
   - Automatic cleanup of old images

## Security Considerations

- **File size limits**: Enforced server-side (10 MB)
- **Content type validation**: Only allow image types
- **Path traversal**: Upload paths generated securely
- **Checksum verification**: SHA256 ensures integrity
- **Authentication**: All endpoints require JWT token
- **CORS**: Configure properly for production

## Performance

- **Async processing**: Images analyzed in background
- **Lazy loading**: Images loaded on-demand in UI
- **Caching**: Browser caches images by URL
- **Thumbnails**: Consider generating thumbnails for list view

---

**Implementation Date**: October 2025
**Backend Framework**: Django 5.1+ with DRF
**Frontend Framework**: Flutter 3.9+
**OCR Engine**: Tesseract 4.x+
