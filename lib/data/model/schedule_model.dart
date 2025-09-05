import 'package:flutter/material.dart';

class ScheduleModel {
  final int id;
  final String day;
  final String startTime;
  final String endTime;
  final TeacherModel teacher;
  final SectionModel section;

  ScheduleModel({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.teacher,
    required this.section,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] ?? 0,
      day: json['day'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      teacher: TeacherModel.fromJson(json['teacher'] ?? {}),
      section: SectionModel.fromJson(json['section'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'teacher': teacher.toJson(),
      'section': section.toJson(),
    };
  }

  // Helper getters
  String get formattedStartTime {
    final time = DateTime.parse('2023-01-01 $startTime');
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get formattedEndTime {
    final time = DateTime.parse('2023-01-01 $endTime');
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get timeRange => '$formattedStartTime - $formattedEndTime';

  String get dayDisplayName {
    switch (day.toLowerCase()) {
      case 'sun':
        return 'Sunday';
      case 'mon':
        return 'Monday';
      case 'tue':
        return 'Tuesday';
      case 'wed':
        return 'Wednesday';
      case 'thu':
        return 'Thursday';
      case 'fri':
        return 'Friday';
      case 'sat':
        return 'Saturday';
      default:
        return day;
    }
  }

  Color get dayColor {
    switch (day.toLowerCase()) {
      case 'sun':
        return Colors.red;
      case 'mon':
        return Colors.blue;
      case 'tue':
        return Colors.green;
      case 'wed':
        return Colors.orange;
      case 'thu':
        return Colors.purple;
      case 'fri':
        return Colors.teal;
      case 'sat':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class TeacherModel {
  final int id;
  final String username;
  final List<SubjectModel> subjects;

  TeacherModel({
    required this.id,
    required this.username,
    required this.subjects,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map((subject) => SubjectModel.fromJson(subject))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'subjects': subjects.map((subject) => subject.toJson()).toList(),
    };
  }

  // Get the first subject and its teacher
  String get primarySubjectName =>
      subjects.isNotEmpty ? subjects.first.name : 'N/A';
  String get primaryTeacherName =>
      subjects.isNotEmpty && subjects.first.teacher.isNotEmpty
      ? subjects.first.teacher.first.name
      : 'N/A';
}

class SubjectModel {
  final int id;
  final String name;
  final GradeModel grade;
  final List<TeacherInfoModel> teacher;

  SubjectModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.teacher,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      grade: GradeModel.fromJson(json['grade'] ?? {}),
      teacher:
          (json['teacher'] as List<dynamic>?)
              ?.map((teacher) => TeacherInfoModel.fromJson(teacher))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade.toJson(),
      'teacher': teacher.map((teacher) => teacher.toJson()).toList(),
    };
  }
}

class TeacherInfoModel {
  final int id;
  final String name;

  TeacherInfoModel({required this.id, required this.name});

  factory TeacherInfoModel.fromJson(Map<String, dynamic> json) {
    return TeacherInfoModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class SectionModel {
  final int id;
  final String name;
  final int limit;
  final GradeModel grade;

  SectionModel({
    required this.id,
    required this.name,
    required this.limit,
    required this.grade,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      limit: json['limit'] ?? 0,
      grade: GradeModel.fromJson(json['grade'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'limit': limit, 'grade': grade.toJson()};
  }
}

class GradeModel {
  final int id;
  final String name;
  final StudyStageModel studyStage;
  final StudyYearModel studyYear;

  GradeModel({
    required this.id,
    required this.name,
    required this.studyStage,
    required this.studyYear,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      studyStage: StudyStageModel.fromJson(json['study_stage'] ?? {}),
      studyYear: StudyYearModel.fromJson(json['study_year'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'study_stage': studyStage.toJson(),
      'study_year': studyYear.toJson(),
    };
  }
}

class StudyStageModel {
  final int id;
  final String name;

  StudyStageModel({required this.id, required this.name});

  factory StudyStageModel.fromJson(Map<String, dynamic> json) {
    return StudyStageModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class StudyYearModel {
  final int id;
  final String name;

  StudyYearModel({required this.id, required this.name});

  factory StudyYearModel.fromJson(Map<String, dynamic> json) {
    return StudyYearModel(id: json['id'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
