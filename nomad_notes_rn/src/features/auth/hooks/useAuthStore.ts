import { create } from 'zustand';
import { secureStorage } from '@/core/storage/secure-storage';
import type { UserResponse } from '../api/auth-types';

/**
 * Authentication Store (Zustand)
 *
 * Manages auth state similar to Flutter's AuthController
 * Status: unknown -> signedOut | signedIn
 */

export type AuthStatus = 'unknown' | 'signedOut' | 'signedIn';

interface AuthState {
  status: AuthStatus;
  user: UserResponse | null;
  accessToken: string | null;
  refreshToken: string | null;

  // Actions
  setAuthenticated: (user: UserResponse, accessToken: string, refreshToken: string) => void;
  setUnauthenticated: () => void;
  updateTokens: (accessToken: string, refreshToken: string) => void;
  bootstrap: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  status: 'unknown',
  user: null,
  accessToken: null,
  refreshToken: null,

  setAuthenticated: (user, accessToken, refreshToken) => {
    secureStorage.saveTokens(accessToken, refreshToken);
    set({
      status: 'signedIn',
      user,
      accessToken,
      refreshToken,
    });
  },

  setUnauthenticated: () => {
    secureStorage.clearTokens();
    set({
      status: 'signedOut',
      user: null,
      accessToken: null,
      refreshToken: null,
    });
  },

  updateTokens: (accessToken, refreshToken) => {
    secureStorage.saveTokens(accessToken, refreshToken);
    set({ accessToken, refreshToken });
  },

  bootstrap: async () => {
    const hasTokens = await secureStorage.hasTokens();
    set({
      status: hasTokens ? 'signedIn' : 'signedOut',
    });
  },
}));
