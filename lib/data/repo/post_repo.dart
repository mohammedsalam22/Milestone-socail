import '../api/post_api.dart';
import '../model/post_model.dart';
import 'dart:io';

class PostRepo {
  final PostApi _postApi;

  PostRepo(this._postApi);

  Future<List<PostModel>> getPosts() async {
    try {
      return await _postApi.getPosts();
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
      return await _postApi.createPost(
        title: title,
        text: text,
        isPublic: isPublic,
        sectionIds: sectionIds,
        attachments: attachments,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      await _postApi.deletePost(postId);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addComment({
    required int postId,
    required String text,
  }) async {
    try {
      final response = await _postApi.addComment(
        postId: postId,
        text: text,
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteComment({
    required int commentId,
  }) async {
    try {
      final response = await _postApi.deleteComment(
        commentId: commentId,
      );
      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addReply({
    required int postId,
    required int commentId,
    required String text,
  }) async {
    try {
      final response = await _postApi.addReply(
        postId: postId,
        commentId: commentId,
        text: text,
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
