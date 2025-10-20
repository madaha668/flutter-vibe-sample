from django.contrib import admin

from .models import Note, NoteImage


@admin.register(Note)
class NoteAdmin(admin.ModelAdmin):
    list_display = ('title', 'owner', 'has_image', 'updated_at', 'created_at')
    list_filter = ('created_at', 'updated_at')
    search_fields = ('title', 'body', 'owner__email')
    ordering = ('-updated_at',)

    def has_image(self, obj):
        return hasattr(obj, 'image')
    has_image.boolean = True
    has_image.short_description = 'Image'


@admin.register(NoteImage)
class NoteImageAdmin(admin.ModelAdmin):
    list_display = ('note', 'file_size', 'analysis_status', 'uploaded_at')
    list_filter = ('analysis_status', 'uploaded_at')
    search_fields = ('note__title', 'ocr_text')
    ordering = ('-uploaded_at',)
    readonly_fields = ('checksum', 'file_size', 'uploaded_at')
