class MessageModel {
  final int id;
  final String sender;
  final String content;
  final DateTime createdAt;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.sender,
    required this.content,
    required this.createdAt,
    required this.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, {String? currentUsername}) {
    final sender = json['sender'];
    final isFromCurrentUser = currentUsername != null && 
        (sender == 'You' || sender == currentUsername);
    
    return MessageModel(
      id: json['id'],
      sender: sender,
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isMe: isFromCurrentUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // For WebSocket messages
  factory MessageModel.fromWebSocket(Map<String, dynamic> json, {String? currentUsername}) {
    final sender = json['sender'] ?? 'Unknown';
    final isFromCurrentUser = currentUsername != null && 
        (sender == 'You' || sender == currentUsername);
    
    return MessageModel(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary ID for WebSocket messages
      sender: sender,
      content: json['message'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isMe: isFromCurrentUser,
    );
  }
}
