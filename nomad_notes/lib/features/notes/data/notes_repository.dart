import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/note.dart';

class NotesRepository {
  NotesRepository(this._client, this._baseUrl);

  final http.Client _client;
  final String _baseUrl;

  String get _apiBase => '$_baseUrl/api';

  Future<List<Note>> fetchNotes(String accessToken) async {
    final url = Uri.parse('$_apiBase/notes/');
    final response = await _client.get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw HttpException(response.statusCode, response.body);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => Note.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Note> createNote({
    required String accessToken,
    required String title,
    required String body,
    File? imageFile,
  }) async {
    final url = Uri.parse('$_apiBase/notes/');

    if (imageFile != null) {
      // Create multipart request for image upload
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..fields['title'] = title
        ..fields['body'] = body;

      final fileName = imageFile.path.split('/').last;
      final mimeType = _getMimeType(fileName);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image_file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw HttpException(response.statusCode, response.body);
      }

      return Note.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // Regular JSON request
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'title': title,
          'body': body,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw HttpException(response.statusCode, response.body);
      }

      return Note.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
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
  final client = ref.watch(httpClientProvider);
  final baseUrl = ref.watch(apiBaseUrlProvider);
  return NotesRepository(client, baseUrl);
});
