class AttendanceModel {
  final int studentId;
  final String studentName;
  final DateTime date;
  final bool absent;
  final bool excused;
  final String note;

  AttendanceModel({
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.absent,
    required this.excused,
    required this.note,
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
