import { apiClient } from '@/core/api/client';
import { API_ENDPOINTS } from '@/core/config/api-config';
import type {
  SignUpRequest,
  SignInRequest,
  SignUpResponse,
  SignInResponse,
  AuthTokensResponse,
  UserResponse,
} from './auth-types';

/**
 * Authentication API Service
 *
 * All endpoints under /api/auth/
 */

export const authApi = {
  /**
   * Sign up a new user
   * POST /api/auth/signup/
   */
  signUp: async (data: SignUpRequest): Promise<SignUpResponse> => {
    const response = await apiClient.post<SignUpResponse>(
      API_ENDPOINTS.AUTH.SIGNUP,
      data
    );
    return response.data;
  },

  /**
   * Sign in existing user
   * POST /api/auth/signin/
   */
  signIn: async (data: SignInRequest): Promise<SignInResponse> => {
    const response = await apiClient.post<SignInResponse>(
      API_ENDPOINTS.AUTH.SIGNIN,
      data
    );
    return response.data;
  },

  /**
   * Refresh access token
   * POST /api/auth/refresh/
   */
  refreshToken: async (refreshToken: string): Promise<AuthTokensResponse> => {
    const response = await apiClient.post<AuthTokensResponse>(
      API_ENDPOINTS.AUTH.REFRESH,
      { refresh: refreshToken }
    );
    return response.data;
  },

  /**
   * Sign out (blacklist refresh token)
   * POST /api/auth/signout/
   */
  signOut: async (refreshToken: string): Promise<void> => {
    await apiClient.post(API_ENDPOINTS.AUTH.SIGNOUT, {
      refresh: refreshToken,
    });
  },

  /**
   * Get current user profile
   * GET /api/auth/me/
   */
  getCurrentUser: async (): Promise<UserResponse> => {
    const response = await apiClient.get<UserResponse>(API_ENDPOINTS.AUTH.ME);
    return response.data;
  },
};
