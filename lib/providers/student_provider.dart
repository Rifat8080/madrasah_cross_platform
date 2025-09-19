import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../models/student.dart';

class StudentProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Student> _students = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Student> get students => _students;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Student> get filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    
    return _students.where((student) =>
      student.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      student.studentId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      student.className.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final studentMaps = await _db.query(
        'students',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'full_name ASC',
      );

      _students = studentMaps.map((map) => Student.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error loading students: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Student?> getStudent(int id) async {
    try {
      final studentMap = await _db.queryFirst(
        'students',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (studentMap != null) {
        return Student.fromMap(studentMap);
      }
    } catch (e) {
      debugPrint('Error getting student: $e');
    }
    return null;
  }

  Future<bool> addStudent(Student student) async {
    try {
      final studentMap = student.toMap();
      studentMap.remove('id'); // Remove id for insertion
      
      final id = await _db.insert('students', studentMap);
      
      if (id > 0) {
        await loadStudents(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error adding student: $e');
    }
    return false;
  }

  Future<bool> updateStudent(Student student) async {
    try {
      final count = await _db.update(
        'students',
        student.toMap(),
        where: 'id = ?',
        whereArgs: [student.id],
      );
      
      if (count > 0) {
        await loadStudents(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error updating student: $e');
    }
    return false;
  }

  Future<bool> deleteStudent(int id) async {
    try {
      // Soft delete by setting is_active to 0
      final count = await _db.update(
        'students',
        {'is_active': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count > 0) {
        await loadStudents(); // Refresh the list
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting student: $e');
    }
    return false;
  }

  Future<bool> isStudentIdUnique(String studentId, {int? excludeId}) async {
    try {
      String whereClause = 'student_id = ?';
      List<dynamic> whereArgs = [studentId];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final count = await _db.count(
        'students',
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      return count == 0;
    } catch (e) {
      debugPrint('Error checking student ID uniqueness: $e');
      return false;
    }
  }

  Future<Map<String, int>> getStudentStats() async {
    try {
      final totalStudents = await _db.count(
        'students',
        where: 'is_active = ?',
        whereArgs: [1],
      );
      
      final maleStudents = await _db.count(
        'students',
        where: 'is_active = ? AND gender = ?',
        whereArgs: [1, 'Male'],
      );
      
      final femaleStudents = await _db.count(
        'students',
        where: 'is_active = ? AND gender = ?',
        whereArgs: [1, 'Female'],
      );

      return {
        'total': totalStudents,
        'male': maleStudents,
        'female': femaleStudents,
      };
    } catch (e) {
      debugPrint('Error getting student stats: $e');
      return {'total': 0, 'male': 0, 'female': 0};
    }
  }

  Future<List<String>> getUniqueClasses() async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery(
        'SELECT DISTINCT class_name FROM students WHERE is_active = 1 ORDER BY class_name',
      );
      
      return result.map((row) => row['class_name'] as String).toList();
    } catch (e) {
      debugPrint('Error getting unique classes: $e');
      return [];
    }
  }

  List<Student> getStudentsByClass(String className) {
    return _students.where((student) => student.className == className).toList();
  }
}
