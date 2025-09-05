import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/chat_repo.dart';
import '../../data/repo/group_repo.dart';
import '../../data/model/chat_room_model.dart';
import '../../data/model/group_model.dart';
import '../../data/model/unified_chat_model.dart';
import '../../data/model/message_model.dart';
import '../../data/services/chat_websocket_service.dart';
import 'chat_state.dart';

enum ChatFilter { all, individual, groups }

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  final GroupRepo _groupRepo;
  ChatWebSocketService? _webSocketService;
  Stream<MessageModel>? _wsStream;
  List<MessageModel> _allMessages = [];
  List<ChatRoomModel> _allChatRooms = [];
  List<GroupModel> _allGroups = [];
  List<UnifiedChatModel> _allUnifiedChats = [];
  ChatFilter _currentFilter = ChatFilter.all;
  String _currentUser = '';

  ChatCubit(this._chatRepo, this._groupRepo) : super(ChatInitial());

  // Unified Chat Methods
  Future<void> getAllChats({String? currentUser}) async {
    try {
      if (currentUser != null) {
        _currentUser = currentUser;
      }

      // Only show loading if we don't have any data
      if (_allUnifiedChats.isEmpty) {
        emit(ChatRoomsLoading());
      }

      // Fetch both individual chats and groups
      final chatRooms = await _chatRepo.getChatRooms();
      final groups = await _groupRepo.getGroups();

      _allChatRooms = chatRooms;
      _allGroups = groups;

      // Create unified chat list
      _allUnifiedChats = _createUnifiedChatList();

      emit(ChatRoomsLoaded(_allUnifiedChats));
    } catch (e) {
      emit(ChatRoomsError(e.toString()));
    }
  }

  // Legacy method for backward compatibility
  Future<void> getChatRooms() async {
    await getAllChats();
  }

  // Create unified chat list from individual chats and groups
  List<UnifiedChatModel> _createUnifiedChatList() {
    final List<UnifiedChatModel> unifiedChats = [];

    // Add individual chats
    for (final chatRoom in _allChatRooms) {
      unifiedChats.add(UnifiedChatModel.fromChatRoom(chatRoom, _currentUser));
    }

    // Add groups
    for (final group in _allGroups) {
      unifiedChats.add(UnifiedChatModel.fromGroup(group));
    }

    // Sort by last message time (most recent first)
    unifiedChats.sort((a, b) {
      if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
      if (a.lastMessageTime == null) return 1;
      if (b.lastMessageTime == null) return -1;
      return b.lastMessageTime!.compareTo(a.lastMessageTime!);
    });

    return unifiedChats;
  }

  // Filter methods
  void setFilter(ChatFilter filter) {
    _currentFilter = filter;
    _applyFilter();
  }

  void _applyFilter() {
    List<UnifiedChatModel> filteredChats = _allUnifiedChats;

    switch (_currentFilter) {
      case ChatFilter.individual:
        filteredChats = _allUnifiedChats
            .where((chat) => chat.isIndividualChat)
            .toList();
        break;
      case ChatFilter.groups:
        filteredChats = _allUnifiedChats.where((chat) => chat.isGroup).toList();
        break;
      case ChatFilter.all:
        filteredChats = _allUnifiedChats;
        break;
    }

    emit(ChatRoomsLoaded(_allUnifiedChats, filteredChatRooms: filteredChats));
  }

  // Messages Methods
  Future<void> getMessages(int roomId, {String? currentUsername}) async {
    try {
      emit(MessagesLoading());
      final messages = await _chatRepo.getMessages(
        roomId,
        currentUsername: currentUsername,
      );
      _allMessages = messages;
      emit(MessagesLoaded(_allMessages));
    } catch (e) {
      emit(MessagesError(e.toString()));
    }
  }

  // WebSocket Methods
  Future<void> connectWebSocket(
    String token,
    int roomId, {
    void Function(MessageModel)? onNewMessage,
    String? currentUsername,
  }) async {
    _webSocketService = ChatWebSocketService(
      token: token,
      roomId: roomId,
      currentUsername: currentUsername,
    );
    _wsStream = _webSocketService!.connect();
    _wsStream!.listen(
      (message) {
        // Check for duplicates by content and timestamp (within 5 seconds)
        final isDuplicate = _allMessages.any(
          (m) =>
              m.content == message.content &&
              m.sender == message.sender &&
              (m.createdAt.difference(message.createdAt).abs().inSeconds < 5),
        );

        if (!isDuplicate) {
          _allMessages.add(message);
          if (onNewMessage != null) {
            onNewMessage(message);
          } else {
            emit(MessageReceived(message));
            emit(MessagesLoaded(_allMessages));
          }
        }
      },
      onError: (e) {
        // On error, keep showing current messages
        emit(MessagesLoaded(_allMessages));
      },
      onDone: () {
        // On close, keep showing current messages
        emit(MessagesLoaded(_allMessages));
      },
    );
  }

  void disconnectWebSocket() {
    _webSocketService?.disconnect();
    // Clear messages when disconnecting to prevent state conflicts
    _allMessages.clear();
    // Emit the current unified chats state to ensure UI updates properly
    if (_allUnifiedChats.isNotEmpty) {
      _applyFilter();
    }
  }

  void sendMessage(
    String message, {
    String? currentUsername,
    String? displayName,
  }) {
    if (_webSocketService != null && message.trim().isNotEmpty) {
      _webSocketService!.sendMessage(message.trim());

      // Don't add local message - wait for WebSocket to receive it back from server
      // This prevents duplicates
    }
  }

  void refreshMessages(int roomId) {
    getMessages(roomId);
  }

  void clearChatRooms() {
    _allChatRooms.clear();
    _allGroups.clear();
    _allUnifiedChats.clear();
    emit(ChatInitial());
  }

  void searchChatRooms(String query) {
    if (query.trim().isEmpty) {
      // If search is empty, apply current filter
      _applyFilter();
    } else {
      // Filter unified chats by name or members
      final filteredChats = _allUnifiedChats.where((chat) {
        return chat.name.toLowerCase().contains(query.toLowerCase()) ||
            chat.members.any(
              (member) => member.toLowerCase().contains(query.toLowerCase()),
            );
      }).toList();

      emit(ChatRoomsLoaded(_allUnifiedChats, filteredChatRooms: filteredChats));
    }
  }

  void refreshChatRooms() {
    getAllChats();
  }

  void restoreChatRoomsState() {
    if (_allUnifiedChats.isNotEmpty) {
      _applyFilter();
    }
  }

  // Getters
  List<ChatRoomModel> get chatRooms => _allChatRooms;
  List<GroupModel> get groups => _allGroups;
  List<UnifiedChatModel> get unifiedChats => _allUnifiedChats;
  List<MessageModel> get messages => _allMessages;
  ChatFilter get currentFilter => _currentFilter;
}
