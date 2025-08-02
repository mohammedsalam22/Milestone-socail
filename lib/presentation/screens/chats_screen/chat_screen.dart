import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';
import '../../../data/model/message_model.dart';
import '../../../generated/l10n.dart';

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chat;
  final UserModel user;

  const ChatScreen({super.key, required this.chat, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final List<MessageModel> _messages;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messages = [
      MessageModel(
        id: 1,
        sender: 'Admin',
        content: 'Hello! Welcome to our school community.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isMe: false,
      ),
      MessageModel(
        id: 2,
        sender: widget.user.firstName + ' ' + widget.user.lastName,
        content: 'Thank you! I\'m excited to be here.',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 45),
        ),
        isMe: true,
      ),
      MessageModel(
        id: 3,
        sender: 'Admin',
        content: 'Great! If you have any questions, feel free to ask.',
        timestamp: DateTime.now().subtract(
          const Duration(hours: 1, minutes: 30),
        ),
        isMe: false,
      ),
      MessageModel(
        id: 4,
        sender: widget.user.firstName + ' ' + widget.user.lastName,
        content: 'Will do! Looking forward to a great year.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isMe: true,
      ),
      MessageModel(
        id: 5,
        sender: 'Admin',
        content:
            'Perfect! Don\'t forget to check the school calendar for upcoming events.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        isMe: false,
      ),
    ];
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(
          MessageModel(
            id: _messages.length + 1,
            sender: widget.user.firstName + ' ' + widget.user.lastName,
            content: _controller.text.trim(),
            timestamp: DateTime.now(),
            isMe: true,
          ),
        );
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat['name'] ?? S.of(context).chats),
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
              // TODO: Implement menu actions
            },
            itemBuilder: (context) => [
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
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
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
              backgroundColor: Colors.grey[300],
              child: Text(
                message.sender[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
                      _formatTime(message.timestamp),
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
                widget.user.firstName[0].toUpperCase(),
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
}
