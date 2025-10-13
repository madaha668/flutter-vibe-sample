import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const routePath = '/home';
  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = _demoNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nomad Notes'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            child: ListTile(
              title: Text(note.title),
              subtitle: Text(note.preview),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: notes.length,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
    );
  }
}

class _DemoNote {
  const _DemoNote(this.title, this.preview);

  final String title;
  final String preview;
}

const _demoNotes = [
  _DemoNote('Welcome to Nomad Notes', 'Sync ideas across devices seamlessly.'),
  _DemoNote('Capture fast', 'Use the + button to create new notes on the go.'),
  _DemoNote('Stay secure', 'Your data remains encrypted once the backend is wired.'),
];
