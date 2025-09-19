import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../core/database/database_helper.dart';

class DataSyncService {
  static final DataSyncService _instance = DataSyncService._internal();
  static DataSyncService get instance => _instance;
  DataSyncService._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Export all data to a JSON file
  Future<String?> exportData() async {
    try {
      // Get all data from database
      final data = await _db.exportAllData();
      
      // Add metadata
      data['export_info'] = {
        'version': '1.0.0',
        'exported_by': 'Madrasah Management System',
        'exported_at': DateTime.now().toIso8601String(),
        'platform': Platform.operatingSystem,
        'total_records': _calculateTotalRecords(data),
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // Save to file
      final fileName = 'madrasah_backup_${_getTimestamp()}.json';
      
      if (kIsWeb) {
        // For web, we'll need to trigger download differently
        return jsonString; // Return the JSON string for web handling
      } else {
        // For desktop/mobile, save to Documents directory
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        return file.path;
      }
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return null;
    }
  }

  /// Import data from a JSON file
  Future<bool> importData(String? filePath) async {
    try {
      String jsonString;
      
      if (filePath == null) {
        // Let user pick a file
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          jsonString = await file.readAsString();
        } else {
          return false;
        }
      } else {
        final file = File(filePath);
        jsonString = await file.readAsString();
      }

      // Parse JSON
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Validate data structure
      if (!_validateImportData(data)) {
        throw Exception('Invalid backup file format');
      }
      
      // Import data to database
      await _db.importData(data);
      
      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  /// Export specific table data
  Future<String?> exportTableData(String tableName) async {
    try {
      final db = await _db.database;
      final tableData = await db.query(tableName);
      
      final data = {
        'table_name': tableName,
        'export_timestamp': DateTime.now().toIso8601String(),
        'record_count': tableData.length,
        'data': tableData,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final fileName = '${tableName}_export_${_getTimestamp()}.json';
      
      if (kIsWeb) {
        return jsonString;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        return file.path;
      }
    } catch (e) {
      debugPrint('Error exporting table data: $e');
      return null;
    }
  }

  /// Import specific table data
  Future<bool> importTableData(String filePath, {bool replaceExisting = false}) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      final tableName = data['table_name'] as String;
      final records = data['data'] as List<dynamic>;
      
      final db = await _db.database;
      
      await db.transaction((txn) async {
        if (replaceExisting) {
          // Clear existing data
          await txn.delete(tableName);
        }
        
        // Insert new data
        for (final record in records) {
          final recordMap = Map<String, dynamic>.from(record as Map);
          
          if (replaceExisting) {
            await txn.insert(tableName, recordMap);
          } else {
            // Check if record exists and update or insert accordingly
            final existingRecord = await txn.query(
              tableName,
              where: 'id = ?',
              whereArgs: [recordMap['id']],
            );
            
            if (existingRecord.isNotEmpty) {
              await txn.update(
                tableName,
                recordMap,
                where: 'id = ?',
                whereArgs: [recordMap['id']],
              );
            } else {
              await txn.insert(tableName, recordMap);
            }
          }
        }
      });
      
      return true;
    } catch (e) {
      debugPrint('Error importing table data: $e');
      return false;
    }
  }

  /// Create incremental backup (changes since last export)
  Future<String?> createIncrementalBackup(DateTime since) async {
    try {
      final db = await _db.database;
      
      // Get all tables that have been modified since the given date
      final modifiedData = <String, dynamic>{};
      final tables = [
        'students',
        'staff',
        'salary_payments',
        'student_fees',
        'attendance',
        'accounting_transactions',
      ];

      for (final table in tables) {
        final records = await db.query(
          table,
          where: 'updated_at > ?',
          whereArgs: [since.toIso8601String()],
        );
        
        if (records.isNotEmpty) {
          modifiedData[table] = records;
        }
      }

      if (modifiedData.isEmpty) {
        return null; // No changes to backup
      }

      // Add metadata
      modifiedData['backup_info'] = {
        'type': 'incremental',
        'since': since.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'total_changed_records': _calculateTotalRecords(modifiedData),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(modifiedData);
      final fileName = 'madrasah_incremental_${_getTimestamp()}.json';
      
      if (kIsWeb) {
        return jsonString;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);
        return file.path;
      }
    } catch (e) {
      debugPrint('Error creating incremental backup: $e');
      return null;
    }
  }

  /// Get backup info without importing
  Future<Map<String, dynamic>?> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      final exportInfo = data['export_info'] as Map<String, dynamic>?;
      if (exportInfo != null) {
        return exportInfo;
      }
      
      // Fallback: calculate info from data
      return {
        'version': 'Unknown',
        'exported_by': 'Unknown',
        'exported_at': 'Unknown',
        'platform': 'Unknown',
        'total_records': _calculateTotalRecords(data),
      };
    } catch (e) {
      debugPrint('Error getting backup info: $e');
      return null;
    }
  }

  /// Validate database integrity after import
  Future<Map<String, dynamic>> validateDatabaseIntegrity() async {
    try {
      final db = await _db.database;
      final validation = <String, dynamic>{};
      
      // Check table record counts
      final tables = [
        'students',
        'staff',
        'salary_payments',
        'student_fees',
        'attendance',
        'accounting_transactions',
      ];

      for (final table in tables) {
        final count = await _db.count(table);
        validation['${table}_count'] = count;
      }

      // Check for orphaned records
      validation['orphaned_salary_payments'] = await _checkOrphanedRecords(
        'salary_payments', 'staff_id', 'staff', 'id'
      );
      
      validation['orphaned_student_fees'] = await _checkOrphanedRecords(
        'student_fees', 'student_id', 'students', 'id'
      );
      
      validation['orphaned_attendance'] = await _checkOrphanedRecords(
        'attendance', 'student_id', 'students', 'id'
      );

      validation['validation_timestamp'] = DateTime.now().toIso8601String();
      validation['status'] = 'completed';
      
      return validation;
    } catch (e) {
      debugPrint('Error validating database integrity: $e');
      return {
        'status': 'error',
        'error': e.toString(),
        'validation_timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  // Helper methods
  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}'
           '${now.day.toString().padLeft(2, '0')}_'
           '${now.hour.toString().padLeft(2, '0')}'
           '${now.minute.toString().padLeft(2, '0')}';
  }

  int _calculateTotalRecords(Map<String, dynamic> data) {
    int total = 0;
    final tables = [
      'students',
      'staff',
      'salary_payments',
      'student_fees',
      'attendance',
      'accounting_transactions',
    ];

    for (final table in tables) {
      if (data.containsKey(table) && data[table] is List) {
        total += (data[table] as List).length;
      }
    }
    return total;
  }

  bool _validateImportData(Map<String, dynamic> data) {
    // Check if required tables exist
    final requiredTables = ['students', 'staff'];
    
    for (final table in requiredTables) {
      if (!data.containsKey(table)) {
        return false;
      }
      
      if (data[table] is! List) {
        return false;
      }
    }
    
    return true;
  }

  Future<int> _checkOrphanedRecords(
    String childTable,
    String foreignKey,
    String parentTable,
    String parentKey,
  ) async {
    try {
      final db = await _db.database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $childTable c
        LEFT JOIN $parentTable p ON c.$foreignKey = p.$parentKey
        WHERE p.$parentKey IS NULL
      ''');
      
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('Error checking orphaned records: $e');
      return 0;
    }
  }
}
