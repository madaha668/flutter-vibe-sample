/**
 * Notes API Types
 *
 * Matches Django backend /api/notes/ endpoints
 */

export interface Note {
  id: string;
  title: string;
  body: string;
  created_at: string;
  updated_at: string;
  owner: string;
}

export interface CreateNoteRequest {
  title: string;
  body: string;
}

export interface UpdateNoteRequest {
  title?: string;
  body?: string;
}
