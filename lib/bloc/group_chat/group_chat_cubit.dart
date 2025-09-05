import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/api/group_chat_api.dart';
import '../../data/model/message_model.dart';
import '../../data/services/group_chat_websocket_service.dart';
import 'group_chat_state.dart';

class GroupChatCubit extends Cubit<GroupChatState> {
  final GroupChatApi _groupChatApi;
  GroupChatWebSocketService? _webSocketService;
  Stream<MessageModel>? _wsStream;
  List<MessageModel> _allMessages = [];

  GroupChatCubit(this._groupChatApi) : super(GroupChatInitial());

  // Messages Methods
  Future<void> getGroupMessages(int groupId, {String? currentUsername}) async {
    try {
      emit(GroupMessagesLoading());
      final messages = await _groupChatApi.getGroupMessages(
        groupId,
        currentUsername: currentUsername,
      );
      _allMessages = messages;
      emit(GroupMessagesLoaded(_allMessages));
    } catch (e) {
      emit(GroupMessagesError(e.toString()));
    }
  }

  // WebSocket Methods
  Future<void> connectWebSocket(
    String token,
    int groupId, {
    void Function(MessageModel)? onNewMessage,
    String? currentUsername,
  }) async {
    _webSocketService = GroupChatWebSocketService(
      token: token,
      groupId: groupId,
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
            emit(GroupMessageReceived(message));
            emit(GroupMessagesLoaded(_allMessages));
          }
        }
      },
      onError: (e) {
        // On error, keep showing current messages
        emit(GroupMessagesLoaded(_allMessages));
      },
      onDone: () {
        // On close, keep showing current messages
        emit(GroupMessagesLoaded(_allMessages));
      },
    );
  }

  void disconnectWebSocket() {
    _webSocketService?.disconnect();
    // Clear messages when disconnecting to prevent state conflicts
    _allMessages.clear();
    emit(GroupChatInitial());
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

  void refreshMessages(int groupId) {
    getGroupMessages(groupId);
  }

  // Getters
  List<MessageModel> get messages => _allMessages;
}
