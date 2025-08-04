import '../api/chat_api.dart';
import '../model/chat_room_model.dart';
import '../model/message_model.dart';

class ChatRepo {
  final ChatApi _chatApi;

  ChatRepo(this._chatApi);

  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      return await _chatApi.getChatRooms();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessages(int roomId, {String? currentUsername}) async {
    try {
      return await _chatApi.getMessages(roomId, currentUsername: currentUsername);
    } catch (e) {
      rethrow;
    }
  }
} 