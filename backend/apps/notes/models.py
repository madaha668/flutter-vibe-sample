from __future__ import annotations

import hashlib
import uuid

from django.conf import settings
from django.db import models
from django.utils import timezone


def note_image_upload_path(instance: NoteImage, filename: str) -> str:
    """Generate upload path: notes/<note_id>/<filename>"""
    return f'notes/{instance.note.id}/{filename}'


class Note(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notes',
    )
    title = models.CharField(max_length=200)
    body = models.TextField(blank=True)
    created_at = models.DateTimeField(default=timezone.now)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-updated_at']

    def __str__(self) -> str:  # pragma: no cover - debug representation
        return self.title


class NoteImage(models.Model):
    """Stores image attachment for a note with OCR and object detection results."""

    class AnalysisStatus(models.TextChoices):
        PENDING = 'pending', 'Pending'
        PROCESSING = 'processing', 'Processing'
        COMPLETED = 'completed', 'Completed'
        FAILED = 'failed', 'Failed'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    note = models.OneToOneField(
        Note,
        on_delete=models.CASCADE,
        related_name='image',
    )
    image = models.ImageField(upload_to=note_image_upload_path)
    file_size = models.PositiveIntegerField(help_text='File size in bytes')
    checksum = models.CharField(max_length=64, help_text='SHA256 hash of the image')

    # Analysis fields
    analysis_status = models.CharField(
        max_length=20,
        choices=AnalysisStatus.choices,
        default=AnalysisStatus.PENDING,
    )
    ocr_text = models.TextField(blank=True, help_text='Extracted text from OCR')
    object_labels = models.JSONField(
        default=list,
        help_text='List of detected objects/labels',
    )
    analysis_error = models.TextField(blank=True, help_text='Error message if analysis failed')

    uploaded_at = models.DateTimeField(default=timezone.now)

    class Meta:
        ordering = ['-uploaded_at']

    def __str__(self) -> str:  # pragma: no cover - debug representation
        return f'Image for {self.note.title}'

    def calculate_checksum(self) -> str:
        """Calculate SHA256 checksum of the image file."""
        sha256 = hashlib.sha256()
        for chunk in self.image.chunks():
            sha256.update(chunk)
        return sha256.hexdigest()
