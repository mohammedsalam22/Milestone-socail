import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/chat_room_model.dart';
import '../model/message_model.dart';

class ChatApi {
  final ApiService _apiService;

  ChatApi(this._apiService);

  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      final response = await _apiService.get(ApiEndpoints.chatRooms);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> chatRoomsData = response.data;
        return chatRoomsData
            .map((chatRoomJson) => ChatRoomModel.fromJson(chatRoomJson))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch chat rooms. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessages(
    int roomId, {
    String? currentUsername,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.messages,
        params: {'room_id': roomId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> messagesData = response.data;
        return messagesData
            .map(
              (messageJson) => MessageModel.fromJson(
                messageJson,
                currentUsername: currentUsername,
              ),
            )
            .toList();
      } else {
        throw Exception(
          'Failed to fetch messages. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
