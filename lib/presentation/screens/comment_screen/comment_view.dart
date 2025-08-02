import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../bloc/posts/posts_cubit.dart';
import '../../../../bloc/posts/posts_state.dart';
import '../../../../data/model/post_model.dart';
import '../../../../data/model/user_model.dart';
import '../../../../generated/l10n.dart';
import 'widgets/comment_card.dart';
import 'widgets/comment_input.dart';

class CommentsScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final UserModel user;

  const CommentsScreen({super.key, required this.post, required this.user});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostsCubit, PostsState>(
      builder: (context, state) {
        PostModel? postModel;
        if (state is PostsLoaded) {
          postModel = state.posts.firstWhere(
            (p) => p.id == widget.post['id'],
            orElse: () => PostModel.fromJson(widget.post),
          );
        } else {
          postModel = PostModel.fromJson(widget.post);
        }
        final comments = postModel.comments;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(S.of(context).comments),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: Column(
            children: [
              _buildPostPreview(),
              Expanded(
                child: comments.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return CommentCard(
                            comment: comment,
                            currentUser: widget.user,
                            onReply: () => _startReply(comment.id),
                            onDelete: () => _confirmDelete(context, comment.id),
                          );
                        },
                      ),
              ),
              CommentInput(
                postModel: postModel,
                currentUser: widget.user,
                onCommentSubmit: _handleCommentSubmit,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              widget.post['authorAvatar'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post['author'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.post['title'].isNotEmpty
                      ? widget.post['title']
                      : widget.post['content'].substring(0, 50) + '...',
                  style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.comment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            S.of(context).noCommentsYet,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).beFirstToComment,
            style: TextStyle(color: Colors.grey[500]!, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _startReply(int commentId) {
    // This will be handled by the CommentInput widget
  }

  void _handleCommentSubmit(String text, bool isReply, int? replyToId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    if (isReply && replyToId != null) {
      // Add as reply
      await context.read<PostsCubit>().addReply(
        postId: widget.post['id'],
        commentId: replyToId,
        text: text,
        token: token,
      );
    } else {
      // Add as new comment
      await context.read<PostsCubit>().addComment(
        postId: widget.post['id'],
        text: text,
        token: token,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).commentAddedSuccessfully)),
    );
  }

  void _confirmDelete(BuildContext context, int commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).delete),
        content: Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      await context.read<PostsCubit>().deleteComment(
        commentId: commentId,
        token: token,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).commentAddedSuccessfully),
        ), // Use as placeholder
      );
    }
  }
}
