class MessageModel {
  final int id;
  final String sender;
  final String content;
  final DateTime timestamp;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });
}
