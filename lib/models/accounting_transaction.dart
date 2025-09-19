class AccountingTransaction {
  final int? id;
  final String transactionType; // 'income' or 'expense'
  final String category;
  final double amount;
  final String description;
  final int? referenceId;
  final String? referenceType;
  final DateTime transactionDate;
  final String? paymentMethod;
  final String? receiptNumber;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountingTransaction({
    this.id,
    required this.transactionType,
    required this.category,
    required this.amount,
    required this.description,
    this.referenceId,
    this.referenceType,
    required this.transactionDate,
    this.paymentMethod,
    this.receiptNumber,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transaction_type': transactionType,
      'category': category,
      'amount': amount,
      'description': description,
      'reference_id': referenceId,
      'reference_type': referenceType,
      'transaction_date': transactionDate.toIso8601String(),
      'payment_method': paymentMethod,
      'receipt_number': receiptNumber,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AccountingTransaction.fromMap(Map<String, dynamic> map) {
    return AccountingTransaction(
      id: map['id']?.toInt(),
      transactionType: map['transaction_type'] ?? '',
      category: map['category'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      referenceId: map['reference_id']?.toInt(),
      referenceType: map['reference_type'],
      transactionDate: DateTime.parse(map['transaction_date']),
      paymentMethod: map['payment_method'],
      receiptNumber: map['receipt_number'],
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  bool get isIncome => transactionType == 'income';
  bool get isExpense => transactionType == 'expense';

  AccountingTransaction copyWith({
    int? id,
    String? transactionType,
    String? category,
    double? amount,
    String? description,
    int? referenceId,
    String? referenceType,
    DateTime? transactionDate,
    String? paymentMethod,
    String? receiptNumber,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountingTransaction(
      id: id ?? this.id,
      transactionType: transactionType ?? this.transactionType,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      transactionDate: transactionDate ?? this.transactionDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
