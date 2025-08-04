import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/user_model.dart';
import '../../../data/model/chat_room_model.dart';
import '../../../bloc/chat/chat_cubit.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../generated/l10n.dart';
import '../../../core/utils/role_utils.dart';
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
  late ChatCubit _chatCubit;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatCubit = context.read<ChatCubit>();
    // Ensure we have the correct state when returning to this screen
    if (_chatCubit.chatRooms.isNotEmpty) {
      // If we have data, restore the loaded state
      _chatCubit.restoreChatRoomsState();
    } else {
      // If no data, fetch it
      _chatCubit.getChatRooms();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures the state is correct when the widget is rebuilt
    if (_chatCubit.chatRooms.isNotEmpty &&
        _chatCubit.state is! ChatRoomsLoaded) {
      _chatCubit.restoreChatRoomsState();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isAdmin => RoleUtils.isAdmin(widget.user.role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search chats...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[600]),
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (query) {
                  _chatCubit.searchChatRooms(query);
                },
              )
            : Text(
                S.of(context).chats,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (_isSearching)
            IconButton(onPressed: _cancelSearch, icon: const Icon(Icons.close))
          else
            IconButton(onPressed: _startSearch, icon: const Icon(Icons.search)),
          if (_isAdmin && !_isSearching)
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
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          // Get the current chat rooms (either from state or memory)
          final chatRooms = state is ChatRoomsLoaded
              ? state.filteredChatRooms
              : _chatCubit.chatRooms;

          if (state is ChatRoomsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatRoomsError) {
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
                    onPressed: () => _chatCubit.refreshChatRooms(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (chatRooms.isNotEmpty) {
            // Show chat rooms if we have them (regardless of state)
            return RefreshIndicator(
              onRefresh: () async {
                _chatCubit.refreshChatRooms();
              },
              child: ListView.builder(
                itemCount: chatRooms.length,
                itemBuilder: (context, index) {
                  final chatRoom = chatRooms[index];
                  return _buildChatItem(chatRoom);
                },
              ),
            );
          } else {
            // Show empty state or loading
            if (state is ChatRoomsLoaded && state.chatRooms.isEmpty) {
              return EmptyChats(currentUser: widget.user);
            } else if (state is ChatRoomsLoaded &&
                state.filteredChatRooms.isEmpty &&
                _searchController.text.isNotEmpty) {
              // Show no results found when searching
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No chats found for "${_searchController.text}"',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: _isAdmin ? _buildCreateButton() : null,
    );
  }

  Widget _buildChatItem(ChatRoomModel chatRoom) {
    final chat = {
      'id': chatRoom.id,
      'name': chatRoom.studentName,
      'avatar': chatRoom.studentName.isNotEmpty
          ? chatRoom.studentName[0].toUpperCase()
          : '?',
      'lastMessage': chatRoom.lastMessage?.content ?? 'No messages yet',
      'lastMessageTime': chatRoom.lastMessage != null
          ? _formatTime(chatRoom.lastMessage!.createdAt)
          : '',
      'unreadCount': 0, // TODO: Implement unread count
      'isGroup': false,
      'members': [
        widget.user.firstName + ' ' + widget.user.lastName,
        chatRoom.studentName,
      ],
      'isMuted': false,
      'isPinned': false,
    };

    return ChatItem(
      chat: chat,
      currentUser: widget.user,
      onTap: () => _openChat(chatRoom),
      onTogglePin: _togglePin,
      onToggleMute: _toggleMute,
      onDelete: _deleteChat,
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

  Widget _buildCreateButton() {
    return FloatingActionButton(
      onPressed: _showCreateOptions,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.chat),
      tooltip: 'Create New Chat',
      heroTag: 'create_chat_fab',
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

  void _openChat(ChatRoomModel chatRoom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(chatRoom: chatRoom, user: widget.user),
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
            // TODO: Implement group creation
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
      const SnackBar(content: Text('New chat feature coming soon!')),
    );
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    _chatCubit.searchChatRooms(''); // Reset to show all chats
  }

  void _togglePin(int chatId) {
    // TODO: Implement pin functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pin feature coming soon!')));
  }

  void _toggleMute(int chatId) {
    // TODO: Implement mute functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mute feature coming soon!')));
  }

  void _deleteChat(int chatId) {
    // TODO: Implement delete functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete feature coming soon!')),
    );
  }
}
