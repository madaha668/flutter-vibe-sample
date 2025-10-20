"""Vision processing services for image analysis (OCR and object detection)."""

from __future__ import annotations

import logging
from abc import ABC, abstractmethod
from dataclasses import dataclass
from pathlib import Path
from typing import Protocol

logger = logging.getLogger(__name__)


@dataclass
class VisionResult:
    """Result from vision processing."""

    ocr_text: str = ''
    object_labels: list[str] = None
    success: bool = True
    error: str = ''

    def __post_init__(self):
        if self.object_labels is None:
            self.object_labels = []


class VisionProvider(Protocol):
    """Protocol for vision analysis providers."""

    def analyze(self, image_path: str | Path) -> VisionResult:
        """Analyze an image and return OCR text and object labels."""
        ...


class DummyVisionProvider:
    """Dummy vision provider for testing (returns placeholder results)."""

    def analyze(self, image_path: str | Path) -> VisionResult:
        """Return dummy analysis results."""
        logger.info(f'DummyVisionProvider analyzing {image_path}')
        return VisionResult(
            ocr_text='[OCR not configured - install Tesseract for real text extraction]',
            object_labels=['photo', 'image'],
            success=True,
        )


class TesseractVisionProvider:
    """Vision provider using Tesseract OCR for text extraction."""

    def __init__(self):
        try:
            import pytesseract
            from PIL import Image

            self.pytesseract = pytesseract
            self.Image = Image
            self._available = True
        except ImportError:
            logger.warning('pytesseract or Pillow not installed. OCR will not be available.')
            self._available = False

    def analyze(self, image_path: str | Path) -> VisionResult:
        """Extract text using Tesseract OCR."""
        if not self._available:
            return VisionResult(
                ocr_text='',
                object_labels=[],
                success=False,
                error='Tesseract not available - install pytesseract and Pillow',
            )

        try:
            image = self.Image.open(image_path)
            ocr_text = self.pytesseract.image_to_string(image).strip()

            logger.info(f'Tesseract OCR extracted {len(ocr_text)} characters from {image_path}')

            return VisionResult(
                ocr_text=ocr_text,
                object_labels=['document', 'text'] if ocr_text else [],
                success=True,
            )
        except Exception as e:
            logger.error(f'Tesseract OCR failed for {image_path}: {e}')
            return VisionResult(
                ocr_text='',
                object_labels=[],
                success=False,
                error=str(e),
            )


class CompositeVisionProvider:
    """Combines multiple vision providers for comprehensive analysis."""

    def __init__(self, providers: list[VisionProvider] | None = None):
        self.providers = providers or [TesseractVisionProvider()]

    def analyze(self, image_path: str | Path) -> VisionResult:
        """Run all providers and merge results."""
        all_ocr_text = []
        all_labels = set()
        errors = []

        for provider in self.providers:
            result = provider.analyze(image_path)
            if result.success:
                if result.ocr_text:
                    all_ocr_text.append(result.ocr_text)
                all_labels.update(result.object_labels)
            else:
                errors.append(f'{provider.__class__.__name__}: {result.error}')

        return VisionResult(
            ocr_text='\n\n'.join(all_ocr_text),
            object_labels=sorted(list(all_labels)),
            success=len(errors) < len(self.providers),  # Success if at least one provider worked
            error='; '.join(errors) if errors else '',
        )


def get_vision_provider() -> VisionProvider:
    """Factory function to get the configured vision provider."""
    # For now, use Tesseract. In production, this could be configured via settings
    # to use cloud providers like Google Vision API, AWS Rekognition, etc.
    return TesseractVisionProvider()
