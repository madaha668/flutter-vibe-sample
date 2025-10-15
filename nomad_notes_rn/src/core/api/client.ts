import axios, { AxiosError, AxiosInstance, InternalAxiosRequestConfig } from 'axios';
import { API_BASE_URL, API_ENDPOINTS } from '../config/api-config';
import { secureStorage } from '../storage/secure-storage';

/**
 * Axios API Client with Auto Token Refresh
 *
 * Matches Flutter app's Dio interceptor pattern:
 * 1. Inject access token on every request
 * 2. Automatically refresh token on 401 errors
 * 3. Retry original request with new token
 * 4. Sign out if refresh fails
 */

class ApiClient {
  private client: AxiosInstance;
  private isRefreshing = false;
  private refreshSubscribers: Array<(token: string) => void> = [];

  constructor() {
    console.log('[API Client] Initializing with baseURL:', API_BASE_URL);

    this.client = axios.create({
      baseURL: API_BASE_URL,
      timeout: 10000,
      headers: {
        'Content-Type': 'application/json',
      },
    });

    this.setupInterceptors();
  }

  private setupInterceptors(): void {
    // Request interceptor: Inject access token
    this.client.interceptors.request.use(
      async (config: InternalAxiosRequestConfig) => {
        console.log('[API Client] Making request:', {
          method: config.method?.toUpperCase(),
          url: config.url,
          baseURL: config.baseURL,
          fullURL: `${config.baseURL}${config.url}`,
        });

        const token = await secureStorage.getAccessToken();
        if (token && config.headers) {
          config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
      },
      (error) => {
        console.error('[API Client] Request error:', error);
        return Promise.reject(error);
      }
    );

    // Response interceptor: Handle 401 and auto-refresh
    this.client.interceptors.response.use(
      (response) => {
        console.log('[API Client] Response received:', {
          status: response.status,
          url: response.config.url,
        });
        return response;
      },
      async (error: AxiosError) => {
        console.error('[API Client] Response error:', {
          message: error.message,
          code: error.code,
          status: error.response?.status,
          url: error.config?.url,
          responseData: error.response?.data,
        });
        const originalRequest = error.config as InternalAxiosRequestConfig & {
          _retry?: boolean;
        };

        // Handle 401 Unauthorized
        if (error.response?.status === 401 && originalRequest && !originalRequest._retry) {
          if (this.isRefreshing) {
            // Wait for ongoing refresh to complete
            return new Promise((resolve) => {
              this.refreshSubscribers.push((token: string) => {
                if (originalRequest.headers) {
                  originalRequest.headers.Authorization = `Bearer ${token}`;
                }
                resolve(this.client(originalRequest));
              });
            });
          }

          originalRequest._retry = true;
          this.isRefreshing = true;

          try {
            const refreshToken = await secureStorage.getRefreshToken();
            if (!refreshToken) {
              throw new Error('No refresh token available');
            }

            // Call refresh endpoint
            const { data } = await axios.post(
              `${API_BASE_URL}${API_ENDPOINTS.AUTH.REFRESH}`,
              { refresh: refreshToken }
            );

            const { access, refresh } = data;

            // Save new tokens
            await secureStorage.saveTokens(access, refresh);

            // Update original request header
            if (originalRequest.headers) {
              originalRequest.headers.Authorization = `Bearer ${access}`;
            }

            // Notify all waiting requests
            this.onRefreshed(access);
            this.refreshSubscribers = [];

            return this.client(originalRequest);
          } catch (refreshError) {
            // Refresh failed - clear tokens and sign out
            await secureStorage.clearTokens();
            this.refreshSubscribers = [];
            return Promise.reject(refreshError);
          } finally {
            this.isRefreshing = false;
          }
        }

        return Promise.reject(error);
      }
    );
  }

  private onRefreshed(token: string): void {
    this.refreshSubscribers.forEach((callback) => callback(token));
  }

  // Expose axios instance for use in API services
  get instance(): AxiosInstance {
    return this.client;
  }
}

export const apiClient = new ApiClient().instance;
