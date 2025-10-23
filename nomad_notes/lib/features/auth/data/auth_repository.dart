import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  AuthRepository(this._client, this._baseUrl);

  final http.Client _client;
  final String _baseUrl;

  String get _apiBase => '$_baseUrl/api';

  Future<AuthSession> signIn({required String email, required String password}) async {
    final url = Uri.parse('$_apiBase/auth/signin/');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException(response.statusCode, response.body);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
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
    final url = Uri.parse('$_apiBase/auth/signup/');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'full_name': fullName,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw HttpException(response.statusCode, response.body);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthSession(
      tokens: AuthTokens(
        access: data['access'] as String,
        refresh: data['refresh'] as String,
      ),
      user: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<void> signOut({required String accessToken, required String refreshToken}) async {
    final url = Uri.parse('$_apiBase/auth/signout/');
    final response = await _client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw HttpException(response.statusCode, response.body);
    }
  }

  Future<AuthTokens> refresh({required String refreshToken}) async {
    final url = Uri.parse('$_apiBase/auth/refresh/');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode != 200) {
      throw HttpException(response.statusCode, response.body);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthTokens(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
    );
  }

  Future<UserProfile> me({required String accessToken}) async {
    final url = Uri.parse('$_apiBase/auth/me/');
    final response = await _client.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw HttpException(response.statusCode, response.body);
    }

    return UserProfile.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

class HttpException implements Exception {
  HttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'HttpException: $statusCode - $body';
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(httpClientProvider);
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return AuthRepository(client, baseUrl);
});
