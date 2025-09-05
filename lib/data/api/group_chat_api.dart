import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/message_model.dart';

class GroupChatApi {
  final ApiService _apiService;

  GroupChatApi(this._apiService);

  Future<List<MessageModel>> getGroupMessages(
    int groupId, {
    String? currentUsername,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.groupMessages,
        params: {'room_id': groupId},
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
          'Failed to fetch group messages. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
