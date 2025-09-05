import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/post_model.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class PostApi {
  final ApiService _apiService;

  PostApi(this._apiService);

  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _apiService.get(ApiEndpoints.posts);

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

  Future<List<PostModel>> getPostsBySection(int sectionId) async {
    try {
      final response = await _apiService.get(
        '${ApiEndpoints.posts}?sections=$sectionId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> postsData = response.data;
        return postsData
            .map((postJson) => PostModel.fromJson(postJson))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch posts by section. Status code: ${response.statusCode}',
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
        formData.fields.add(MapEntry('section_ids', sectionIds.join(',')));
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
        ApiEndpoints.posts,
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

  Future<PostModel> editPost({
    required int postId,
    required String text,
  }) async {
    try {
      final response = await _apiService.patch(
        '${ApiEndpoints.posts}/$postId',
        data: {'text': text},
      );

      if (response.statusCode == 200 && response.data != null) {
        return PostModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to edit post. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      final response = await _apiService.delete(
        '${ApiEndpoints.posts}/$postId',
      );

      if (response.statusCode != 204) {
        throw Exception(
          'Failed to delete post. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addComment({
    required int postId,
    required String text,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.comments,
        data: {'post': postId, 'text': text},
      );

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
          'Failed to add comment. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteComment({required int commentId}) async {
    try {
      final response = await _apiService.delete(
        '${ApiEndpoints.comments}/$commentId',
      );

      if (response.statusCode == 204) {
        return response;
      } else {
        throw Exception(
          'Failed to delete comment. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addReply({
    required int postId,
    required int commentId,
    required String text,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.comments,
        data: {'post': postId, 'comment': commentId, 'text': text},
      );

      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception(
          'Failed to add reply. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
