class SalaryPayment {
  final int? id;
  final int staffId;
  final int month;
  final int year;
  final double basicSalary;
  final double allowances;
  final double deductions;
  final double bonus;
  final double totalSalary;
  final DateTime? paymentDate;
  final String paymentStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalaryPayment({
    this.id,
    required this.staffId,
    required this.month,
    required this.year,
    required this.basicSalary,
    this.allowances = 0.0,
    this.deductions = 0.0,
    this.bonus = 0.0,
    required this.totalSalary,
    this.paymentDate,
    this.paymentStatus = 'pending',
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staff_id': staffId,
      'month': month,
      'year': year,
      'basic_salary': basicSalary,
      'allowances': allowances,
      'deductions': deductions,
      'bonus': bonus,
      'total_salary': totalSalary,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_status': paymentStatus,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SalaryPayment.fromMap(Map<String, dynamic> map) {
    return SalaryPayment(
      id: map['id']?.toInt(),
      staffId: map['staff_id']?.toInt() ?? 0,
      month: map['month']?.toInt() ?? 1,
      year: map['year']?.toInt() ?? DateTime.now().year,
      basicSalary: map['basic_salary']?.toDouble() ?? 0.0,
      allowances: map['allowances']?.toDouble() ?? 0.0,
      deductions: map['deductions']?.toDouble() ?? 0.0,
      bonus: map['bonus']?.toDouble() ?? 0.0,
      totalSalary: map['total_salary']?.toDouble() ?? 0.0,
      paymentDate: map['payment_date'] != null ? DateTime.parse(map['payment_date']) : null,
      paymentStatus: map['payment_status'] ?? 'pending',
      notes: map['notes'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  String get monthName {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

  bool get isPaid => paymentStatus == 'paid';

  SalaryPayment copyWith({
    int? id,
    int? staffId,
    int? month,
    int? year,
    double? basicSalary,
    double? allowances,
    double? deductions,
    double? bonus,
    double? totalSalary,
    DateTime? paymentDate,
    String? paymentStatus,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalaryPayment(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      month: month ?? this.month,
      year: year ?? this.year,
      basicSalary: basicSalary ?? this.basicSalary,
      allowances: allowances ?? this.allowances,
      deductions: deductions ?? this.deductions,
      bonus: bonus ?? this.bonus,
      totalSalary: totalSalary ?? this.totalSalary,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
