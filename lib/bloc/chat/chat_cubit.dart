import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/chat_repo.dart';
import '../../data/model/chat_room_model.dart';
import '../../data/model/message_model.dart';
import '../../data/services/chat_websocket_service.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  ChatWebSocketService? _webSocketService;
  Stream<MessageModel>? _wsStream;
  List<MessageModel> _allMessages = [];
  List<ChatRoomModel> _allChatRooms = [];

  ChatCubit(this._chatRepo) : super(ChatInitial());

  // Chat Rooms Methods
  Future<void> getChatRooms() async {
    try {
      // Only show loading if we don't have any chat rooms
      if (_allChatRooms.isEmpty) {
        emit(ChatRoomsLoading());
      }
      final chatRooms = await _chatRepo.getChatRooms();
      _allChatRooms = chatRooms;
      emit(ChatRoomsLoaded(_allChatRooms));
    } catch (e) {
      emit(ChatRoomsError(e.toString()));
    }
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
    // Emit the current chat rooms state to ensure UI updates properly
    if (_allChatRooms.isNotEmpty) {
      emit(ChatRoomsLoaded(_allChatRooms));
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

  void refreshChatRooms() {
    getChatRooms();
  }

  void refreshMessages(int roomId) {
    getMessages(roomId);
  }

  void clearChatRooms() {
    _allChatRooms.clear();
    emit(ChatInitial());
  }

  void restoreChatRoomsState() {
    if (_allChatRooms.isNotEmpty) {
      emit(ChatRoomsLoaded(_allChatRooms));
    }
  }

  void searchChatRooms(String query) {
    if (query.trim().isEmpty) {
      // If search is empty, show all chat rooms
      emit(ChatRoomsLoaded(_allChatRooms));
    } else {
      // Filter chat rooms by student name
      final filteredRooms = _allChatRooms.where((room) {
        return room.studentName.toLowerCase().contains(query.toLowerCase());
      }).toList();
      
      emit(ChatRoomsLoaded(_allChatRooms, filteredChatRooms: filteredRooms));
    }
  }

  List<ChatRoomModel> get chatRooms => _allChatRooms;
  List<MessageModel> get messages => _allMessages;
}
