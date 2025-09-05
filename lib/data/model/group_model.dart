class GroupMember {
  final int id;
  final String name;
  final String? role; // For employees only

  GroupMember({required this.id, required this.name, this.role});

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, if (role != null) 'role': role};
  }
}

class GroupOwner {
  final int id;
  final String name;
  final String role;

  GroupOwner({required this.id, required this.name, required this.role});

  factory GroupOwner.fromJson(Map<String, dynamic> json) {
    return GroupOwner(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'role': role};
  }
}

class GroupModel {
  final int id;
  final String name;
  final GroupOwner owner;
  final List<GroupMember> students;
  final List<GroupMember> employees;

  GroupModel({
    required this.id,
    required this.name,
    required this.owner,
    required this.students,
    required this.employees,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      owner: GroupOwner.fromJson(json['owner'] ?? {}),
      students:
          (json['students'] as List<dynamic>?)
              ?.map((student) => GroupMember.fromJson(student))
              .toList() ??
          [],
      employees:
          (json['employees'] as List<dynamic>?)
              ?.map((employee) => GroupMember.fromJson(employee))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner': owner.toJson(),
      'students': students.map((student) => student.toJson()).toList(),
      'employees': employees.map((employee) => employee.toJson()).toList(),
    };
  }

  // Helper method to get all members count
  int get totalMembers => students.length + employees.length;

  // Helper method to get all members as a single list
  List<GroupMember> get allMembers => [...students, ...employees];

  // Helper method to get display name with member count
  String get displayNameWithCount => '$name (${totalMembers} members)';

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, students: ${students.length}, employees: ${employees.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Request model for creating a group
class CreateGroupRequest {
  final String name;
  final List<int> studentIds;
  final List<int> employeeIds;

  CreateGroupRequest({
    required this.name,
    required this.studentIds,
    required this.employeeIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'student_ids': studentIds,
      'employee_ids': employeeIds,
    };
  }
}
