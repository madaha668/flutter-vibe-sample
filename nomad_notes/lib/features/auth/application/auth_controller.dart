import 'dart:async';
import 'dart:io';

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
    } on HttpException catch (error) {
      if (error.statusCode == 401) {
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
  if (error is HttpException) {
    // HTTP error with response
    try {
      final data = error.body;
      if (data.isNotEmpty) {
        // Try to parse as JSON
        final json = Uri.decodeComponent(data);
        if (json.contains('detail')) {
          // Extract detail field if present
          final detailMatch = RegExp(r'"detail"\s*:\s*"([^"]*)"').firstMatch(json);
          if (detailMatch != null) {
            return detailMatch.group(1) ?? 'Server error';
          }
        }
      }
    } catch (_) {
      // Fall through to generic message
    }

    if (error.statusCode == 400) {
      return 'Invalid request. Please check your details.';
    }

    if (error.statusCode == 401) {
      return 'Invalid credentials. Please check your email and password.';
    }

    if (error.statusCode >= 500) {
      return 'Server error (${error.statusCode}). Please try again later.';
    }

    return 'Request failed (${error.statusCode}). Please try again.';
  }

  if (error is SocketException) {
    return 'Cannot connect to server. Please check if the backend is running and your network connection.';
  }

  if (error is TimeoutException) {
    return 'Connection timeout. Please check your internet connection.';
  }

  // Unknown error
  return 'Something went wrong: ${error.toString()}';
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
