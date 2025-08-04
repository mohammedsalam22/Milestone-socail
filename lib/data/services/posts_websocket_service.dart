import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../model/post_model.dart';
import '../../core/constants/api_endpoints.dart';

class PostsWebSocketService {
  final String token;
  WebSocketChannel? _channel;

  PostsWebSocketService({required this.token});

  Stream<PostModel> connect() {
    final url = ApiEndpoints.getPostsWebSocketUrl(token);
    _channel = WebSocketChannel.connect(Uri.parse(url));
    return _channel!.stream.map((event) {
      final data = json.decode(event);
      return PostModel.fromJson(data);
    });
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
