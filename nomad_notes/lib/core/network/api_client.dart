import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final apiBaseUrlProvider = Provider<String>((ref) {
  return ref.watch(apiConfigProvider).baseUrl;
});
