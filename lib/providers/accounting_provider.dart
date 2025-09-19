import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../models/accounting_transaction.dart';

class AccountingProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<AccountingTransaction> _transactions = [];
  bool _isLoading = false;
  DateTime _selectedMonth = DateTime.now();

  List<AccountingTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  DateTime get selectedMonth => _selectedMonth;

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    notifyListeners();
    loadTransactions();
  }

  Future<void> loadTransactions({DateTime? month}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final effectiveMonth = month ?? _selectedMonth;
      final startDate = DateTime(effectiveMonth.year, effectiveMonth.month, 1);
      final endDate = DateTime(effectiveMonth.year, effectiveMonth.month + 1, 0);

      final transactionMaps = await _db.query(
        'accounting_transactions',
        where: 'transaction_date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'transaction_date DESC',
      );

      _transactions = transactionMaps.map((map) => AccountingTransaction.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<AccountingTransaction?> getTransaction(int id) async {
    try {
      final transactionMap = await _db.queryFirst(
        'accounting_transactions',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (transactionMap != null) {
        return AccountingTransaction.fromMap(transactionMap);
      }
    } catch (e) {
      debugPrint('Error getting transaction: $e');
    }
    return null;
  }

  Future<bool> addTransaction(AccountingTransaction transaction) async {
    try {
      final transactionMap = transaction.toMap();
      transactionMap.remove('id'); // Remove id for insertion
      
      final id = await _db.insert('accounting_transactions', transactionMap);
      
      if (id > 0) {
        await loadTransactions(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
    return false;
  }

  Future<bool> updateTransaction(AccountingTransaction transaction) async {
    try {
      final count = await _db.update(
        'accounting_transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      
      if (count > 0) {
        await loadTransactions(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
    return false;
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      final count = await _db.delete(
        'accounting_transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadTransactions(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
    return false;
  }

  // Add income transaction
  Future<bool> addIncome({
    required String category,
    required double amount,
    required String description,
    required DateTime date,
    String? paymentMethod,
    String? receiptNumber,
    int? referenceId,
    String? referenceType,
  }) async {
    final transaction = AccountingTransaction(
      transactionType: 'income',
      category: category,
      amount: amount,
      description: description,
      transactionDate: date,
      paymentMethod: paymentMethod,
      receiptNumber: receiptNumber,
      referenceId: referenceId,
      referenceType: referenceType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await addTransaction(transaction);
  }

  // Add expense transaction
  Future<bool> addExpense({
    required String category,
    required double amount,
    required String description,
    required DateTime date,
    String? paymentMethod,
    String? receiptNumber,
    int? referenceId,
    String? referenceType,
  }) async {
    final transaction = AccountingTransaction(
      transactionType: 'expense',
      category: category,
      amount: amount,
      description: description,
      transactionDate: date,
      paymentMethod: paymentMethod,
      receiptNumber: receiptNumber,
      referenceId: referenceId,
      referenceType: referenceType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await addTransaction(transaction);
  }

  Future<Map<String, dynamic>> getMonthlyFinancialSummary({DateTime? month}) async {
    try {
      final effectiveMonth = month ?? _selectedMonth;
      final startDate = DateTime(effectiveMonth.year, effectiveMonth.month, 1);
      final endDate = DateTime(effectiveMonth.year, effectiveMonth.month + 1, 0);

      final db = await _db.database;
      
      // Get total income
      final incomeResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM accounting_transactions WHERE transaction_type = ? AND transaction_date BETWEEN ? AND ?',
        ['income', startDate.toIso8601String(), endDate.toIso8601String()],
      );
      
      final totalIncome = (incomeResult.first['total'] as double?) ?? 0.0;
      
      // Get total expenses
      final expenseResult = await db.rawQuery(
        'SELECT SUM(amount) as total FROM accounting_transactions WHERE transaction_type = ? AND transaction_date BETWEEN ? AND ?',
        ['expense', startDate.toIso8601String(), endDate.toIso8601String()],
      );
      
      final totalExpenses = (expenseResult.first['total'] as double?) ?? 0.0;

      return {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'netProfit': totalIncome - totalExpenses,
        'month': effectiveMonth,
      };
    } catch (e) {
      debugPrint('Error getting monthly financial summary: $e');
      return {
        'totalIncome': 0.0,
        'totalExpenses': 0.0,
        'netProfit': 0.0,
        'month': _selectedMonth,
      };
    }
  }

  Future<Map<String, double>> getIncomeByCategory({DateTime? month}) async {
    try {
      final effectiveMonth = month ?? _selectedMonth;
      final startDate = DateTime(effectiveMonth.year, effectiveMonth.month, 1);
      final endDate = DateTime(effectiveMonth.year, effectiveMonth.month + 1, 0);

      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM accounting_transactions WHERE transaction_type = ? AND transaction_date BETWEEN ? AND ? GROUP BY category',
        ['income', startDate.toIso8601String(), endDate.toIso8601String()],
      );

      final Map<String, double> incomeByCategory = {};
      for (final row in result) {
        incomeByCategory[row['category'] as String] = (row['total'] as double?) ?? 0.0;
      }

      return incomeByCategory;
    } catch (e) {
      debugPrint('Error getting income by category: $e');
      return {};
    }
  }

  Future<Map<String, double>> getExpensesByCategory({DateTime? month}) async {
    try {
      final effectiveMonth = month ?? _selectedMonth;
      final startDate = DateTime(effectiveMonth.year, effectiveMonth.month, 1);
      final endDate = DateTime(effectiveMonth.year, effectiveMonth.month + 1, 0);

      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM accounting_transactions WHERE transaction_type = ? AND transaction_date BETWEEN ? AND ? GROUP BY category',
        ['expense', startDate.toIso8601String(), endDate.toIso8601String()],
      );

      final Map<String, double> expensesByCategory = {};
      for (final row in result) {
        expensesByCategory[row['category'] as String] = (row['total'] as double?) ?? 0.0;
      }

      return expensesByCategory;
    } catch (e) {
      debugPrint('Error getting expenses by category: $e');
      return {};
    }
  }

  List<AccountingTransaction> get incomeTransactions {
    return _transactions.where((t) => t.transactionType == 'income').toList();
  }

  List<AccountingTransaction> get expenseTransactions {
    return _transactions.where((t) => t.transactionType == 'expense').toList();
  }

  double get totalIncome {
    return incomeTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpenses {
    return expenseTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get netProfit {
    return totalIncome - totalExpenses;
  }

  // Common categories for income and expenses
  static const List<String> incomeCategories = [
    'Student Fees',
    'Admission Fees',
    'Donations',
    'Government Grants',
    'Events & Functions',
    'Book Sales',
    'Other Income',
  ];

  static const List<String> expenseCategories = [
    'Staff Salaries',
    'Utilities',
    'Maintenance',
    'Office Supplies',
    'Teaching Materials',
    'Transportation',
    'Food & Catering',
    'Equipment Purchase',
    'Insurance',
    'Other Expenses',
  ];
}
