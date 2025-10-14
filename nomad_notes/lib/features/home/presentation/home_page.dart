import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../../notes/application/notes_controller.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const routePath = '/home';
  static const routeName = 'home';

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.listen<NotesState>(
      notesControllerProvider,
      (previous, next) {
        if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.errorMessage!)),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final notesState = ref.watch(notesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nomad Notes${authState.user != null ? ' • ${authState.user!.email}' : ''}'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: authState.isLoading
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notesControllerProvider.notifier).load(),
        child: Builder(
          builder: (context) {
            if (notesState.isLoading && notesState.notes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notesState.notes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.sticky_note_2_outlined, size: 64, color: Colors.grey),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                      child: Text(
                        'No notes yet. Tap the + button to capture your first idea.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final note = notesState.notes[index];
                return Card(
                  child: ListTile(
                    title: Text(note.title),
                    subtitle: Text(
                      note.body.isEmpty ? 'No content' : note.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: notesState.notes.length,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateNoteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
    );
  }

  Future<void> _showCreateNoteDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;
        String? errorText;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New note'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: bodyController,
                    decoration: const InputDecoration(labelText: 'Body'),
                    minLines: 3,
                    maxLines: 5,
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        errorText!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop(false);
                        },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final body = bodyController.text.trim();
                          if (title.isEmpty) {
                            setState(() {
                              errorText = 'Title cannot be empty';
                            });
                            return;
                          }

                          setState(() {
                            isSubmitting = true;
                            errorText = null;
                          });

                          final success = await ref
                              .read(notesControllerProvider.notifier)
                              .create(title: title, body: body);

                          if (!mounted || !dialogContext.mounted) return;

                          if (success) {
                            Navigator.of(dialogContext).pop(true);
                          } else {
                            setState(() {
                              isSubmitting = false;
                              errorText = 'Could not save note. Please retry.';
                            });
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!context.mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note added.')),
      );
    }
  }
}
