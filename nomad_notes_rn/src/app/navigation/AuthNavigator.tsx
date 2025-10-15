import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import SignInScreen from '@/features/auth/screens/SignInScreen';
import SignUpScreen from '@/features/auth/screens/SignUpScreen';

/**
 * Auth Navigator
 *
 * Handles navigation for unauthenticated users
 */

export type AuthStackParamList = {
  SignIn: undefined;
  SignUp: undefined;
};

const Stack = createStackNavigator<AuthStackParamList>();

export default function AuthNavigator() {
  return (
    <Stack.Navigator
      initialRouteName="SignIn"
      screenOptions={{
        headerShown: false,
      }}
    >
      <Stack.Screen name="SignIn" component={SignInScreen} />
      <Stack.Screen name="SignUp" component={SignUpScreen} />
    </Stack.Navigator>
  );
}
