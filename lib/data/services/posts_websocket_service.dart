import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../model/post_model.dart';

class PostsWebSocketService {
  final String token;
  final String baseUrl;
  WebSocketChannel? _channel;

  PostsWebSocketService({
    required this.token,
    this.baseUrl = 'ws://10.15.249.81:8000/posts/posts',
  });

  Stream<PostModel> connect() {
    final url = '$baseUrl?token=$token';
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
