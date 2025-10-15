/**
 * Core API Types
 *
 * Matches Django backend API responses
 */

// Common response wrapper
export interface ApiResponse<T> {
  data: T;
  message?: string;
}

// Error response from Django
export interface ApiError {
  detail?: string;
  [key: string]: any;
}

// Pagination (for future use)
export interface PaginatedResponse<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}
