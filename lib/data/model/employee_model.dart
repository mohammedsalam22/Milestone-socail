class EmployeeModel {
  final int id;
  final String username;
  final String phone;
  final String firstName;
  final String lastName;
  final String role;
  final String fatherName;
  final String motherName;
  final String nationality;
  final String gender;
  final String address;
  final String birthDate;
  final String familyStatus;
  final String nationalNo;
  final String salary;
  final String contractStart;
  final String contractEnd;
  final String dayStart;
  final String dayEnd;

  EmployeeModel({
    required this.id,
    required this.username,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.fatherName,
    required this.motherName,
    required this.nationality,
    required this.gender,
    required this.address,
    required this.birthDate,
    required this.familyStatus,
    required this.nationalNo,
    required this.salary,
    required this.contractStart,
    required this.contractEnd,
    required this.dayStart,
    required this.dayEnd,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return EmployeeModel(
      id: json['id'] ?? 0,
      username: user['username'] ?? '',
      phone: user['phone'] ?? '',
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      role: json['role'] ?? '',
      fatherName: json['father_name'] ?? '',
      motherName: json['mother_name'] ?? '',
      nationality: json['nationality'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      birthDate: json['birth_date'] ?? '',
      familyStatus: json['family_status'] ?? '',
      nationalNo: json['national_no'] ?? '',
      salary: json['salary'] ?? '',
      contractStart: json['contract_start'] ?? '',
      contractEnd: json['contract_end'] ?? '',
      dayStart: json['day_start'] ?? '',
      dayEnd: json['day_end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': {
        'username': username,
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
      },
      'role': role,
      'father_name': fatherName,
      'mother_name': motherName,
      'nationality': nationality,
      'gender': gender,
      'address': address,
      'birth_date': birthDate,
      'family_status': familyStatus,
      'national_no': nationalNo,
      'salary': salary,
      'contract_start': contractStart,
      'contract_end': contractEnd,
      'day_start': dayStart,
      'day_end': dayEnd,
    };
  }

  // Helper method to get full name
  String get fullName => '$firstName $lastName'.trim();

  // Helper method to get display name with role
  String get displayNameWithRole => '$fullName ($role)';

  // Helper method to get essential info for display
  String get essentialInfo => '$fullName - $role';

  @override
  String toString() {
    return 'EmployeeModel(id: $id, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmployeeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
