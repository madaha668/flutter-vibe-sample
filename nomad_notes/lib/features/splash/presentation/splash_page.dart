import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  static const routePath = '/';
  static const routeName = 'splash';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (authState.isLoading)
              const CircularProgressIndicator()
            else
              const Icon(Icons.note_alt_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              authState.isLoading
                  ? 'Preparing Nomad Notes…'
                  : 'Almost there…',
            ),
          ],
        ),
      ),
    );
  }
}
