import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final notesState = ref.watch(notesControllerProvider);

    // Listen for error messages and show snackbar
    ref.listen<NotesState>(
      notesControllerProvider,
      (previous, next) {
        if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        }
      },
    );

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
                    leading: note.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              note.image!.imageUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image),
                            ),
                          )
                        : null,
                    title: Text(note.title),
                    subtitle: Text(
                      note.body.isEmpty ? 'No content' : note.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: note.image != null
                        ? const Icon(Icons.photo_library, size: 16)
                        : null,
                    onTap: () => _showNoteDetailDialog(context, note),
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
    final imagePicker = ImagePicker();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;
        String? errorText;
        File? selectedImage;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New note'),
              content: SingleChildScrollView(
                child: Column(
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
                    const SizedBox(height: 16),
                    if (selectedImage != null) ...[
                      SizedBox(
                        height: 150,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                selectedImage!,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton.filled(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(4),
                                  minimumSize: const Size(32, 32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux)
                      // On desktop, show single button for file picker
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  try {
                                    const typeGroup = XTypeGroup(
                                      label: 'images',
                                      extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
                                    );
                                    final file = await openFile(
                                      acceptedTypeGroups: [typeGroup],
                                    );
                                    if (file != null) {
                                      setState(() {
                                        selectedImage = File(file.path);
                                      });
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: ${e.toString()}')),
                                      );
                                    }
                                  }
                                },
                          icon: const Icon(Icons.add_photo_alternate),
                          label: const Text('Choose Image'),
                        ),
                      )
                    else
                      // On mobile (iOS/Android), show camera and gallery buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    try {
                                      final image = await imagePicker.pickImage(
                                        source: ImageSource.camera,
                                      );
                                      if (image != null) {
                                        setState(() {
                                          selectedImage = File(image.path);
                                        });
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Camera error: $e')),
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                          ),
                          TextButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    try {
                                      final image = await imagePicker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (image != null) {
                                        setState(() {
                                          selectedImage = File(image.path);
                                        });
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Gallery error: $e')),
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                          ),
                        ],
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
                              .create(
                                title: title,
                                body: body,
                                imageFile: selectedImage,
                              );

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

  Future<void> _showNoteDetailDialog(BuildContext context, note) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(note.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.image != null) ...[
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        note.image!.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 64),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (note.image!.analysisStatus == 'completed') ...[
                    if (note.image!.ocrText.isNotEmpty) ...[
                      const Text(
                        'Extracted Text:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(note.image!.ocrText),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (note.image!.objectLabels.isNotEmpty) ...[
                      const Text(
                        'Detected Objects:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: note.image!.objectLabels
                            .map<Widget>((label) => Chip(
                                  label: Text(label),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ] else if (note.image!.analysisStatus == 'processing') ...[
                    const Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Analyzing image...'),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
                if (note.body.isNotEmpty) ...[
                  const Text(
                    'Note:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(note.body),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
