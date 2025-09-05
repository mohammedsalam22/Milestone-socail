import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserModel {
  final int pk;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final Map<String, dynamic>? entity;

  UserModel({
    required this.pk,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.entity,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final entity = json['entity'] as Map<String, dynamic>?;

    // Determine role based on entity structure
    String determinedRole = json['role'] ?? '';

    if (determinedRole.isEmpty && entity != null) {
      // If role is null/empty but entity exists, this is likely a parent/student account
      if (entity.containsKey('parent1') || entity.containsKey('parent2')) {
        determinedRole = 'parent';
      } else if (entity.containsKey('section')) {
        determinedRole = 'student';
      }
    }

    return UserModel(
      pk: json['pk'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: determinedRole,
      entity: entity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pk': pk,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'entity': entity,
    };
  }

  // Helper method to get student name from entity
  String get studentName {
    if (entity != null && entity!['card'] != null) {
      final card = entity!['card'] as Map<String, dynamic>;
      final firstName = card['first_name'] ?? '';
      final lastName = card['last_name'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return '$firstName $lastName'.trim();
  }

  // Helper method to get student full name (first + last)
  String get studentFullName {
    if (entity != null && entity!['card'] != null) {
      final card = entity!['card'] as Map<String, dynamic>;
      final firstName = card['first_name'] ?? '';
      final lastName = card['last_name'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return 'Unknown Student';
  }

  // Helper method to get student ID from entity
  int get studentId {
    if (entity != null && entity!['card'] != null) {
      final card = entity!['card'] as Map<String, dynamic>;
      return card['id'] ?? 0;
    }
    return 0;
  }

  // Helper method to get student card info from entity
  Map<String, dynamic>? get studentCard {
    if (entity != null && entity!['card'] != null) {
      return entity!['card'] as Map<String, dynamic>;
    }
    return null;
  }

  // Helper method to get section info from entity
  Map<String, dynamic>? get sectionInfo {
    if (entity != null && entity!['section'] != null) {
      return entity!['section'] as Map<String, dynamic>;
    }
    return null;
  }

  // Helper method to get section ID
  int get sectionId {
    final section = sectionInfo;
    return section?['id'] ?? 0;
  }

  // Helper method to get grade info from entity
  Map<String, dynamic>? get gradeInfo {
    final section = sectionInfo;
    return section?['grade'] as Map<String, dynamic>?;
  }

  // Helper method to get study stage info
  Map<String, dynamic>? get studyStageInfo {
    final grade = gradeInfo;
    return grade?['study_stage'] as Map<String, dynamic>?;
  }

  // Helper method to get study year info
  Map<String, dynamic>? get studyYearInfo {
    final grade = gradeInfo;
    return grade?['study_year'] as Map<String, dynamic>?;
  }

  // Helper method to get parent info from entity
  Map<String, dynamic>? get parent1Info {
    if (entity != null && entity!['parent1'] != null) {
      return entity!['parent1'] as Map<String, dynamic>;
    }
    return null;
  }

  Map<String, dynamic>? get parent2Info {
    if (entity != null && entity!['parent2'] != null) {
      return entity!['parent2'] as Map<String, dynamic>;
    }
    return null;
  }

  // Helper method to get formatted section display name
  String get sectionDisplayName {
    final section = sectionInfo;
    final grade = gradeInfo;
    if (section != null && grade != null) {
      final sectionName = section['name'] ?? '';
      final gradeName = grade['name'] ?? '';
      return '$sectionName - $gradeName';
    }
    return 'Unknown Section';
  }

  // Helper method to get full academic info
  String get academicInfo {
    final section = sectionInfo;
    final grade = gradeInfo;
    final studyStage = studyStageInfo;
    final studyYear = studyYearInfo;

    if (section != null &&
        grade != null &&
        studyStage != null &&
        studyYear != null) {
      final sectionName = section['name'] ?? '';
      final gradeName = grade['name'] ?? '';
      final stageName = studyStage['name'] ?? '';
      final yearName = studyYear['name'] ?? '';
      return '$sectionName - $gradeName ($stageName - $yearName)';
    }
    return 'Unknown Academic Info';
  }

  // Save student data to SharedPreferences
  Future<void> saveStudentData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save student ID and section ID
    await prefs.setInt('student_id', studentId);
    await prefs.setInt('section_id', sectionId);

    // Save full student data as JSON
    await prefs.setString('student_data', jsonEncode(toJson()));

    // Save individual fields for easy access
    await prefs.setString('student_name', studentFullName);
    await prefs.setString('section_name', sectionDisplayName);
    await prefs.setString('academic_info', academicInfo);
  }

  // Load student data from SharedPreferences
  static Future<UserModel?> loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    final studentDataJson = prefs.getString('student_data');

    if (studentDataJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(studentDataJson);
        return UserModel.fromJson(data);
      } catch (e) {
        print('Error loading student data: $e');
        return null;
      }
    }
    return null;
  }

  // Clear student data from SharedPreferences
  static Future<void> clearStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('student_id');
    await prefs.remove('section_id');
    await prefs.remove('student_data');
    await prefs.remove('student_name');
    await prefs.remove('section_name');
    await prefs.remove('academic_info');
  }

  // Get student ID from SharedPreferences
  static Future<int> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('student_id') ?? 0;
  }

  // Get section ID from SharedPreferences
  static Future<int> getSectionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('section_id') ?? 0;
  }
}
