import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { useAuthStore } from '@/features/auth/hooks/useAuthStore';
import AuthNavigator from './AuthNavigator';
import MainNavigator from './MainNavigator';
import SplashScreen from '@/features/auth/screens/SplashScreen';

/**
 * Root App Navigator
 *
 * Handles auth-aware routing:
 * - Shows splash while bootstrapping (status = 'unknown')
 * - Shows auth screens when signed out (status = 'signedOut')
 * - Shows main app when signed in (status = 'signedIn')
 *
 * Matches Flutter's go_router redirect pattern
 */

export default function AppNavigator() {
  const { status, bootstrap } = useAuthStore();

  useEffect(() => {
    bootstrap();
  }, [bootstrap]);

  // Show splash during initial auth check
  if (status === 'unknown') {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      {status === 'signedIn' ? <MainNavigator /> : <AuthNavigator />}
    </NavigationContainer>
  );
}
