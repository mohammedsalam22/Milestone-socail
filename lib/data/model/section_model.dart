class SectionModel {
  final int id;
  final String name;
  final GradeModel grade;

  SectionModel({required this.id, required this.name, required this.grade});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      grade: GradeModel.fromJson(json['grade'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'grade': grade.toJson()};
  }

  String get displayName => '$name - ${grade.name}';
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
