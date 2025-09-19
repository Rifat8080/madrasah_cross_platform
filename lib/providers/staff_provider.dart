import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../models/staff.dart';

class StaffProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Staff> _staff = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Staff> get staff => _staff;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Staff> get filteredStaff {
    if (_searchQuery.isEmpty) return _staff;
    
    return _staff.where((staff) =>
      staff.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      staff.staffId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      staff.position.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadStaff() async {
    _isLoading = true;
    notifyListeners();

    try {
      final staffMaps = await _db.query(
        'staff',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'full_name ASC',
      );

      _staff = staffMaps.map((map) => Staff.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading staff: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Staff?> getStaff(int id) async {
    try {
      final staffMap = await _db.queryFirst(
        'staff',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (staffMap != null) {
        return Staff.fromMap(staffMap);
      }
    } catch (e) {
      debugPrint('Error getting staff: $e');
    }
    return null;
  }

  Future<bool> addStaff(Staff staff) async {
    try {
      final staffMap = staff.toMap();
      staffMap.remove('id'); // Remove id for insertion
      
      final id = await _db.insert('staff', staffMap);
      
      if (id > 0) {
        await loadStaff(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error adding staff: $e');
    }
    return false;
  }

  Future<bool> updateStaff(Staff staff) async {
    try {
      final count = await _db.update(
        'staff',
        staff.toMap(),
        where: 'id = ?',
        whereArgs: [staff.id],
      );
      
      if (count > 0) {
        await loadStaff(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error updating staff: $e');
    }
    return false;
  }

  Future<bool> deleteStaff(int id) async {
    try {
      // Soft delete by setting is_active to 0
      final count = await _db.update(
        'staff',
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadStaff(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting staff: $e');
    }
    return false;
  }

  Future<bool> isStaffIdUnique(String staffId, {int? excludeId}) async {
    try {
      String whereClause = 'staff_id = ?';
      List<dynamic> whereArgs = [staffId];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final count = await _db.count(
        'staff',
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      return count == 0;
    } catch (e) {
      debugPrint('Error checking staff ID uniqueness: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getStaffStats() async {
    try {
      final totalStaff = await _db.count(
        'staff',
        where: 'is_active = ?',
        whereArgs: [1],
      );
      
      final maleStaff = await _db.count(
        'staff',
        where: 'is_active = ? AND gender = ?',
        whereArgs: [1, 'Male'],
      );
      
      final femaleStaff = await _db.count(
        'staff',
        where: 'is_active = ? AND gender = ?',
        whereArgs: [1, 'Female'],
      );

      // Calculate total salary expenses
      double totalSalaryExpense = 0.0;
      for (final staff in _staff) {
        totalSalaryExpense += staff.totalSalary;
      }

      return {
        'total': totalStaff,
        'male': maleStaff,
        'female': femaleStaff,
        'totalSalaryExpense': totalSalaryExpense,
      };
    } catch (e) {
      debugPrint('Error getting staff stats: $e');
      return {'total': 0, 'male': 0, 'female': 0, 'totalSalaryExpense': 0.0};
    }
  }

  Future<List<String>> getUniquePositions() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT DISTINCT position FROM staff WHERE is_active = 1 ORDER BY position',
      );
      
      return result.map((row) => row['position'] as String).toList();
    } catch (e) {
      debugPrint('Error getting unique positions: $e');
      return [];
    }
  }

  Future<List<String>> getUniqueDepartments() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT DISTINCT department FROM staff WHERE is_active = 1 AND department IS NOT NULL ORDER BY department',
      );
      
      return result.map((row) => row['department'] as String).toList();
    } catch (e) {
      debugPrint('Error getting unique departments: $e');
      return [];
    }
  }

  List<Staff> getStaffByPosition(String position) {
    return _staff.where((staff) => staff.position == position).toList();
  }

  List<Staff> getStaffByDepartment(String department) {
    return _staff.where((staff) => staff.department == department).toList();
  }
}
