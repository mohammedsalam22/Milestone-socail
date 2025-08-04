class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'http://10.218.65.81:8000';
  static const String wsBaseUrl = 'ws://10.218.65.81:8000';

  // REST API Endpoints
  static const String login = '/api/users/auth/login/';
  static const String chatRooms = '/api/chat/chat-rooms';
  static const String messages = '/api/chat/messages';
  static const String posts = '/api/posts/posts';
  static const String comments = '/api/posts/comments';

  // WebSocket Endpoints
  static const String chatWebSocket = '/ws/chat';
  static const String postsWebSocket = '/ws/posts';

  // Helper methods for WebSocket URLs
  static String getChatWebSocketUrl(int roomId, String token) {
    return '$wsBaseUrl$chatWebSocket/$roomId/?token=$token';
  }

  static String getPostsWebSocketUrl(String token) {
    return '$wsBaseUrl$postsWebSocket/?token=$token';
  }
}
