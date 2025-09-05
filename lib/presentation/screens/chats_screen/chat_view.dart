import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/user_model.dart';
import '../../../bloc/chat/chat_cubit.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../data/model/unified_chat_model.dart';
import '../../../bloc/students/students_cubit.dart';
import '../../../bloc/employees/employees_cubit.dart';
import '../../../bloc/groups/groups_cubit.dart';
import '../../../bloc/group_chat/group_chat_cubit.dart';
import '../../../generated/l10n.dart';
import '../../../core/utils/role_utils.dart';
import '../../../di_container.dart';
import 'chat_screen.dart';
import 'group_chat_screen.dart';
import 'create_group_screen.dart';
import 'group_info_screen.dart';
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
    if (_chatCubit.unifiedChats.isNotEmpty) {
      // If we have data, restore the loaded state
      _chatCubit.restoreChatRoomsState();
    } else {
      // If no data, fetch it
      _chatCubit.getAllChats(
        currentUser: widget.user.firstName + ' ' + widget.user.lastName,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This ensures the state is correct when the widget is rebuilt
    if (_chatCubit.unifiedChats.isNotEmpty &&
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildFilterChips(),
        ),
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          // Get the current unified chats (either from state or memory)
          final chatRooms = state is ChatRoomsLoaded
              ? state.filteredChatRooms
              : _chatCubit.unifiedChats;

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
                _chatCubit.getAllChats(
                  currentUser:
                      widget.user.firstName + ' ' + widget.user.lastName,
                );
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

  Widget _buildChatItem(UnifiedChatModel unifiedChat) {
    final chat = unifiedChat.toChatItemMap();

    return ChatItem(
      chat: chat,
      currentUser: widget.user,
      onTap: () => _openChat(unifiedChat),
      onAvatarTap: unifiedChat.isGroup
          ? () => _openGroupInfo(unifiedChat)
          : null,
      onTogglePin: _togglePin,
      onToggleMute: _toggleMute,
      onDelete: _deleteChat,
    );
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

  void _openChat(UnifiedChatModel unifiedChat) {
    if (unifiedChat.isGroup) {
      // Navigate to group chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => DIContainer.get<GroupChatCubit>(),
              ),
            ],
            child: GroupChatScreen(
              group: unifiedChat.groupData!,
              user: widget.user,
            ),
          ),
        ),
      );
    } else if (unifiedChat.chatRoomData != null) {
      // Navigate to individual chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoom: unifiedChat.chatRoomData!,
            user: widget.user,
          ),
        ),
      );
    }
  }

  void _openGroupInfo(UnifiedChatModel unifiedChat) {
    if (unifiedChat.isGroup && unifiedChat.groupData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => DIContainer.get<GroupsCubit>()),
            ],
            child: GroupInfoScreen(
              group: unifiedChat.groupData!,
              currentUser: widget.user,
            ),
          ),
        ),
      ).then((groupDeleted) {
        // If group was deleted, refresh the chat list
        if (groupDeleted == true) {
          _chatCubit.getAllChats(
            currentUser: widget.user.firstName + ' ' + widget.user.lastName,
          );
        }
      });
    }
  }

  void _createNewGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => DIContainer.get<StudentsCubit>()),
            BlocProvider(
              create: (context) => DIContainer.get<EmployeesCubit>(),
            ),
            BlocProvider(create: (context) => DIContainer.get<GroupsCubit>()),
          ],
          child: CreateGroupScreen(
            user: widget.user,
            onGroupCreated: (newGroup) {
              // Refresh the unified chats to show the new group
              _chatCubit.getAllChats(
                currentUser: widget.user.firstName + ' ' + widget.user.lastName,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).groupCreatedSuccessfully)),
              );
            },
          ),
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

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('All', ChatFilter.all),
          const SizedBox(width: 8),
          _buildFilterChip('Individual', ChatFilter.individual),
          const SizedBox(width: 8),
          _buildFilterChip('Groups', ChatFilter.groups),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ChatFilter filter) {
    final isSelected = _chatCubit.currentFilter == filter;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _chatCubit.setFilter(filter);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.grey[200],
    );
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
