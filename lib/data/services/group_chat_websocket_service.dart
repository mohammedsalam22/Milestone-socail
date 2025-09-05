import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../model/message_model.dart';
import '../../core/constants/api_endpoints.dart';

class GroupChatWebSocketService {
  final String token;
  final int groupId;
  final String? currentUsername;
  WebSocketChannel? _channel;

  GroupChatWebSocketService({
    required this.token,
    required this.groupId,
    this.currentUsername,
  });

  Stream<MessageModel> connect() {
    final url = ApiEndpoints.getGroupChatWebSocketUrl(groupId, token);
    _channel = WebSocketChannel.connect(Uri.parse(url));
    return _channel!.stream.map((event) {
      final data = json.decode(event);
      return MessageModel.fromWebSocket(data, currentUsername: currentUsername);
    });
  }

  void sendMessage(String message) {
    if (_channel != null) {
      final messageData = {'message': message};
      _channel!.sink.add(json.encode(messageData));
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
