class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'http://10.199.2.81:8000';
  static const String wsBaseUrl = 'ws://10.199.2.81:8000';

  // REST API Endpoints
  static const String login = '/api/users/auth/login/';
  static const String chatRooms = '/api/chat/chat-rooms';
  static const String messages = '/api/chat/messages';
  static const String posts = '/api/posts/posts';
  static const String comments = '/api/posts/comments';
  static const String students = '/api/users/students';
  static const String incidents = '/api/school/event';
  static const String attendances = '/api/school/attendances/';
  static const String marks = '/api/school/marks/';
  static const String schedules = '/api/school/schedules';
  static const String employees = '/api/users/employees';
  static const String groupRooms = '/api/chat/group-rooms';
  static const String groupMessages = '/api/chat/group-messages';

  // WebSocket Endpoints
  static const String chatWebSocket = '/ws/chat';
  static const String groupChatWebSocket = '/ws/group-chat';
  static const String postsWebSocket = '/ws/posts';
  static const String notificationsWebSocket = '/ws/notifications';

  // Helper methods for WebSocket URLs
  static String getChatWebSocketUrl(int roomId, String token) {
    return '$wsBaseUrl$chatWebSocket/$roomId/?token=$token';
  }

  static String getGroupChatWebSocketUrl(int groupId, String token) {
    return '$wsBaseUrl$groupChatWebSocket/$groupId/?token=$token';
  }

  static String getPostsWebSocketUrl(String token) {
    return '$wsBaseUrl$postsWebSocket/?token=$token';
  }

  static String getNotificationsWebSocketUrl(String token) {
    return '$wsBaseUrl$notificationsWebSocket/?token=$token';
  }
}
