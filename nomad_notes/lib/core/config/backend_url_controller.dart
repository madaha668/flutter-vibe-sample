import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import '../storage/storage_providers.dart';

const _defaultBackendUrl = 'http://192.168.66.238:8000';

class BackendUrlController extends StateNotifier<String> {
  BackendUrlController(this._ref) : super(_defaultBackendUrl) {
    _loadUrl();
  }

  final Ref _ref;

  Future<void> _loadUrl() async {
    final storage = _ref.read(backendUrlStorageProvider);

    // Check for environment override first
    const envUrl = String.fromEnvironment('NOMAD_API_URL');
    if (envUrl.isNotEmpty) {
      state = envUrl;
      return;
    }

    // Try to load from storage
    final savedUrl = await storage.readUrl();
    if (savedUrl != null && savedUrl.isNotEmpty) {
      state = savedUrl;
    }
  }

  Future<void> updateUrl(String newUrl) async {
    final storage = _ref.read(backendUrlStorageProvider);
    await storage.saveUrl(newUrl);
    state = newUrl;
  }

  Future<void> resetToDefault() async {
    final storage = _ref.read(backendUrlStorageProvider);
    await storage.clear();
    state = _defaultBackendUrl;
  }
}

final backendUrlControllerProvider =
    StateNotifierProvider<BackendUrlController, String>((ref) {
  return BackendUrlController(ref);
});

// For backward compatibility - this is what other parts of the app use
final apiBaseUrlProvider = Provider<String>((ref) {
  return ref.watch(backendUrlControllerProvider);
});
