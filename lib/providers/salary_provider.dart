import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../models/salary_payment.dart';
import '../models/staff.dart';

class SalaryProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<SalaryPayment> _salaryPayments = [];
  bool _isLoading = false;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  List<SalaryPayment> get salaryPayments => _salaryPayments;
  bool get isLoading => _isLoading;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  void setSelectedPeriod(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    notifyListeners();
    loadSalaryPayments();
  }

  Future<void> loadSalaryPayments({int? month, int? year}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final effectiveMonth = month ?? _selectedMonth;
      final effectiveYear = year ?? _selectedYear;

      final salaryMaps = await _db.query(
        'salary_payments',
        where: 'month = ? AND year = ?',
        whereArgs: [effectiveMonth, effectiveYear],
        orderBy: 'created_at DESC',
      );

      _salaryPayments = salaryMaps.map((map) => SalaryPayment.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading salary payments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<SalaryPayment?> getSalaryPayment(int id) async {
    try {
      final salaryMap = await _db.queryFirst(
        'salary_payments',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (salaryMap != null) {
        return SalaryPayment.fromMap(salaryMap);
      }
    } catch (e) {
      debugPrint('Error getting salary payment: $e');
    }
    return null;
  }

  Future<SalaryPayment?> getSalaryPaymentByStaff(int staffId, int month, int year) async {
    try {
      final salaryMap = await _db.queryFirst(
        'salary_payments',
        where: 'staff_id = ? AND month = ? AND year = ?',
        whereArgs: [staffId, month, year],
      );

      if (salaryMap != null) {
        return SalaryPayment.fromMap(salaryMap);
      }
    } catch (e) {
      debugPrint('Error getting salary payment by staff: $e');
    }
    return null;
  }

  Future<bool> generateSalariesForMonth(List<Staff> staffList, int month, int year) async {
    try {
      for (final staff in staffList) {
        // Check if salary already exists for this month/year
        final existing = await getSalaryPaymentByStaff(staff.id!, month, year);
        
        if (existing == null) {
          final salaryPayment = SalaryPayment(
            staffId: staff.id!,
            month: month,
            year: year,
            basicSalary: staff.basicSalary,
            allowances: staff.allowances,
            totalSalary: staff.basicSalary + staff.allowances,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await addSalaryPayment(salaryPayment);
        }
      }
      
      await loadSalaryPayments(month: month, year: year);
      return true;
    } catch (e) {
      debugPrint('Error generating salaries: $e');
      return false;
    }
  }

  Future<bool> addSalaryPayment(SalaryPayment salaryPayment) async {
    try {
      final salaryMap = salaryPayment.toMap();
      salaryMap.remove('id'); // Remove id for insertion
      
      final id = await _db.insert('salary_payments', salaryMap);
      
      if (id > 0) {
        return true;
      }
    } catch (e) {
      debugPrint('Error adding salary payment: $e');
    }
    return false;
  }

  Future<bool> updateSalaryPayment(SalaryPayment salaryPayment) async {
    try {
      final count = await _db.update(
        'salary_payments',
        salaryPayment.toMap(),
        where: 'id = ?',
        whereArgs: [salaryPayment.id],
      );
      
      if (count > 0) {
        await loadSalaryPayments(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error updating salary payment: $e');
    }
    return false;
  }

  Future<bool> paySalary(int salaryPaymentId, DateTime paymentDate, {String? notes}) async {
    try {
      final count = await _db.update(
        'salary_payments',
        {
          'payment_status': 'paid',
          'payment_date': paymentDate.toIso8601String(),
          'notes': notes,
        },
        where: 'id = ?',
        whereArgs: [salaryPaymentId],
      );
      
      if (count > 0) {
        await loadSalaryPayments(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error paying salary: $e');
    }
    return false;
  }

  Future<bool> deleteSalaryPayment(int id) async {
    try {
      final count = await _db.delete(
        'salary_payments',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadSalaryPayments(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting salary payment: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>> getSalaryStats(int month, int year) async {
    try {
      final db = await _db.database;
      
      // Get total salaries for the month
      final totalResult = await db.rawQuery(
        'SELECT SUM(total_salary) as total FROM salary_payments WHERE month = ? AND year = ?',
        [month, year],
      );
      
      final total = (totalResult.first['total'] as double?) ?? 0.0;
      
      // Get paid salaries for the month
      final paidResult = await db.rawQuery(
        'SELECT SUM(total_salary) as paid FROM salary_payments WHERE month = ? AND year = ? AND payment_status = ?',
        [month, year, 'paid'],
      );
      
      final paid = (paidResult.first['paid'] as double?) ?? 0.0;
      
      // Get count of paid/unpaid salaries
      final paidCount = await _db.count(
        'salary_payments',
        where: 'month = ? AND year = ? AND payment_status = ?',
        whereArgs: [month, year, 'paid'],
      );
      
      final totalCount = await _db.count(
        'salary_payments',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
      );

      return {
        'totalAmount': total,
        'paidAmount': paid,
        'pendingAmount': total - paid,
        'paidCount': paidCount,
        'totalCount': totalCount,
        'pendingCount': totalCount - paidCount,
      };
    } catch (e) {
      debugPrint('Error getting salary stats: $e');
      return {
        'totalAmount': 0.0,
        'paidAmount': 0.0,
        'pendingAmount': 0.0,
        'paidCount': 0,
        'totalCount': 0,
        'pendingCount': 0,
      };
    }
  }

  List<SalaryPayment> get pendingSalaries {
    return _salaryPayments.where((salary) => salary.paymentStatus == 'pending').toList();
  }

  List<SalaryPayment> get paidSalaries {
    return _salaryPayments.where((salary) => salary.paymentStatus == 'paid').toList();
  }
}
