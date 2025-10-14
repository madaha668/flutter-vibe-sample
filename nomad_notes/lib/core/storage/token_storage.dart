import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final Map<String, String> _fallbackMemoryStore = {};

class TokenStorage {
  const TokenStorage();

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  FlutterSecureStorage get _storage => const FlutterSecureStorage();

  Future<void> saveTokens({required String access, required String refresh}) async {
    try {
      await _storage.write(key: _accessKey, value: access);
      await _storage.write(key: _refreshKey, value: refresh);
    } on PlatformException catch (_) {
      _fallbackMemoryStore[_accessKey] = access;
      _fallbackMemoryStore[_refreshKey] = refresh;
    }
  }

  Future<Map<String, String>?> readTokens() async {
    String? access;
    String? refresh;
    try {
      access = await _storage.read(key: _accessKey);
      refresh = await _storage.read(key: _refreshKey);
    } on PlatformException catch (_) {
      access = _fallbackMemoryStore[_accessKey];
      refresh = _fallbackMemoryStore[_refreshKey];
    }
    if (access == null || refresh == null) {
      return null;
    }
    return {
      'access': access,
      'refresh': refresh,
    };
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } on PlatformException catch (_) {
      _fallbackMemoryStore.remove(_accessKey);
      _fallbackMemoryStore.remove(_refreshKey);
    }
  }
}
