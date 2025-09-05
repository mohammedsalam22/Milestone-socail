import '../api/group_chat_api.dart';
import '../model/message_model.dart';

class GroupChatRepo {
  final GroupChatApi _groupChatApi;

  GroupChatRepo(this._groupChatApi);

  Future<List<MessageModel>> getGroupMessages(
    int groupId, {
    String? currentUsername,
  }) async {
    return await _groupChatApi.getGroupMessages(
      groupId,
      currentUsername: currentUsername,
    );
  }
}
