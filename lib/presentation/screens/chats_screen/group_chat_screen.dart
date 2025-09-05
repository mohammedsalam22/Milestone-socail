import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../data/model/user_model.dart';
import '../../../data/model/group_model.dart';
import '../../../data/model/message_model.dart';
import '../../../bloc/group_chat/group_chat_cubit.dart';
import '../../../bloc/group_chat/group_chat_state.dart';
import '../../../generated/l10n.dart';

class GroupChatScreen extends StatefulWidget {
  final GroupModel group;
  final UserModel user;

  const GroupChatScreen({super.key, required this.group, required this.user});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late GroupChatCubit _groupChatCubit;
  String? _authToken;

  String? _currentUsername;
  String get _currentDisplayName =>
      widget.user.firstName + ' ' + widget.user.lastName;

  @override
  void initState() {
    super.initState();
    _groupChatCubit = context.read<GroupChatCubit>();
    _initializeGroupChat();
  }

  Future<void> _initializeGroupChat() async {
    // Get auth token and user info
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');

    // Get username from stored user info
    final userJson = prefs.getString('user_info');
    if (userJson != null) {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      _currentUsername = userData['username'] as String?;
    }

    if (_authToken != null) {
      // Load messages
      await _groupChatCubit.getGroupMessages(
        widget.group.id,
        currentUsername: _currentUsername,
      );

      // Connect to WebSocket
      await _groupChatCubit.connectWebSocket(
        _authToken!,
        widget.group.id,
        currentUsername: _currentUsername,
        onNewMessage: (message) {
          // Handle new message from WebSocket
          setState(() {});
        },
      );
    }
  }

  @override
  void dispose() {
    // Disconnect WebSocket and clear messages when leaving chat
    _groupChatCubit.disconnectWebSocket();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      _groupChatCubit.sendMessage(
        _controller.text.trim(),
        currentUsername: _currentUsername,
        displayName: _currentDisplayName,
      );
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.group.totalMembers} members',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement video call
            },
            icon: const Icon(Icons.video_call),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement voice call
            },
            icon: const Icon(Icons.call),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'group_info') {
                // Navigate to group info
                Navigator.pushNamed(
                  context,
                  '/group_info',
                  arguments: widget.group,
                );
              } else if (value == 'search') {
                // TODO: Implement search
              } else if (value == 'media') {
                // TODO: Implement media
              } else if (value == 'mute') {
                // TODO: Implement mute
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'group_info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Group Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text('Search'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'media',
                child: Row(
                  children: [
                    Icon(Icons.photo_library),
                    SizedBox(width: 8),
                    Text('Media'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.volume_off),
                    SizedBox(width: 8),
                    Text('Mute'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<GroupChatCubit, GroupChatState>(
              builder: (context, state) {
                if (state is GroupMessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GroupMessagesLoaded) {
                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet. Start the conversation!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          state.messages[state.messages.length - 1 - index];
                      return _buildMessageBubble(message);
                    },
                  );
                } else if (state is GroupMessagesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              _groupChatCubit.refreshMessages(widget.group.id),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: _getMemberColor(message.sender),
              child: Text(
                message.sender.isNotEmpty
                    ? message.sender[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isMe
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isMe)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.sender,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: message.isMe
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: message.isMe ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                widget.user.firstName.isNotEmpty
                    ? widget.user.firstName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              // TODO: Implement attachment picker
            },
            icon: const Icon(Icons.attach_file),
            color: Colors.grey[600],
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: S.of(context).typeMessage,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            mini: true,
            child: const Icon(Icons.send),
            tooltip: 'Send Message',
            heroTag: 'send_group_message_fab',
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getMemberColor(String memberName) {
    // Generate consistent color based on member name
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.red,
    ];
    final index = memberName.hashCode % colors.length;
    return colors[index];
  }
}
