import React from 'react';
import { StyleSheet } from 'react-native';
import { Card, Text, IconButton } from 'react-native-paper';
import type { Note } from '../api/notes-types';

interface NoteCardProps {
  note: Note;
  onPress: () => void;
  onDelete: () => void;
}

/**
 * Note Card Component
 *
 * Displays a single note in the list
 */

export default function NoteCard({ note, onPress, onDelete }: NoteCardProps) {
  const formattedDate = new Date(note.updated_at).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  return (
    <Card style={styles.card} onPress={onPress}>
      <Card.Content>
        <Text variant="titleMedium" numberOfLines={1} style={styles.title}>
          {note.title}
        </Text>
        <Text variant="bodyMedium" numberOfLines={2} style={styles.body}>
          {note.body}
        </Text>
        <Text variant="bodySmall" style={styles.date}>
          {formattedDate}
        </Text>
      </Card.Content>
      <Card.Actions>
        <IconButton
          icon="delete"
          size={20}
          onPress={onDelete}
        />
      </Card.Actions>
    </Card>
  );
}

const styles = StyleSheet.create({
  card: {
    marginHorizontal: 16,
    marginVertical: 8,
  },
  title: {
    fontWeight: 'bold',
    marginBottom: 4,
  },
  body: {
    color: '#666',
    marginBottom: 8,
  },
  date: {
    color: '#999',
  },
});
