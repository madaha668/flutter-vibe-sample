/**
 * Authentication API Types
 *
 * Matches Django backend /api/auth/ endpoints
 */

// Request DTOs
export interface SignUpRequest {
  email: string;
  password: string;
  full_name: string;
}

export interface SignInRequest {
  email: string;
  password: string;
}

export interface RefreshTokenRequest {
  refresh: string;
}

export interface SignOutRequest {
  refresh: string;
}

// Response DTOs
export interface AuthTokensResponse {
  access: string;
  refresh: string;
}

export interface UserResponse {
  id: string;
  email: string;
  full_name: string;
}

export interface SignUpResponse extends AuthTokensResponse {
  user: UserResponse;
}

export interface SignInResponse extends AuthTokensResponse {
  user: UserResponse;
}
