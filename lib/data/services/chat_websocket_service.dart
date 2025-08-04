import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../model/message_model.dart';
import '../../core/constants/api_endpoints.dart';

class ChatWebSocketService {
  final String token;
  final int roomId;
  final String? currentUsername;
  WebSocketChannel? _channel;

  ChatWebSocketService({
    required this.token,
    required this.roomId,
    this.currentUsername,
  });

  Stream<MessageModel> connect() {
    final url = ApiEndpoints.getChatWebSocketUrl(roomId, token);
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
