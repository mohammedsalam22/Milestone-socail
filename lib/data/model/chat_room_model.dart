class ChatRoomModel {
  final int id;
  final String studentName;
  final LastMessage? lastMessage;

  ChatRoomModel({
    required this.id,
    required this.studentName,
    this.lastMessage,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'],
      studentName: json['student_name'],
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'last_message': lastMessage?.toJson(),
    };
  }
}

class LastMessage {
  final String content;
  final DateTime createdAt;
  final String sender;

  LastMessage({
    required this.content,
    required this.createdAt,
    required this.sender,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      sender: json['sender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'sender': sender,
    };
  }
} 