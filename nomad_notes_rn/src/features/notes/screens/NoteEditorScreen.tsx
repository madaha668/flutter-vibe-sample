import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';
import { TextInput, Button, Appbar, ActivityIndicator, Snackbar } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { useNote, useCreateNote, useUpdateNote } from '../hooks/useNotes';
import { getErrorMessage } from '@/core/utils/error-handler';

type RouteParams = {
  NoteEditor: {
    noteId?: string;
  };
};

/**
 * Note Editor Screen
 *
 * Create or edit a note
 */

export default function NoteEditorScreen() {
  const navigation = useNavigation();
  const route = useRoute<RouteProp<RouteParams, 'NoteEditor'>>();
  const noteId = route.params?.noteId;

  const { data: note, isLoading } = useNote(noteId || '');
  const createNote = useCreateNote();
  const updateNote = useUpdateNote();

  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [error, setError] = useState('');

  const isEditing = !!noteId;

  useEffect(() => {
    if (note) {
      setTitle(note.title);
      setBody(note.body);
    }
  }, [note]);

  const handleSave = () => {
    if (!title.trim()) {
      setError('Title is required');
      return;
    }

    if (isEditing && noteId) {
      updateNote.mutate(
        { id: noteId, data: { title, body } },
        {
          onSuccess: () => {
            navigation.goBack();
          },
          onError: (err) => {
            setError(getErrorMessage(err));
          },
        }
      );
    } else {
      createNote.mutate(
        { title, body },
        {
          onSuccess: () => {
            navigation.goBack();
          },
          onError: (err) => {
            setError(getErrorMessage(err));
          },
        }
      );
    }
  };

  const isSaving = createNote.isPending || updateNote.isPending;

  if (isLoading && isEditing) {
    return (
      <View style={styles.centerContainer}>
        <ActivityIndicator size="large" />
      </View>
    );
  }

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <Appbar.Header>
        <Appbar.BackAction onPress={() => navigation.goBack()} />
        <Appbar.Content title={isEditing ? 'Edit Note' : 'New Note'} />
        <Appbar.Action
          icon="check"
          onPress={handleSave}
          disabled={isSaving}
        />
      </Appbar.Header>

      <ScrollView style={styles.content}>
        <TextInput
          label="Title"
          value={title}
          onChangeText={setTitle}
          mode="outlined"
          style={styles.titleInput}
          disabled={isSaving}
        />

        <TextInput
          label="Note"
          value={body}
          onChangeText={setBody}
          mode="outlined"
          multiline
          numberOfLines={10}
          style={styles.bodyInput}
          disabled={isSaving}
        />
      </ScrollView>

      <Snackbar
        visible={!!error}
        onDismiss={() => setError('')}
        duration={4000}
      >
        {error}
      </Snackbar>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  content: {
    flex: 1,
    padding: 16,
  },
  titleInput: {
    marginBottom: 16,
  },
  bodyInput: {
    minHeight: 200,
  },
});
