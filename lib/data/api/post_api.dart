import '../../core/servcies/api_service.dart';
import '../model/post_model.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostApi {
  final ApiService _apiService;

  PostApi(this._apiService);

  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _apiService.get('/api/posts/posts');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> postsData = response.data;
        return postsData
            .map((postJson) => PostModel.fromJson(postJson))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch posts. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<PostModel> createPost({
    required String title,
    required String text,
    required bool isPublic,
    List<String> sectionIds = const [],
    List<File> attachments = const [],
  }) async {
    try {
      final formData = FormData();
      formData.fields
        ..add(MapEntry('title', title))
        ..add(MapEntry('text', text))
        ..add(MapEntry('is_public', isPublic.toString()));

      // Only add section_ids if isPublic is false and sectionIds is not empty
      if (!isPublic && sectionIds.isNotEmpty) {
        for (final id in sectionIds) {
          formData.fields.add(MapEntry('section_ids', id));
        }
      }

      // Attachments are optional
      for (int i = 0; i < attachments.length; i++) {
        final file = attachments[i];
        final fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            'attachments[$i]file',
            await MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
      }

      final response = await _apiService.dio.post(
        '/api/posts/posts',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 201 && response.data != null) {
        return PostModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to create post. Status code:  {response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      final response = await _apiService.delete('/api/posts/posts/$postId');

      if (response.statusCode != 204) {
        throw Exception(
          'Failed to delete post. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> addComment({
    required int postId,
    required String text,
    required String token,
  }) async {
    final url = Uri.parse('http://10.15.249.81:8000/api/posts/comments');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'post': postId, 'text': text}),
    );
    return response;
  }

  Future<http.Response> deleteComment({
    required int commentId,
    required String token,
  }) async {
    final url = Uri.parse(
      'http://10.15.249.81:8000/api/posts/comments/$commentId',
    );
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  Future<http.Response> addReply({
    required int postId,
    required int commentId,
    required String text,
    required String token,
  }) async {
    final url = Uri.parse('http://10.15.249.81:8000/api/posts/comments');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'post': postId, 'comment': commentId, 'text': text}),
    );
    return response;
  }
}
