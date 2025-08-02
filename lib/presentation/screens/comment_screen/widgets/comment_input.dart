import 'package:flutter/material.dart';
import '../../../../../data/model/post_model.dart';
import '../../../../../data/model/user_model.dart';
import '../../../../../generated/l10n.dart';

class CommentInput extends StatefulWidget {
  final PostModel postModel;
  final UserModel currentUser;
  final Function(String text, bool isReply, int? replyToId) onCommentSubmit;

  const CommentInput({
    super.key,
    required this.postModel,
    required this.currentUser,
    required this.onCommentSubmit,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _commentController = TextEditingController();
  bool _isReplying = false;
  int? _replyingToId;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void startReply(int commentId) {
    setState(() {
      _isReplying = true;
      _replyingToId = commentId;
      _commentController.text = '';
    });
  }

  void _submitComment() {
    if (_commentController.text.trim().isEmpty) return;

    widget.onCommentSubmit(
      _commentController.text.trim(),
      _isReplying,
      _replyingToId,
    );

    _commentController.clear();
    setState(() {
      _isReplying = false;
      _replyingToId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              widget.currentUser.firstName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: _isReplying
                    ? S.of(context).writeAReply
                    : S.of(context).writeAComment,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                suffixIcon: _commentController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _submitComment,
                        icon: const Icon(Icons.send),
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
