import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../application/auth_controller.dart';

class BackendUrlDialog extends ConsumerStatefulWidget {
  const BackendUrlDialog({super.key});

  @override
  ConsumerState<BackendUrlDialog> createState() => _BackendUrlDialogState();
}

class _BackendUrlDialogState extends ConsumerState<BackendUrlDialog> {
  late TextEditingController _urlController;
  String? _testResult;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    final currentUrl = ref.read(backendUrlControllerProvider);
    _urlController = TextEditingController(text: currentUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _testResult = 'Please enter a URL';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = 'Testing...';
    });

    try {
      final testUrl = Uri.parse('$url/api/docs/');
      final client = http.Client();

      final response = await client.get(testUrl).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout');
        },
      );

      client.close();

      if (response.statusCode == 200) {
        setState(() {
          _testResult = '✓ Backend is reachable (200 OK)';
        });
      } else {
        setState(() {
          _testResult = '✗ Got status ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '✗ Failed to connect: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _saveUrl() async {
    final newUrl = _urlController.text.trim();
    if (newUrl.isEmpty) {
      return;
    }

    // Check if user is logged in
    final authState = ref.read(authControllerProvider);
    final isLoggedIn = authState.status == AuthStatus.signedIn;

    // Update the URL
    await ref.read(backendUrlControllerProvider.notifier).updateUrl(newUrl);

    // If user is logged in, sign them out
    if (isLoggedIn) {
      await ref.read(authControllerProvider.notifier).signOut();
    }

    if (!mounted) return;

    Navigator.of(context).pop();

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLoggedIn
              ? 'Backend URL updated. Please sign in again.'
              : 'Backend URL updated to $newUrl',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl = ref.watch(backendUrlControllerProvider);

    return AlertDialog(
      title: const Text('Configure Backend URL'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current URL:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              currentUrl,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'New Backend URL',
                hintText: 'http://192.168.1.100:8000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testUrl,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_done),
                    label: const Text('Test Connection'),
                  ),
                ),
              ],
            ),
            if (_testResult != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _testResult!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _testResult!.startsWith('✓')
                            ? Colors.green
                            : _testResult!.startsWith('✗')
                                ? Theme.of(context).colorScheme.error
                                : null,
                      ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveUrl,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
