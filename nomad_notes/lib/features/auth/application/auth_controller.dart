import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../../../core/storage/storage_providers.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.tokens,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserProfile? user;
  final AuthTokens? tokens;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserProfile? user,
    AuthTokens? tokens,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref)
      : super(const AuthState(status: AuthStatus.unknown, isLoading: true)) {
    _bootstrap();
  }

  final Ref _ref;

  AuthRepository get _repository => _ref.read(authRepositoryProvider);
  TokenStorage get _tokenStorage => _ref.read(tokenStorageProvider);

  Future<void> _bootstrap() async {
    final stored = await _tokenStorage.readTokens();
    if (stored == null) {
      state = const AuthState(status: AuthStatus.signedOut);
      return;
    }

    final tokens = AuthTokens(access: stored['access']!, refresh: stored['refresh']!);

    try {
      final user = await _repository.me(accessToken: tokens.access);
      _setSignedIn(user: user, tokens: tokens);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _attemptRefresh(tokens);
      } else {
        await _tokenStorage.clear();
        state = const AuthState(status: AuthStatus.signedOut);
      }
    } catch (_) {
      await _tokenStorage.clear();
      state = const AuthState(status: AuthStatus.signedOut);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final session =
          await _repository.signIn(email: email, password: password);
      await _tokenStorage.saveTokens(
        access: session.tokens.access,
        refresh: session.tokens.refresh,
      );
      _setSignedIn(user: session.user, tokens: session.tokens);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFromError(error),
      );
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final session = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      await _tokenStorage.saveTokens(
        access: session.tokens.access,
        refresh: session.tokens.refresh,
      );
      _setSignedIn(user: session.user, tokens: session.tokens);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageFromError(error),
      );
    }
  }

  Future<void> signOut() async {
    final tokens = state.tokens;
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    if (tokens != null) {
      try {
        await _repository.signOut(
          accessToken: tokens.access,
          refreshToken: tokens.refresh,
        );
      } catch (_) {
        // Best-effort sign out; ignore backend errors and clear local session.
      }
    }

    await _tokenStorage.clear();
    state = const AuthState(status: AuthStatus.signedOut);
  }

  Future<void> _attemptRefresh(AuthTokens tokens) async {
    try {
      final refreshed =
          await _repository.refresh(refreshToken: tokens.refresh);
      await _tokenStorage.saveTokens(
        access: refreshed.access,
        refresh: refreshed.refresh,
      );
      final user = await _repository.me(accessToken: refreshed.access);
      _setSignedIn(user: user, tokens: refreshed);
    } catch (_) {
      await _tokenStorage.clear();
      state = const AuthState(status: AuthStatus.signedOut);
    }
  }

  void _setSignedIn({required UserProfile user, required AuthTokens tokens}) {
    state = AuthState(
      status: AuthStatus.signedIn,
      user: user,
      tokens: tokens,
      isLoading: false,
    );
  }
}

String _messageFromError(Object error) {
  if (error is DioException) {
    // Network error (no response from server)
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check if the backend is running at ${error.requestOptions.baseUrl}';
    }

    // Server responded with error
    final detail = error.response?.data;
    if (detail is Map<String, dynamic>) {
      if (detail['detail'] is String) {
        return detail['detail'] as String;
      }
      final firstEntry = detail.entries.firstWhere(
        (_) => true,
        orElse: () => MapEntry('', ''),
      );
      if (firstEntry.value is List && firstEntry.value.isNotEmpty) {
        return firstEntry.value.first.toString();
      }
    }

    if (error.response?.statusCode == 400) {
      return 'Invalid request. Please check your details.';
    }

    if (error.response?.statusCode != null) {
      return 'Server error (${error.response!.statusCode}). Please try again.';
    }

    // Unknown DioException
    return 'Network error: ${error.message ?? error.type.name}';
  }

  // Non-Dio error
  return 'Something went wrong: ${error.toString()}';
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
