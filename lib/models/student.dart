class Student {
  final int? id;
  final String studentId;
  final String fullName;
  final String fatherName;
  final String motherName;
  final DateTime dateOfBirth;
  final String gender;
  final String address;
  final String? phone;
  final String? email;
  final String guardianName;
  final String guardianPhone;
  final String guardianRelation;
  final String className;
  final String? section;
  final String? rollNumber;
  final DateTime admissionDate;
  final double admissionFee;
  final double monthlyFee;
  final double discountPercentage;
  final bool isActive;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    this.id,
    required this.studentId,
    required this.fullName,
    required this.fatherName,
    required this.motherName,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    this.phone,
    this.email,
    required this.guardianName,
    required this.guardianPhone,
    required this.guardianRelation,
    required this.className,
    this.section,
    this.rollNumber,
    required this.admissionDate,
    this.admissionFee = 0.0,
    this.monthlyFee = 0.0,
    this.discountPercentage = 0.0,
    this.isActive = true,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'full_name': fullName,
      'father_name': fatherName,
      'mother_name': motherName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'address': address,
      'phone': phone,
      'email': email,
      'guardian_name': guardianName,
      'guardian_phone': guardianPhone,
      'guardian_relation': guardianRelation,
      'class_name': className,
      'section': section,
      'roll_number': rollNumber,
      'admission_date': admissionDate.toIso8601String(),
      'admission_fee': admissionFee,
      'monthly_fee': monthlyFee,
      'discount_percentage': discountPercentage,
      'is_active': isActive ? 1 : 0,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id']?.toInt(),
      studentId: map['student_id'] ?? '',
      fullName: map['full_name'] ?? '',
      fatherName: map['father_name'] ?? '',
      motherName: map['mother_name'] ?? '',
      dateOfBirth: DateTime.parse(map['date_of_birth']),
      gender: map['gender'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'],
      email: map['email'],
      guardianName: map['guardian_name'] ?? '',
      guardianPhone: map['guardian_phone'] ?? '',
      guardianRelation: map['guardian_relation'] ?? '',
      className: map['class_name'] ?? '',
      section: map['section'],
      rollNumber: map['roll_number'],
      admissionDate: DateTime.parse(map['admission_date']),
      admissionFee: map['admission_fee']?.toDouble() ?? 0.0,
      monthlyFee: map['monthly_fee']?.toDouble() ?? 0.0,
      discountPercentage: map['discount_percentage']?.toDouble() ?? 0.0,
      isActive: map['is_active'] == 1,
      profileImage: map['profile_image'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Student copyWith({
    int? id,
    String? studentId,
    String? fullName,
    String? fatherName,
    String? motherName,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? phone,
    String? email,
    String? guardianName,
    String? guardianPhone,
    String? guardianRelation,
    String? className,
    String? section,
    String? rollNumber,
    DateTime? admissionDate,
    double? admissionFee,
    double? monthlyFee,
    double? discountPercentage,
    bool? isActive,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      guardianRelation: guardianRelation ?? this.guardianRelation,
      className: className ?? this.className,
      section: section ?? this.section,
      rollNumber: rollNumber ?? this.rollNumber,
      admissionDate: admissionDate ?? this.admissionDate,
      admissionFee: admissionFee ?? this.admissionFee,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isActive: isActive ?? this.isActive,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
