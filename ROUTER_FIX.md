# Router Fix for Riverpod 2.x Compatibility

## Problem

The Flutter app was throwing the following error:

```
Assertion failed:
file:///Users/roobot/.pub-cache/hosted/pub.dev/flutter_riverpod-2.6.1/lib/src/consumer.dart:600:7
debugDoingBuild
"ref.listen can only be used within the build method of a ConsumerWidget"
```

## Root Cause

In Riverpod 2.x, `ref.listen()` can only be called within specific contexts:
- Inside a provider's build function (the callback passed to `Provider()`, `StateNotifier Provider()`, etc.)
- Inside the `build()` method of a `ConsumerWidget` or `ConsumerStatefulWidget`

The original code was calling `ref.listen()` inside a `RouterNotifier` class constructor, which is not an allowed context.

## Solution

Changed the router setup from using a separate `RouterNotifier` class to using `ref.listen()` directly within the `routerProvider`'s build function:

### Before (Broken):
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);
  return GoRouter(
    refreshListenable: notifier,
    // ...
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _subscription = _ref.listen<AuthState>(  // ❌ NOT ALLOWED
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
}
```

### After (Fixed):
```dart
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<int>(0);

  // ✅ ref.listen called directly in provider build function
  ref.listen<AuthState>(
    authControllerProvider,
    (previous, next) {
      notifier.value++; // Trigger GoRouter refresh
    },
  );

  final router = GoRouter(
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      // ... handle redirects
    },
    routes: [/* ... */],
  );

  ref.onDispose(() {
    router.dispose();
    notifier.dispose();
  });

  return router;
});
```

## How It Works

1. A `ValueNotifier<int>` is created to act as a simple listenable for GoRouter
2. `ref.listen()` is called within the provider's build function (allowed in Riverpod 2.x)
3. When auth state changes, the notifier's value is incremented
4. GoRouter detects the change in `refreshListenable` and re-evaluates redirects
5. The `redirect` callback reads the current auth state and determines routing

## Benefits

- ✅ Compatible with Riverpod 2.5.1+ and go_router 14.x+
- ✅ Proper resource cleanup with `ref.onDispose()`
- ✅ Simplified code - no need for custom `RouterNotifier` class
- ✅ Auth state changes immediately trigger routing updates

## Testing

After this fix:
- Chrome Flutter app should load without assertion errors
- macOS, iOS, Android apps should navigate properly based on auth state
- Sign in/out should trigger automatic navigation
- Splash screen → Sign in → Home page flow should work correctly

## Files Modified

- `nomad_notes/lib/app/router.dart` - Complete rewrite of router configuration
