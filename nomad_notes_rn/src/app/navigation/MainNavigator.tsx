import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Appbar, useTheme } from 'react-native-paper';
import { MaterialCommunityIcons } from '@expo/vector-icons';
import NotesListScreen from '@/features/notes/screens/NotesListScreen';
import NoteEditorScreen from '@/features/notes/screens/NoteEditorScreen';
import ProfileScreen from '@/features/profile/screens/ProfileScreen';

/**
 * Main Navigator
 *
 * Handles navigation for authenticated users
 */

export type NotesStackParamList = {
  NotesList: undefined;
  NoteEditor: { noteId?: string };
};

export type MainTabParamList = {
  NotesTab: undefined;
  ProfileTab: undefined;
};

const NotesStack = createStackNavigator<NotesStackParamList>();
const Tab = createBottomTabNavigator<MainTabParamList>();

function NotesNavigator() {
  return (
    <NotesStack.Navigator>
      <NotesStack.Screen
        name="NotesList"
        component={NotesListScreen}
        options={{
          header: () => (
            <Appbar.Header>
              <Appbar.Content title="Nomad Notes" />
            </Appbar.Header>
          ),
        }}
      />
      <NotesStack.Screen
        name="NoteEditor"
        component={NoteEditorScreen}
        options={{ headerShown: false }}
      />
    </NotesStack.Navigator>
  );
}

export default function MainNavigator() {
  const theme = useTheme();

  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: '#666',
      }}
    >
      <Tab.Screen
        name="NotesTab"
        component={NotesNavigator}
        options={{
          tabBarLabel: 'Notes',
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="note-text" size={size} color={color} />
          ),
        }}
      />
      <Tab.Screen
        name="ProfileTab"
        component={ProfileScreen}
        options={{
          tabBarLabel: 'Profile',
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="account" size={size} color={color} />
          ),
        }}
      />
    </Tab.Navigator>
  );
}
