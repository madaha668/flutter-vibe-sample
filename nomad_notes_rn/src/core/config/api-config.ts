import Constants from 'expo-constants';

/**
 * API Configuration
 *
 * IMPORTANT: NO HARDCODED ENDPOINTS!
 *
 * The API URL is injected via environment variable at runtime.
 * This allows the same build to work with different backends.
 *
 * Usage:
 *   Development:   NOMAD_API_URL=http://10.0.56.2:8000 npm run ios
 *   Staging:       NOMAD_API_URL=https://staging.api.com npm run android
 *   Production:    NOMAD_API_URL=https://api.com npm run ios
 *
 * The value is read from app.json's "extra.apiUrl" field, which is
 * populated from the NOMAD_API_URL environment variable.
 */

const getApiUrl = (): string => {
  // Try to get from Expo constants (injected via app.json)
  const envUrl = Constants.expoConfig?.extra?.apiUrl;

  if (envUrl && envUrl !== '${NOMAD_API_URL}') {
    console.log('[API Config] Using API URL from environment:', envUrl);
    return envUrl;
  }

  // Fallback: Check if running in development mode
  if (__DEV__) {
    console.warn(
      '[API Config] WARNING: NOMAD_API_URL not set! Using localhost fallback.\n' +
      'Please run with: NOMAD_API_URL=http://YOUR_IP:8000 npm run ios/android'
    );
    return 'http://localhost:8000';
  }

  // Production builds MUST have API URL set
  throw new Error(
    'NOMAD_API_URL environment variable is required for production builds.\n' +
    'Please set it before building: NOMAD_API_URL=https://your-api.com'
  );
};

export const API_BASE_URL = getApiUrl();

// API Endpoints
export const API_ENDPOINTS = {
  AUTH: {
    SIGNUP: '/api/auth/signup/',
    SIGNIN: '/api/auth/signin/',
    SIGNOUT: '/api/auth/signout/',
    REFRESH: '/api/auth/refresh/',
    ME: '/api/auth/me/',
  },
  NOTES: {
    LIST: '/api/notes/',
    DETAIL: (id: string) => `/api/notes/${id}/`,
  },
} as const;
