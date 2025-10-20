import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';

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
    File? imageFile,
  }) async {
    FormData formData;

    if (imageFile != null) {
      // Create multipart form data with image
      final fileName = imageFile.path.split('/').last;
      final mimeType = _getMimeType(fileName);

      formData = FormData.fromMap({
        'title': title,
        'body': body,
        'image_file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });
    } else {
      // Regular JSON payload
      formData = FormData.fromMap({
        'title': title,
        'body': body,
      });
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/notes/',
      data: formData,
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
        contentType: 'multipart/form-data',
      ),
    );

    return Note.fromJson(response.data!);
  }

  String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotesRepository(dio);
});
