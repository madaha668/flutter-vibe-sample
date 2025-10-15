import { useMutation, useQuery } from '@tanstack/react-query';
import { authApi } from '../api/auth-api';
import { useAuthStore } from './useAuthStore';
import { getErrorMessage } from '@/core/utils/error-handler';
import type { SignUpRequest, SignInRequest } from '../api/auth-types';

/**
 * Authentication Hooks (React Query)
 *
 * Manages auth mutations and queries
 */

export const useSignUp = () => {
  const setAuthenticated = useAuthStore((state) => state.setAuthenticated);

  return useMutation({
    mutationFn: (data: SignUpRequest) => authApi.signUp(data),
    onSuccess: (response) => {
      setAuthenticated(response.user, response.access, response.refresh);
    },
    onError: (error) => {
      console.error('[SignUp] Failed:', getErrorMessage(error));
    },
  });
};

export const useSignIn = () => {
  const setAuthenticated = useAuthStore((state) => state.setAuthenticated);

  return useMutation({
    mutationFn: (data: SignInRequest) => authApi.signIn(data),
    onSuccess: (response) => {
      setAuthenticated(response.user, response.access, response.refresh);
    },
    onError: (error) => {
      console.error('[SignIn] Failed:', getErrorMessage(error));
    },
  });
};

export const useSignOut = () => {
  const { setUnauthenticated, refreshToken } = useAuthStore();

  return useMutation({
    mutationFn: async () => {
      if (refreshToken) {
        await authApi.signOut(refreshToken);
      }
    },
    onSuccess: () => {
      setUnauthenticated();
    },
    onError: (error) => {
      console.error('[SignOut] Failed:', getErrorMessage(error));
      // Still sign out locally even if server request fails
      setUnauthenticated();
    },
  });
};

export const useCurrentUser = () => {
  const status = useAuthStore((state) => state.status);

  return useQuery({
    queryKey: ['currentUser'],
    queryFn: authApi.getCurrentUser,
    enabled: status === 'signedIn',
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};
