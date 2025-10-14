import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the base URL for the backend API depending on the current platform.
final apiBaseUrlProvider = Provider<String>((ref) {
  if (kIsWeb) {
    return const String.fromEnvironment('NOMAD_API_URL', defaultValue: 'http://localhost:8000');
  }

  if (Platform.isAndroid) {
    return const String.fromEnvironment('NOMAD_API_URL', defaultValue: 'http://10.0.2.2:8000');
  }

  return const String.fromEnvironment('NOMAD_API_URL', defaultValue: 'http://127.0.0.1:8000');
});
