from __future__ import annotations

from rest_framework import serializers

from .models import Note, NoteImage


class NoteImageSerializer(serializers.ModelSerializer):
    """Serializer for NoteImage model."""

    image_url = serializers.SerializerMethodField()

    class Meta:
        model = NoteImage
        fields = (
            'id',
            'image_url',
            'file_size',
            'checksum',
            'analysis_status',
            'ocr_text',
            'object_labels',
            'uploaded_at',
        )
        read_only_fields = (
            'id',
            'checksum',
            'analysis_status',
            'ocr_text',
            'object_labels',
            'uploaded_at',
        )

    def get_image_url(self, obj: NoteImage) -> str | None:
        """Return full URL for the image."""
        if obj.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return None


class NoteSerializer(serializers.ModelSerializer):
    """Serializer for Note model with optional image support."""

    image = NoteImageSerializer(read_only=True)
    image_file = serializers.ImageField(write_only=True, required=False)

    class Meta:
        model = Note
        fields = ('id', 'title', 'body', 'created_at', 'updated_at', 'image', 'image_file')
        read_only_fields = ('id', 'created_at', 'updated_at', 'image')

    def create(self, validated_data):
        # Remove image_file from validated_data before creating Note
        validated_data.pop('image_file', None)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        # Remove image_file from validated_data before updating Note
        validated_data.pop('image_file', None)
        return super().update(instance, validated_data)
