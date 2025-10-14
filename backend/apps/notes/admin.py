from django.contrib import admin

from .models import Note


@admin.register(Note)
class NoteAdmin(admin.ModelAdmin):
    list_display = ('title', 'owner', 'updated_at', 'created_at')
    list_filter = ('created_at', 'updated_at')
    search_fields = ('title', 'body', 'owner__email')
    ordering = ('-updated_at',)
