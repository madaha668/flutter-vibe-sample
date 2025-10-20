import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_controller.dart';
import '../data/notes_repository.dart';
import '../domain/note.dart';

class NotesState {
  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Note> notes;
  final bool isLoading;
  final String? errorMessage;

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NotesController extends StateNotifier<NotesState> {
  NotesController(this._ref, this._repository) : super(const NotesState()) {
    _authSubscription = _ref.listen<AuthState>(
      authControllerProvider,
      _handleAuthChange,
      fireImmediately: true,
    );
  }

  final Ref _ref;
  final NotesRepository _repository;
  late final ProviderSubscription<AuthState> _authSubscription;

  void _handleAuthChange(AuthState? previous, AuthState next) {
    if (next.status == AuthStatus.signedIn) {
      load();
    } else if (next.status == AuthStatus.signedOut) {
      clear();
    }
  }

  Future<void> load() async {
    final tokens = _ref.read(authControllerProvider).tokens;
    if (tokens == null) {
      state = const NotesState();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final notes = await _repository.fetchNotes(tokens.access);
      state = state.copyWith(notes: notes, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to fetch notes. Please try again.',
      );
    }
  }

  Future<bool> create({
    required String title,
    required String body,
    File? imageFile,
  }) async {
    final tokens = _ref.read(authControllerProvider).tokens;
    if (tokens == null) {
      return false;
    }

    try {
      final note = await _repository.createNote(
        accessToken: tokens.access,
        title: title,
        body: body,
        imageFile: imageFile,
      );
      state = state.copyWith(notes: [note, ...state.notes], clearError: true);
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: 'Could not create note.');
      return false;
    }
  }

  void clear() {
    state = const NotesState();
  }

  @override
  void dispose() {
    _authSubscription.close();
    super.dispose();
  }
}

final notesControllerProvider =
    StateNotifierProvider<NotesController, NotesState>((ref) {
  final repository = ref.watch(notesRepositoryProvider);
  return NotesController(ref, repository);
});
