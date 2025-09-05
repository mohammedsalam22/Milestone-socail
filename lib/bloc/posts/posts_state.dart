import '../../data/model/post_model.dart';

abstract class PostsState {}

class PostsInitial extends PostsState {}

class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<PostModel> posts;

  PostsLoaded(this.posts);
}

class PostsError extends PostsState {
  final String message;

  PostsError(this.message);
}

class PostCreated extends PostsState {
  final PostModel post;

  PostCreated(this.post);
}

class PostEdited extends PostsState {
  final PostModel post;

  PostEdited(this.post);
}

class PostDeleted extends PostsState {
  final int postId;

  PostDeleted(this.postId);
}
