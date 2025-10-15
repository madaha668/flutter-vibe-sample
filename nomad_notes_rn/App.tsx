import React from 'react';
import { StatusBar } from 'expo-status-bar';
import AppProviders from './src/app/providers/AppProviders';
import AppNavigator from './src/app/navigation/AppNavigator';

/**
 * Root App Component
 *
 * Entry point for Nomad Notes React Native app
 */

export default function App() {
  return (
    <AppProviders>
      <AppNavigator />
      <StatusBar style="auto" />
    </AppProviders>
  );
}
