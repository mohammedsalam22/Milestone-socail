import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';
import '../../../generated/l10n.dart';
import 'chat_screen.dart';
import 'create_group_screen.dart';
import 'widgets/chat_item.dart';
import 'widgets/empty_chats.dart';

class ChatsView extends StatefulWidget {
  final UserModel user;

  const ChatsView({super.key, required this.user});

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView> {
  final List<Map<String, dynamic>> _chats = [
    {
      'id': 1,
      'name': 'Parent-Teacher Group',
      'avatar': 'PT',
      'lastMessage': 'Meeting scheduled for tomorrow at 3 PM',
      'lastMessageTime': '2:30 PM',
      'unreadCount': 3,
      'isGroup': true,
      'members': ['Admin', 'Sarah Wilson', 'Mike Johnson', 'Emily Davis'],
      'isMuted': false,
      'isPinned': true,
    },
    {
      'id': 2,
      'name': 'Sarah Wilson',
      'avatar': 'S',
      'lastMessage': 'Thank you for the update!',
      'lastMessageTime': '1:45 PM',
      'unreadCount': 0,
      'isGroup': false,
      'members': ['Admin', 'Sarah Wilson'],
      'isMuted': false,
      'isPinned': false,
    },
    {
      'id': 3,
      'name': 'Mike Johnson',
      'avatar': 'M',
      'lastMessage': 'Can we discuss the homework assignment?',
      'lastMessageTime': '11:20 AM',
      'unreadCount': 1,
      'isGroup': false,
      'members': ['Admin', 'Mike Johnson'],
      'isMuted': true,
      'isPinned': false,
    },
    {
      'id': 4,
      'name': 'Science Class Group',
      'avatar': 'SC',
      'lastMessage': 'Great work on the experiments!',
      'lastMessageTime': 'Yesterday',
      'unreadCount': 0,
      'isGroup': true,
      'members': ['Admin', 'Students'],
      'isMuted': false,
      'isPinned': false,
    },
    {
      'id': 5,
      'name': 'Emily Davis',
      'avatar': 'E',
      'lastMessage': 'I have a question about the project',
      'lastMessageTime': 'Yesterday',
      'unreadCount': 2,
      'isGroup': false,
      'members': ['Admin', 'Emily Davis'],
      'isMuted': false,
      'isPinned': false,
    },
  ];

  bool get _isAdmin => widget.user.role.toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          S.of(context).chats,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(onPressed: _searchChats, icon: const Icon(Icons.search)),
          if (_isAdmin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'new_group') {
                  _createNewGroup();
                } else if (value == 'new_chat') {
                  _createNewChat();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'new_group',
                  child: Row(
                    children: [
                      const Icon(Icons.group_add),
                      const SizedBox(width: 8),
                      Text(S.of(context).newGroup),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'new_chat',
                  child: Row(
                    children: [
                      const Icon(Icons.person_add),
                      const SizedBox(width: 8),
                      Text(S.of(context).newChat),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _chats.isEmpty
          ? EmptyChats(currentUser: widget.user)
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ChatItem(
                  chat: chat,
                  currentUser: widget.user,
                  onTap: () => _openChat(chat),
                  onTogglePin: _togglePin,
                  onToggleMute: _toggleMute,
                  onDelete: _deleteChat,
                );
              },
            ),
      floatingActionButton: _isAdmin ? _buildCreateButton() : null,
    );
  }

  Widget _buildCreateButton() {
    return FloatingActionButton(
      onPressed: _showCreateOptions,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.chat),
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group_add, color: Colors.green),
              title: Text(S.of(context).newGroup),
              subtitle: const Text('Create a group chat'),
              onTap: () {
                Navigator.pop(context);
                _createNewGroup();
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: Text(S.of(context).newChat),
              subtitle: const Text('Start a private conversation'),
              onTap: () {
                Navigator.pop(context);
                _createNewChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chat: chat, user: widget.user),
      ),
    );
  }

  void _createNewGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGroupScreen(
          user: widget.user,
          onGroupCreated: (newGroup) {
            setState(() {
              _chats.insert(0, newGroup);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(S.of(context).groupCreatedSuccessfully)),
            );
          },
        ),
      ),
    );
  }

  void _createNewChat() {
    // TODO: Implement new chat creation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).newChatFeatureComingSoon)),
    );
  }

  void _searchChats() {
    // TODO: Implement chat search
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of(context).searchFeatureComingSoon)),
    );
  }

  void _togglePin(int chatId) {
    setState(() {
      final chat = _chats.firstWhere((chat) => chat['id'] == chatId);
      chat['isPinned'] = !chat['isPinned'];
    });
  }

  void _toggleMute(int chatId) {
    setState(() {
      final chat = _chats.firstWhere((chat) => chat['id'] == chatId);
      chat['isMuted'] = !chat['isMuted'];
    });
  }

  void _deleteChat(int chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteChat),
        content: Text(S.of(context).areYouSureDeleteChat),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _chats.removeWhere((chat) => chat['id'] == chatId);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).chatDeletedSuccessfully)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.of(context).delete),
          ),
        ],
      ),
    );
  }
}
