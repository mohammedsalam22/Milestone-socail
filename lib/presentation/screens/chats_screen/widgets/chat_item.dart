import 'package:flutter/material.dart';
import '../../../../../data/model/user_model.dart';
import '../../../../../generated/l10n.dart';
import '../../../../../core/utils/role_utils.dart';

class ChatItem extends StatelessWidget {
  final Map<String, dynamic> chat;
  final UserModel currentUser;
  final VoidCallback onTap;
  final VoidCallback? onAvatarTap;
  final Function(int) onTogglePin;
  final Function(int) onToggleMute;
  final Function(int) onDelete;

  const ChatItem({
    super.key,
    required this.chat,
    required this.currentUser,
    required this.onTap,
    this.onAvatarTap,
    required this.onTogglePin,
    required this.onToggleMute,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = RoleUtils.isAdmin(currentUser.role);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildAvatar(),
        title: _buildTitle(),
        subtitle: _buildSubtitle(),
        onTap: onTap,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) {
            if (value == 'pin') {
              onTogglePin(chat['id']);
            } else if (value == 'mute') {
              onToggleMute(chat['id']);
            } else if (value == 'delete') {
              onDelete(chat['id']);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'pin',
              child: Row(
                children: [
                  Icon(
                    chat['isPinned'] ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(chat['isPinned'] ? 'Unpin' : 'Pin'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(
                    chat['isMuted'] ? Icons.volume_up : Icons.volume_off,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(chat['isMuted'] ? 'Unmute' : 'Mute'),
                ],
              ),
            ),
            if (isAdmin)
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      S.of(context).delete,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: chat['isGroup'] && onAvatarTap != null ? onAvatarTap : null,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: _getChatColor(),
            child: Text(
              chat['avatar'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (chat['isGroup'])
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.group, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            chat['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (chat['isPinned'])
          const Icon(Icons.push_pin, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          chat['lastMessageTime'],
          style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show members for groups
        if (chat['isGroup'] && chat['members'] != null) ...[
          Text(
            _formatMembersList(chat['members']),
            style: TextStyle(
              color: Colors.grey[500]!,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
        ],
        // Show last message or mute indicator
        Row(
          children: [
            if (chat['isMuted'])
              const Icon(Icons.volume_off, size: 14, color: Colors.grey),
            if (chat['isMuted']) const SizedBox(width: 4),
            Expanded(
              child: Text(
                chat['lastMessage'],
                style: TextStyle(color: Colors.grey[600]!, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (chat['unreadCount'] > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${chat['unreadCount']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _formatMembersList(List<dynamic> members) {
    if (members.isEmpty) return 'No members';

    // Limit to first 3 members to avoid overflow
    final displayMembers = members.take(3).toList();
    final memberNames = displayMembers
        .map((member) => member.toString())
        .join(', ');

    if (members.length > 3) {
      return '$memberNames +${members.length - 3} more';
    }

    return memberNames;
  }

  Color _getChatColor() {
    if (chat['isGroup']) {
      return Colors.green;
    }
    // Generate consistent color based on chat name
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    final index = chat['name'].hashCode % colors.length;
    return colors[index];
  }
}
