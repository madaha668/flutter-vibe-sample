import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the base URL for the backend API depending on the current platform.
///
/// Default network configuration:
/// - All platforms now connect to backend at 10.0.56.2:8000
/// - Override with: flutter run --dart-define=NOMAD_API_URL=http://your-ip:8000
final apiBaseUrlProvider = Provider<String>((ref) {
  // Check for environment override first
  const envUrl = String.fromEnvironment('NOMAD_API_URL');
  if (envUrl.isNotEmpty) {
    return envUrl;
  }

  // Default to network backend server
  return 'http://10.0.56.2:8000';
});
