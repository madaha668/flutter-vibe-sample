from __future__ import annotations

from rest_framework import permissions, serializers as drf_serializers, status, viewsets
from rest_framework.response import Response

from .models import Note, NoteImage
from .serializers import NoteSerializer


# Image validation constants (10 MB limit as per spec)
MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10 MB in bytes
ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']


class NoteViewSet(viewsets.ModelViewSet):
    serializer_class = NoteSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_queryset(self):
        return Note.objects.filter(owner=self.request.user).select_related('image')

    def _validate_image(self, image_file):
        """Validate image file size and type."""
        # Check file size
        if image_file.size > MAX_IMAGE_SIZE:
            raise drf_serializers.ValidationError({
                'image_file': f'Image file too large. Maximum size is {MAX_IMAGE_SIZE // (1024 * 1024)} MB.'
            })

        # Check content type
        content_type = image_file.content_type
        if content_type not in ALLOWED_IMAGE_TYPES:
            raise drf_serializers.ValidationError({
                'image_file': f'Invalid image type. Allowed types: {", ".join(ALLOWED_IMAGE_TYPES)}.'
            })

    def _handle_image_upload(self, note: Note, image_file):
        """Create or update NoteImage for the given note."""
        # Delete existing image if present (enforce one-image-per-note rule)
        if hasattr(note, 'image'):
            note.image.delete()

        # Create new NoteImage
        note_image = NoteImage(
            note=note,
            image=image_file,
            file_size=image_file.size,
        )
        note_image.save()

        # Calculate and save checksum
        note_image.checksum = note_image.calculate_checksum()
        note_image.save(update_fields=['checksum'])

        # Trigger async analysis
        from .tasks import analyze_note_image_async
        analyze_note_image_async(str(note_image.id))

        return note_image

    def perform_create(self, serializer):
        image_file = self.request.data.get('image_file')

        if image_file:
            self._validate_image(image_file)

        note = serializer.save(owner=self.request.user)

        if image_file:
            self._handle_image_upload(note, image_file)

    def perform_update(self, serializer):
        image_file = self.request.data.get('image_file')

        if image_file:
            self._validate_image(image_file)

        note = serializer.save()

        if image_file:
            self._handle_image_upload(note, image_file)
