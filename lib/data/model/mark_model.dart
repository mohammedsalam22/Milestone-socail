import 'package:flutter/material.dart';
import 'exam_type.dart';

class MarkModel {
  final int id;
  final String studentName;
  final String subjectName;
  final int mark;
  final ExamType examType;
  final int topMark;
  final int passMark;
  final DateTime date;

  MarkModel({
    required this.id,
    required this.studentName,
    required this.subjectName,
    required this.mark,
    required this.examType,
    required this.topMark,
    required this.passMark,
    required this.date,
  });

  factory MarkModel.fromJson(Map<String, dynamic> json) {
    return MarkModel(
      id: json['id'] ?? 0,
      studentName: json['student_name'] ?? '',
      subjectName: json['subject_name'] ?? '',
      mark: json['mark'] ?? 0,
      examType: ExamType.fromString(json['mark_type'] ?? ''),
      topMark: json['top_mark'] ?? 0,
      passMark: json['pass_mark'] ?? 0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'subject_name': subjectName,
      'mark': mark,
      'mark_type': examType.displayName,
      'top_mark': topMark,
      'pass_mark': passMark,
      'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
    };
  }

  // Helper getters
  double get percentage => topMark > 0 ? (mark / topMark) * 100 : 0.0;

  bool get isPassed => mark >= passMark;

  String get grade {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C+';
    if (percentage >= 40) return 'C';
    return 'F';
  }

  Color get gradeColor {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.lightGreen;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 60) return Colors.orange;
    if (percentage >= 50) return Colors.deepOrange;
    return Colors.red;
  }
}
