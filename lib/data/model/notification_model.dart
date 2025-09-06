class NotificationModel {
  final String type;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? payload;

  NotificationModel({
    required this.type,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.payload,
  });

  factory NotificationModel.fromWebSocket(Map<String, dynamic> data) {
    return NotificationModel(
      type: data['type'] ?? 'unknown',
      message: data['message'] ?? '',
      timestamp: DateTime.now(),
      isRead: false,
      payload: data['payload'],
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      type: json['type'] ?? 'unknown',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(
        json['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: json['isRead'] ?? false,
      payload: json['payload'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'payload': payload,
    };
  }

  NotificationModel copyWith({
    String? type,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? payload,
  }) {
    return NotificationModel(
      type: type ?? this.type,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      payload: payload ?? this.payload,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(type: $type, message: $message, timestamp: $timestamp, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.type == type &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.isRead == isRead &&
        other.payload == payload;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        message.hashCode ^
        timestamp.hashCode ^
        isRead.hashCode ^
        payload.hashCode;
  }
}
