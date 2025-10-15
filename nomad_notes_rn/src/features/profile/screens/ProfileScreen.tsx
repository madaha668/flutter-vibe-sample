import React, { useState } from 'react';
import { View, StyleSheet, ScrollView } from 'react-native';
import { Appbar, List, Button, Dialog, Portal, Text } from 'react-native-paper';
import { useAuthStore } from '@/features/auth/hooks/useAuthStore';
import { useCurrentUser } from '@/features/auth/hooks/useAuth';
import { useSignOut } from '@/features/auth/hooks/useAuth';

/**
 * Profile Screen
 *
 * Shows user information and account actions
 */

export default function ProfileScreen() {
  const user = useAuthStore((state) => state.user);
  const { data: currentUser } = useCurrentUser();
  const signOut = useSignOut();
  const [showSignOutDialog, setShowSignOutDialog] = useState(false);

  const displayUser = currentUser || user;

  const handleSignOut = () => {
    setShowSignOutDialog(false);
    signOut.mutate();
  };

  return (
    <View style={styles.container}>
      <Appbar.Header>
        <Appbar.Content title="Profile" />
      </Appbar.Header>

      <ScrollView style={styles.content}>
        <List.Section>
          <List.Subheader>Account Information</List.Subheader>
          <List.Item
            title="Name"
            description={displayUser?.full_name || 'Not available'}
            left={(props) => <List.Icon {...props} icon="account" />}
          />
          <List.Item
            title="Email"
            description={displayUser?.email || 'Not available'}
            left={(props) => <List.Icon {...props} icon="email" />}
          />
        </List.Section>

        <List.Section>
          <List.Subheader>Actions</List.Subheader>
          <List.Item
            title="Sign Out"
            left={(props) => <List.Icon {...props} icon="logout" />}
            onPress={() => setShowSignOutDialog(true)}
          />
        </List.Section>
      </ScrollView>

      <Portal>
        <Dialog visible={showSignOutDialog} onDismiss={() => setShowSignOutDialog(false)}>
          <Dialog.Title>Sign Out</Dialog.Title>
          <Dialog.Content>
            <Text variant="bodyMedium">Are you sure you want to sign out?</Text>
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setShowSignOutDialog(false)}>Cancel</Button>
            <Button onPress={handleSignOut}>Sign Out</Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    flex: 1,
  },
});
