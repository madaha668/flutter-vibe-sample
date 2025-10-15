import React, { useState } from 'react';
import { View, FlatList, StyleSheet } from 'react-native';
import { FAB, Text, ActivityIndicator, Snackbar } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { useNotes, useDeleteNote } from '../hooks/useNotes';
import { getErrorMessage } from '@/core/utils/error-handler';
import NoteCard from '../components/NoteCard';
import type { Note } from '../api/notes-types';

/**
 * Notes List Screen
 *
 * Main screen showing all user notes
 */

export default function NotesListScreen() {
  const navigation = useNavigation();
  const { data: notes, isLoading, error } = useNotes();
  const deleteNote = useDeleteNote();
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const handleNotePress = (note: Note) => {
    navigation.navigate('NoteEditor' as never, { noteId: note.id } as never);
  };

  const handleDeleteNote = (note: Note) => {
    deleteNote.mutate(note.id, {
      onSuccess: () => {
        setSnackbarMessage('Note deleted');
      },
      onError: (err) => {
        setSnackbarMessage(getErrorMessage(err));
      },
    });
  };

  const handleCreateNote = () => {
    navigation.navigate('NoteEditor' as never);
  };

  if (isLoading) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.centerContainer}>
        <Text variant="bodyLarge">{getErrorMessage(error)}</Text>
      </View>
    );
  }

  if (!notes || notes.length === 0) {
    return (
      <View style={styles.centerContainer}>
        <Text variant="bodyLarge" style={styles.emptyText}>
          No notes yet. Tap + to create your first note!
        </Text>
        <FAB
          icon="plus"
          style={styles.fab}
          onPress={handleCreateNote}
        />
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <FlatList
        data={notes}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <NoteCard
            note={item}
            onPress={() => handleNotePress(item)}
            onDelete={() => handleDeleteNote(item)}
          />
        )}
        contentContainerStyle={styles.listContent}
      />
      <FAB
        icon="plus"
        style={styles.fab}
        onPress={handleCreateNote}
      />
      <Snackbar
        visible={!!snackbarMessage}
        onDismiss={() => setSnackbarMessage('')}
        duration={3000}
      >
        {snackbarMessage}
      </Snackbar>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  listContent: {
    paddingVertical: 8,
  },
  emptyText: {
    textAlign: 'center',
    color: '#666',
  },
  fab: {
    position: 'absolute',
    right: 16,
    bottom: 16,
  },
});
