import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../model/notification_model.dart';
import '../../core/constants/api_endpoints.dart';

class NotificationWebSocketService {
  final String token;
  WebSocketChannel? _channel;

  NotificationWebSocketService({required this.token});

  Stream<NotificationModel> connect() {
    final url = ApiEndpoints.getNotificationsWebSocketUrl(token);
    _channel = WebSocketChannel.connect(Uri.parse(url));

    return _channel!.stream.map((event) {
      try {
        final data = json.decode(event);
        return NotificationModel.fromWebSocket(data);
      } catch (e) {
        // Handle JSON parsing errors gracefully
        print('Error parsing notification data: $e');
        return NotificationModel(
          type: 'error',
          message: 'Failed to parse notification: $e',
          timestamp: DateTime.now(),
        );
      }
    });
  }

  void disconnect() {
    _channel?.sink.close();
  }

  bool get isConnected => _channel != null;
}
