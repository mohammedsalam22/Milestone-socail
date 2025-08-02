import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/post_repo.dart';
import '../../data/model/post_model.dart';
import 'posts_state.dart';
import 'dart:io';
import '../../data/services/posts_websocket_service.dart';

class PostsCubit extends Cubit<PostsState> {
  final PostRepo _postRepo;
  PostsWebSocketService? _webSocketService;
  Stream<PostModel>? _wsStream;
  List<PostModel> _allPosts = [];

  PostsCubit(this._postRepo) : super(PostsInitial());

  Future<void> getPosts() async {
    try {
      emit(PostsLoading());
      final posts = await _postRepo.getPosts();
      _allPosts = _mergeAndDeduplicate(_allPosts, posts);
      emit(PostsLoaded(_allPosts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> createPost({
    required String title,
    required String text,
    required bool isPublic,
    List<String> sectionIds = const [],
    List<File> attachments = const [],
  }) async {
    try {
      final post = await _postRepo.createPost(
        title: title,
        text: text,
        isPublic: isPublic,
        sectionIds: sectionIds,
        attachments: attachments,
      );
      _allPosts.insert(0, post);
      emit(PostCreated(post));
      emit(PostsLoaded(_allPosts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> connectWebSocket(
    String token, {
    void Function(PostModel)? onNewPost,
  }) async {
    _webSocketService = PostsWebSocketService(token: token);
    _wsStream = _webSocketService!.connect();
    _wsStream!.listen(
      (post) {
        // Only add if not already present
        if (!_allPosts.any((p) => p.id == post.id)) {
          _allPosts.insert(0, post);
          if (onNewPost != null) {
            onNewPost(post);
          } else {
            emit(PostsLoaded(_allPosts));
          }
        }
      },
      onError: (e) {
        // On error, keep showing current posts
        emit(PostsLoaded(_allPosts));
      },
      onDone: () {
        // On close, keep showing current posts
        emit(PostsLoaded(_allPosts));
      },
    );
  }

  void disconnectWebSocket() {
    _webSocketService?.disconnect();
    // Do not clear _allPosts so old posts remain visible
  }

  Future<void> deletePost(int postId) async {
    try {
      await _postRepo.deletePost(postId);
      _allPosts.removeWhere((p) => p.id == postId);
      emit(PostDeleted(postId));
      emit(PostsLoaded(_allPosts));
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> addComment({
    required int postId,
    required String text,
    required String token,
  }) async {
    try {
      final success = await _postRepo.addComment(
        postId: postId,
        text: text,
        token: token,
      );
      if (success) {
        await getPosts(); // Refresh posts to get new comments
      } else {
        emit(PostsError('Failed to add comment'));
      }
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> deleteComment({
    required int commentId,
    required String token,
  }) async {
    try {
      final success = await _postRepo.deleteComment(
        commentId: commentId,
        token: token,
      );
      if (success) {
        await getPosts(); // Refresh posts to get updated comments
      } else {
        emit(PostsError('Failed to delete comment'));
      }
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  Future<void> addReply({
    required int postId,
    required int commentId,
    required String text,
    required String token,
  }) async {
    try {
      final success = await _postRepo.addReply(
        postId: postId,
        commentId: commentId,
        text: text,
        token: token,
      );
      if (success) {
        await getPosts(); // Refresh posts to get new replies
      } else {
        emit(PostsError('Failed to add reply'));
      }
    } catch (e) {
      emit(PostsError(e.toString()));
    }
  }

  void refreshPosts() {
    getPosts();
  }

  List<PostModel> _mergeAndDeduplicate(
    List<PostModel> wsPosts,
    List<PostModel> httpPosts,
  ) {
    final Map<int, PostModel> postMap = {for (var p in wsPosts) p.id: p};
    for (var p in httpPosts) {
      postMap[p.id] = p;
    }
    final merged = postMap.values.toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }
}
