from __future__ import annotations

from rest_framework import serializers

from .models import Note


class NoteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Note
        fields = ('id', 'title', 'body', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at')
