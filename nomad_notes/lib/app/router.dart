import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/sign_in_page.dart';
import '../features/auth/presentation/sign_up_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/splash/presentation/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<int>(0);

  // Listen to auth changes and trigger router refresh
  ref.listen<AuthState>(
    authControllerProvider,
    (previous, next) {
      // Increment value to trigger GoRouter refresh
      notifier.value++;
    },
  );

  final router = GoRouter(
    initialLocation: SplashPage.routePath,
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final status = authState.status;
      final location = state.matchedLocation;

      final onSplash = location == SplashPage.routePath;
      final onAuthStack = location.startsWith('/auth');

      if (status == AuthStatus.unknown || authState.isLoading) {
        return onSplash ? null : SplashPage.routePath;
      }

      if (status == AuthStatus.signedOut) {
        if (onAuthStack) {
          return null;
        }
        return SignInPage.routePath;
      }

      if (status == AuthStatus.signedIn) {
        if (onAuthStack || onSplash) {
          return HomePage.routePath;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: SplashPage.routePath,
        name: SplashPage.routeName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: SignInPage.routePath,
        name: SignInPage.routeName,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: SignUpPage.routePath,
        name: SignUpPage.routeName,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: HomePage.routePath,
        name: HomePage.routeName,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    notifier.dispose();
  });

  return router;
});
