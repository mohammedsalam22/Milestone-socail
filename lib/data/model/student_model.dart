class StudentModel {
  final int id;
  final String fullName;
  final int sectionId;
  final String sectionName;
  final String gradeName;
  final String studyStageName;
  final String studyYearName;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.sectionId,
    required this.sectionName,
    required this.gradeName,
    required this.studyStageName,
    required this.studyYearName,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final card = json['card'] ?? {};
    final section = json['section'] ?? {};
    final grade = section['grade'] ?? {};
    final studyStage = grade['study_stage'] ?? {};
    final studyYear = grade['study_year'] ?? {};

    return StudentModel(
      id: json['id'] ?? 0,
      fullName: '${card['first_name'] ?? ''} ${card['last_name'] ?? ''}'.trim(),
      sectionId: section['id'] ?? 0,
      sectionName: section['name'] ?? '',
      gradeName: grade['name'] ?? '',
      studyStageName: studyStage['name'] ?? '',
      studyYearName: studyYear['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'section_id': sectionId,
      'section_name': sectionName,
      'grade_name': gradeName,
      'study_stage_name': studyStageName,
      'study_year_name': studyYearName,
    };
  }

  @override
  String toString() {
    return 'StudentModel(id: $id, fullName: $fullName, sectionId: $sectionId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudentModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
