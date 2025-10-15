import { AxiosError } from 'axios';
import type { ApiError } from '../api/types';

/**
 * Centralized Error Handler
 *
 * Converts API errors into user-friendly messages
 */

export const getErrorMessage = (error: unknown): string => {
  if (error instanceof AxiosError) {
    const axiosError = error as AxiosError<ApiError>;

    // Connection errors
    if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ERR_NETWORK') {
      return 'Cannot connect to server. Please check your internet connection.';
    }

    // Timeout errors
    if (axiosError.code === 'ETIMEDOUT') {
      return 'Request timeout. Please try again.';
    }

    // Server responded with error
    if (axiosError.response) {
      const { status, data } = axiosError.response;

      // Extract error message from response
      if (data?.detail) {
        return data.detail;
      }

      // Field-specific errors (e.g., validation)
      if (typeof data === 'object' && data !== null) {
        const firstErrorKey = Object.keys(data)[0];
        if (firstErrorKey && Array.isArray(data[firstErrorKey])) {
          return data[firstErrorKey][0];
        }
      }

      // Fallback to status-based messages
      switch (status) {
        case 400:
          return 'Invalid request. Please check your input.';
        case 401:
          return 'Session expired. Please sign in again.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'Resource not found.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return `Request failed with status ${status}`;
      }
    }

    return 'Network error. Please check your connection.';
  }

  // Non-Axios errors
  if (error instanceof Error) {
    return error.message;
  }

  return 'An unexpected error occurred.';
};
