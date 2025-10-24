import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BackendUrlStorage {
  BackendUrlStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyBackendUrl = 'backend_url';

  Future<String?> readUrl() async {
    return await _storage.read(key: _keyBackendUrl);
  }

  Future<void> saveUrl(String url) async {
    await _storage.write(key: _keyBackendUrl, value: url);
  }

  Future<void> clear() async {
    await _storage.delete(key: _keyBackendUrl);
  }
}
