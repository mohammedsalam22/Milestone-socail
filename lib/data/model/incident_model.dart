import 'student_model.dart';

class IncidentModel {
  final int id;
  final List<StudentModel> students;
  final String title;
  final String procedure;
  final String note;
  final DateTime date;

  IncidentModel({
    required this.id,
    required this.students,
    required this.title,
    required this.procedure,
    required this.note,
    required this.date,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json) {
    // The API returns student_names with id and name, not full student objects
    final studentNames = json['student_names'] as List<dynamic>? ?? [];

    // Create minimal StudentModel objects with just id and name
    final students = studentNames.map((studentJson) {
      return StudentModel(
        id: studentJson['id'] ?? 0,
        fullName: studentJson['name'] ?? 'Unknown Student',
        sectionId: 0, // Will be filled later when we map to full student data
        sectionName: '',
        gradeName: '',
        studyStageName: '',
        studyYearName: '',
      );
    }).toList();

    return IncidentModel(
      id: json['id'] ?? 0,
      students: students,
      title: json['title'] ?? '',
      procedure: json['procedure'] ?? '',
      note: json['note'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'students': students.map((student) => student.toJson()).toList(),
      'title': title,
      'procedure': procedure,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'students': students.map((student) => student.id).toList(),
      'title': title,
      'procedure': procedure,
      'note': note,
      'date': date.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'IncidentModel(id: $id, title: $title, students: ${students.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IncidentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
