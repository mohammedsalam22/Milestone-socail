import 'package:flutter/material.dart';
import '../../../../../data/model/post_model.dart';
import '../../../../../data/model/user_model.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../core/utils/role_utils.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;
  final UserModel currentUser;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.comment,
    required this.currentUser,
    required this.onReply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthorOrAdmin =
        comment.user.username == currentUser.username ||
        RoleUtils.isAdmin(currentUser.role);

    return GestureDetector(
      onLongPress: isAuthorOrAdmin ? onDelete : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  comment.user.firstName.isNotEmpty
                      ? comment.user.firstName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.user.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getTimeAgo(comment.createdAt),
                          style: TextStyle(
                            color: Colors.grey[600]!,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.text,
                      style: const TextStyle(fontSize: 14, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.reply,
                          label: S.of(context).reply,
                          color: Colors.grey[600]!,
                          onTap: onReply,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 44),
              child: Column(
                children: comment.replies
                    .map(
                      (reply) => ReplyCard(
                        reply: reply,
                        currentUser: currentUser,
                        onDelete: onDelete,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool small = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: small ? 14 : 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: small ? 11 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class ReplyCard extends StatelessWidget {
  final CommentModel reply;
  final UserModel currentUser;
  final VoidCallback? onDelete;

  const ReplyCard({
    super.key,
    required this.reply,
    required this.currentUser,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAuthorOrAdmin =
        reply.user.username == currentUser.username ||
        RoleUtils.isAdmin(currentUser.role);

    return GestureDetector(
      onLongPress: isAuthorOrAdmin ? onDelete : null,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                reply.user.firstName.isNotEmpty
                    ? reply.user.firstName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        reply.user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTimeAgo(reply.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600]!,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reply.text,
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
