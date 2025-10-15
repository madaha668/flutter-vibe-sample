import { apiClient } from '@/core/api/client';
import { API_ENDPOINTS } from '@/core/config/api-config';
import type { Note, CreateNoteRequest, UpdateNoteRequest } from './notes-types';

/**
 * Notes API Service
 *
 * All endpoints under /api/notes/
 */

export const notesApi = {
  /**
   * List all notes for current user
   * GET /api/notes/
   */
  list: async (): Promise<Note[]> => {
    const response = await apiClient.get<Note[]>(API_ENDPOINTS.NOTES.LIST);
    return response.data;
  },

  /**
   * Get a specific note by ID
   * GET /api/notes/:id/
   */
  get: async (id: string): Promise<Note> => {
    const response = await apiClient.get<Note>(API_ENDPOINTS.NOTES.DETAIL(id));
    return response.data;
  },

  /**
   * Create a new note
   * POST /api/notes/
   */
  create: async (data: CreateNoteRequest): Promise<Note> => {
    const response = await apiClient.post<Note>(API_ENDPOINTS.NOTES.LIST, data);
    return response.data;
  },

  /**
   * Update an existing note
   * PATCH /api/notes/:id/
   */
  update: async (id: string, data: UpdateNoteRequest): Promise<Note> => {
    const response = await apiClient.patch<Note>(
      API_ENDPOINTS.NOTES.DETAIL(id),
      data
    );
    return response.data;
  },

  /**
   * Delete a note
   * DELETE /api/notes/:id/
   */
  delete: async (id: string): Promise<void> => {
    await apiClient.delete(API_ENDPOINTS.NOTES.DETAIL(id));
  },
};
