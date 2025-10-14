// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:nomad_notes/app/app.dart';
import 'package:nomad_notes/core/storage/storage_providers.dart';
import 'package:nomad_notes/core/storage/token_storage.dart';

class _InMemoryTokenStorage extends TokenStorage {
  _InMemoryTokenStorage();

  static const _access = 'access';
  static const _refresh = 'refresh';
  final Map<String, String> _store = {};

  @override
  FlutterSecureStorage get _storage => throw UnimplementedError();

  @override
  Future<void> saveTokens({required String access, required String refresh}) async {
    _store[_access] = access;
    _store[_refresh] = refresh;
  }

  @override
  Future<Map<String, String>?> readTokens() async {
    if (!_store.containsKey(_access) || !_store.containsKey(_refresh)) {
      return null;
    }
    return {
      'access': _store[_access]!,
      'refresh': _store[_refresh]!,
    };
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }
}

void main() {
  testWidgets('App routes from splash to sign-in', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tokenStorageProvider.overrideWithValue(_InMemoryTokenStorage()),
        ],
        child: const NomadNotesApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Sign in'), findsWidgets);
  });
}
