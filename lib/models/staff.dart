class Staff {
  final int? id;
  final String staffId;
  final String fullName;
  final String fatherName;
  final DateTime dateOfBirth;
  final String gender;
  final String address;
  final String phone;
  final String? email;
  final String position;
  final String? department;
  final String? qualification;
  final int experienceYears;
  final DateTime joiningDate;
  final double basicSalary;
  final double allowances;
  final bool isActive;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Staff({
    this.id,
    required this.staffId,
    required this.fullName,
    required this.fatherName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.phone,
    this.email,
    required this.position,
    this.department,
    this.qualification,
    this.experienceYears = 0,
    required this.joiningDate,
    required this.basicSalary,
    this.allowances = 0.0,
    this.isActive = true,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staff_id': staffId,
      'full_name': fullName,
      'father_name': fatherName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'address': address,
      'phone': phone,
      'email': email,
      'position': position,
      'department': department,
      'qualification': qualification,
      'experience_years': experienceYears,
      'joining_date': joiningDate.toIso8601String(),
      'basic_salary': basicSalary,
      'allowances': allowances,
      'is_active': isActive ? 1 : 0,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Staff.fromMap(Map<String, dynamic> map) {
    return Staff(
      id: map['id']?.toInt(),
      staffId: map['staff_id'] ?? '',
      fullName: map['full_name'] ?? '',
      fatherName: map['father_name'] ?? '',
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      gender: map['gender'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'],
      position: map['position'] ?? '',
      department: map['department'],
      qualification: map['qualification'],
      experienceYears: map['experience_years']?.toInt() ?? 0,
      joiningDate: DateTime.parse(map['joining_date']),
      basicSalary: map['basic_salary']?.toDouble() ?? 0.0,
      allowances: map['allowances']?.toDouble() ?? 0.0,
      isActive: map['is_active'] == 1,
      profileImage: map['profile_image'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  double get totalSalary => basicSalary + allowances;

  Staff copyWith({
    int? id,
    String? staffId,
    String? fullName,
    String? fatherName,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? phone,
    String? email,
    String? position,
    String? department,
    String? qualification,
    int? experienceYears,
    DateTime? joiningDate,
    double? basicSalary,
    double? allowances,
    bool? isActive,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Staff(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      position: position ?? this.position,
      department: department ?? this.department,
      qualification: qualification ?? this.qualification,
      experienceYears: experienceYears ?? this.experienceYears,
      joiningDate: joiningDate ?? this.joiningDate,
      basicSalary: basicSalary ?? this.basicSalary,
      allowances: allowances ?? this.allowances,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
