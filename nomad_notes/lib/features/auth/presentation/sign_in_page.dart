import 'package:flutter/material.dart';
import 'package:flutter_icmp_ping/flutter_icmp_ping.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_controller.dart';
import 'backend_url_dialog.dart';
import 'sign_up_page.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  static const routePath = '/auth/sign-in';
  static const routeName = 'sign-in';

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _pingStatus;
  bool _isPinging = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    await ref.read(authControllerProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
  }

  Future<void> _testPing() async {
    setState(() {
      _isPinging = true;
      _pingStatus = 'Testing network...';
    });

    try {
      final ping = Ping(
        '8.8.8.8',
        count: 3,
        timeout: 5,
      );

      bool hasResponse = false;

      await for (final event in ping.stream) {
        if (event.response != null) {
          hasResponse = true;
          setState(() {
            _pingStatus = 'Ping OK - ${event.response?.time?.inMilliseconds ?? 0}ms';
          });
          break;
        } else if (event.error != null) {
          setState(() {
            _pingStatus = 'Network error: ${event.error ?? 'Unknown'}';
          });
        }
      }

      if (!hasResponse && _pingStatus == 'Testing network...') {
        setState(() {
          _pingStatus = 'Network is unreachable';
        });
      }
    } catch (e) {
      setState(() {
        _pingStatus = 'Ping failed: $e';
      });
    } finally {
      setState(() {
        _isPinging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;
    final errorMessage = authState.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configure Backend',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BackendUrlDialog(),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _emailController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Invalid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your password';
                      }
                      if (value.length < 8) {
                        return 'Minimum 8 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        errorMessage,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  FilledButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign in'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.go(SignUpPage.routePath),
                    child: const Text('Create an account'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isPinging ? null : _testPing,
                    icon: _isPinging
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check),
                    label: const Text('Test Network (Ping 8.8.8.8)'),
                  ),
                  if (_pingStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _pingStatus!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _pingStatus!.contains('OK')
                                  ? Colors.green
                                  : _pingStatus!.contains('unreachable') ||
                                          _pingStatus!.contains('error') ||
                                          _pingStatus!.contains('failed')
                                      ? Theme.of(context).colorScheme.error
                                      : null,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
