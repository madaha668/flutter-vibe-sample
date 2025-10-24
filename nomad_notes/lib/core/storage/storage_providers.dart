import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'backend_url_storage.dart';
import 'token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => const TokenStorage());

final backendUrlStorageProvider = Provider<BackendUrlStorage>((ref) {
  const storage = FlutterSecureStorage();
  return BackendUrlStorage(storage);
});
