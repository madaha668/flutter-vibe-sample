import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unknown, signedOut, signedIn }

class AuthState {
  const AuthState({
    required this.status,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController()
      : super(const AuthState(
          status: AuthStatus.unknown,
          isLoading: true,
        )) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    state = const AuthState(status: AuthStatus.signedOut);
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      state = const AuthState(status: AuthStatus.signedIn);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign in. Please retry.',
      );
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      state = const AuthState(status: AuthStatus.signedIn);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to sign up. Please retry.',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = const AuthState(status: AuthStatus.signedOut);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
