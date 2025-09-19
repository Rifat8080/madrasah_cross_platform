import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common/sqlite_api.dart' as api;

/// Web stub for DatabaseHelper.
/// It uses an in-memory fake database via sqflite_common's in-memory support when available,
/// otherwise provides minimal mock behavior so UI can render on web.

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  // Simple in-memory storage for tables as Map<table, List<row>>
  final Map<String, List<Map<String, dynamic>>> _store = {};

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<dynamic> get database async {
    // Return a sentinel; other methods use _store directly
    return this;
  }

  // Seed default data (admin user) so login works on web
  void _ensureSeeded() {
    if (_store.containsKey('users')) return;
    _store['users'] = [
      {
        'id': 1,
        'username': 'admin',
        'password': 'admin123',
        'role': 'admin',
        'full_name': 'System Administrator',
        'email': 'admin@madrasah.com',
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }
    ];
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
  _ensureSeeded();
    data['id'] = (DateTime.now().microsecondsSinceEpoch / 1000).toInt();
    data['created_at'] = data['created_at'] ?? DateTime.now().toIso8601String();
    data['updated_at'] = data['updated_at'] ?? DateTime.now().toIso8601String();

    _store.putIfAbsent(table, () => []);
    _store[table]!.add(Map<String, dynamic>.from(data));
    return data['id'] as int;
  }

  Future<List<Map<String, dynamic>>> query(String table, {String? where, List<dynamic>? whereArgs, String? orderBy, int? limit}) async {
    _ensureSeeded();
    final list = _store[table] ?? [];

    if (where == null || whereArgs == null || whereArgs.isEmpty) {
      return List<Map<String, dynamic>>.from(list);
    }

    // Basic WHERE parsing for patterns used in the app: 'username = ? AND password = ? AND is_active = ?' and 'id = ?'
    final whereLower = where.toLowerCase();
    if (whereLower.contains('username') && whereLower.contains('password')) {
      final username = whereArgs[0];
      final password = whereArgs[1];
      final isActive = whereArgs.length > 2 ? whereArgs[2] : 1;

      return list.where((r) {
        return r['username'] == username && r['password'] == password && (r['is_active'] == isActive || r['is_active'] == (isActive as int));
      }).toList();
    }

    if (whereLower.contains('id =')) {
      final id = whereArgs[0];
      return list.where((r) => r['id'] == id).toList();
    }

    // Fallback: return full list
    return List<Map<String, dynamic>>.from(list);
  }

  Future<int> update(String table, Map<String, dynamic> data, {required String where, required List<dynamic> whereArgs}) async {
    final list = _store[table] ?? [];
    final id = whereArgs.first as int;
    final idx = list.indexWhere((r) => r['id'] == id);
    if (idx >= 0) {
      data['updated_at'] = DateTime.now().toIso8601String();
      list[idx] = {...list[idx], ...data};
      return 1;
    }
    return 0;
  }

  Future<int> delete(String table, {required String where, required List<dynamic> whereArgs}) async {
    final list = _store[table] ?? [];
    final id = whereArgs.first as int;
    final idx = list.indexWhere((r) => r['id'] == id);
    if (idx >= 0) {
      list.removeAt(idx);
      return 1;
    }
    return 0;
  }

  Future<Map<String, dynamic>?> queryFirst(String table, {String? where, List<dynamic>? whereArgs}) async {
  _ensureSeeded();
  final results = await query(table, where: where, whereArgs: whereArgs);
  return results.isNotEmpty ? results.first : null;
  }

  Future<int> count(String table, {String? where, List<dynamic>? whereArgs}) async {
    final list = _store[table] ?? [];
    return list.length;
  }

  Future<void> close() async {}

  Future<Map<String, dynamic>> exportAllData() async {
    final data = <String, dynamic>{};
    for (final entry in _store.entries) {
      data[entry.key] = entry.value;
    }
    data['export_timestamp'] = DateTime.now().toIso8601String();
    return data;
  }

  Future<void> importData(Map<String, dynamic> data) async {
    for (final key in data.keys) {
      if (key == 'export_timestamp') continue;
      final records = data[key] as List<dynamic>?;
      if (records != null) {
        _store[key] = records.map((r) => Map<String, dynamic>.from(r as Map)).toList();
      }
    }
  }
}
