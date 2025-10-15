import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { notesApi } from '../api/notes-api';
import { getErrorMessage } from '@/core/utils/error-handler';
import type { CreateNoteRequest, UpdateNoteRequest } from '../api/notes-types';

/**
 * Notes Hooks (React Query)
 *
 * Manages notes queries and mutations with automatic cache invalidation
 */

const QUERY_KEYS = {
  notes: ['notes'] as const,
  note: (id: string) => ['notes', id] as const,
};

export const useNotes = () => {
  return useQuery({
    queryKey: QUERY_KEYS.notes,
    queryFn: notesApi.list,
    staleTime: 30000, // 30 seconds
  });
};

export const useNote = (id: string) => {
  return useQuery({
    queryKey: QUERY_KEYS.note(id),
    queryFn: () => notesApi.get(id),
    enabled: !!id,
  });
};

export const useCreateNote = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateNoteRequest) => notesApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEYS.notes });
    },
    onError: (error) => {
      console.error('[CreateNote] Failed:', getErrorMessage(error));
    },
  });
};

export const useUpdateNote = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateNoteRequest }) =>
      notesApi.update(id, data),
    onSuccess: (updatedNote) => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEYS.notes });
      queryClient.invalidateQueries({ queryKey: QUERY_KEYS.note(updatedNote.id) });
    },
    onError: (error) => {
      console.error('[UpdateNote] Failed:', getErrorMessage(error));
    },
  });
};

export const useDeleteNote = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => notesApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: QUERY_KEYS.notes });
    },
    onError: (error) => {
      console.error('[DeleteNote] Failed:', getErrorMessage(error));
    },
  });
};
