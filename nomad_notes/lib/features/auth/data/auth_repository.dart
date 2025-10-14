import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<AuthSession> signIn({required String email, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/signin/',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data!;
    return AuthSession(
      tokens: AuthTokens(
        access: data['access'] as String,
        refresh: data['refresh'] as String,
      ),
      user: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<AuthSession> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/signup/',
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
    );

    final data = response.data!;
    return AuthSession(
      tokens: AuthTokens(
        access: data['access'] as String,
        refresh: data['refresh'] as String,
      ),
      user: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<void> signOut({required String accessToken, required String refreshToken}) async {
    await _dio.post(
      '/auth/signout/',
      data: {'refresh': refreshToken},
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
  }

  Future<AuthTokens> refresh({required String refreshToken}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh/',
      data: {'refresh': refreshToken},
    );
    final data = response.data!;
    return AuthTokens(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
    );
  }

  Future<UserProfile> me({required String accessToken}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/auth/me/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return UserProfile.fromJson(response.data!);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});
