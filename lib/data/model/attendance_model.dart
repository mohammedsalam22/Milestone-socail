class AttendanceModel {
  final int studentId;
  final String studentName;
  final DateTime date;
  final bool absent;
  final bool excused;
  final String note;

  // Offline fields
  final int? localId;
  final String? serverId;
  final String? syncStatus;
  final int? retryCount;
  final String? errorMessage;
  final DateTime? localTimestamp;
  final DateTime? createdAt;

  AttendanceModel({
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.absent,
    required this.excused,
    required this.note,
    this.localId,
    this.serverId,
    this.syncStatus,
    this.retryCount,
    this.errorMessage,
    this.localTimestamp,
    this.createdAt,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      studentId: json['student_id'] ?? 0,
      studentName: json['student_name'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      absent: json['absent'] ?? false,
      excused: json['excused'] ?? false,
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'absent': absent,
      'excused': excused,
      'note': note,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'student_id': studentId,
      'absent': absent,
      'excused': excused,
      'note': note,
      'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
    };
  }

  @override
  String toString() {
    return 'AttendanceModel(studentId: $studentId, studentName: $studentName, date: $date, absent: $absent, excused: $excused, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel &&
        other.studentId == studentId &&
        other.studentName == studentName &&
        other.date == date &&
        other.absent == absent &&
        other.excused == excused &&
        other.note == note;
  }

  // Copy with method for updating fields
  AttendanceModel copyWith({
    int? studentId,
    String? studentName,
    DateTime? date,
    bool? absent,
    bool? excused,
    String? note,
    int? localId,
    String? serverId,
    String? syncStatus,
    int? retryCount,
    String? errorMessage,
    DateTime? localTimestamp,
    DateTime? createdAt,
  }) {
    return AttendanceModel(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      date: date ?? this.date,
      absent: absent ?? this.absent,
      excused: excused ?? this.excused,
      note: note ?? this.note,
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      localTimestamp: localTimestamp ?? this.localTimestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'student_name': studentName,
      'date': date.toIso8601String().split('T')[0],
      'absent': absent ? 1 : 0,
      'excused': excused ? 1 : 0,
      'note': note,
      'local_id': localId,
      'server_id': serverId,
      'sync_status': syncStatus ?? 'pending',
      'retry_count': retryCount ?? 0,
      'error_message': errorMessage,
      'local_timestamp': localTimestamp?.toIso8601String(),
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create from database map
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      studentId: map['student_id'] ?? 0,
      studentName: map['student_name'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      absent: (map['absent'] ?? 0) == 1,
      excused: (map['excused'] ?? 0) == 1,
      note: map['note'] ?? '',
      localId: map['id'], // Use the primary key as localId
      serverId: map['server_id'],
      syncStatus: map['sync_status'],
      retryCount: map['retry_count'],
      errorMessage: map['error_message'],
      localTimestamp: map['local_timestamp'] != null
          ? DateTime.parse(map['local_timestamp'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  @override
  int get hashCode {
    return studentId.hashCode ^
        studentName.hashCode ^
        date.hashCode ^
        absent.hashCode ^
        excused.hashCode ^
        note.hashCode;
  }
}
