import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../domain/note.dart';

class NotesRepository {
  NotesRepository(this._dio);

  final Dio _dio;

  Future<List<Note>> fetchNotes(String accessToken) async {
    final response = await _dio.get<List<dynamic>>(
      '/notes/',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    final data = response.data ?? const [];
    return data.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Note> createNote({
    required String accessToken,
    required String title,
    required String body,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/notes/',
      data: {
        'title': title,
        'body': body,
      },
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );

    return Note.fromJson(response.data!);
  }
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotesRepository(dio);
});
