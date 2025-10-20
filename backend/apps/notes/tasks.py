"""Background tasks for image analysis."""

from __future__ import annotations

import logging
import threading

from .models import NoteImage
from .vision import get_vision_provider

logger = logging.getLogger(__name__)


def analyze_note_image(note_image_id: str) -> None:
    """Analyze a note image using the configured vision provider."""
    try:
        note_image = NoteImage.objects.get(id=note_image_id)

        # Update status to processing
        note_image.analysis_status = NoteImage.AnalysisStatus.PROCESSING
        note_image.save(update_fields=['analysis_status'])

        # Get vision provider and analyze
        provider = get_vision_provider()
        result = provider.analyze(note_image.image.path)

        # Update note image with results
        if result.success:
            note_image.analysis_status = NoteImage.AnalysisStatus.COMPLETED
            note_image.ocr_text = result.ocr_text
            note_image.object_labels = result.object_labels
            note_image.analysis_error = ''
            logger.info(f'Successfully analyzed image {note_image_id}')
        else:
            note_image.analysis_status = NoteImage.AnalysisStatus.FAILED
            note_image.analysis_error = result.error
            logger.error(f'Failed to analyze image {note_image_id}: {result.error}')

        note_image.save(update_fields=['analysis_status', 'ocr_text', 'object_labels', 'analysis_error'])

    except NoteImage.DoesNotExist:
        logger.error(f'NoteImage {note_image_id} not found')
    except Exception as e:
        logger.exception(f'Unexpected error analyzing image {note_image_id}: {e}')
        try:
            note_image = NoteImage.objects.get(id=note_image_id)
            note_image.analysis_status = NoteImage.AnalysisStatus.FAILED
            note_image.analysis_error = str(e)
            note_image.save(update_fields=['analysis_status', 'analysis_error'])
        except Exception:
            pass


def analyze_note_image_async(note_image_id: str) -> None:
    """Launch image analysis in a background thread."""
    thread = threading.Thread(
        target=analyze_note_image,
        args=(note_image_id,),
        daemon=True,
    )
    thread.start()
    logger.info(f'Started background analysis for image {note_image_id}')
