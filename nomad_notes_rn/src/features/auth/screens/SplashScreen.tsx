import React from 'react';
import { View, StyleSheet } from 'react-native';
import { ActivityIndicator, Text } from 'react-native-paper';

/**
 * Splash Screen
 *
 * Shown during initial auth check (status = 'unknown')
 */

export default function SplashScreen() {
  return (
    <View style={styles.container}>
      <Text variant="headlineMedium" style={styles.title}>
        Nomad Notes
      </Text>
      <ActivityIndicator size="large" style={styles.loader} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  title: {
    marginBottom: 24,
    fontWeight: 'bold',
  },
  loader: {
    marginTop: 16,
  },
});
