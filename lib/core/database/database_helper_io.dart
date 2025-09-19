import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  static DatabaseHelper get instance => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'madrasah_management.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ... (same schema as before)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user',
        full_name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Students table
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        father_name TEXT NOT NULL,
        mother_name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        guardian_name TEXT NOT NULL,
        guardian_phone TEXT NOT NULL,
        guardian_relation TEXT NOT NULL,
        class_name TEXT NOT NULL,
        section TEXT,
        roll_number TEXT,
        admission_date TEXT NOT NULL,
        admission_fee REAL DEFAULT 0.0,
        monthly_fee REAL DEFAULT 0.0,
        discount_percentage REAL DEFAULT 0.0,
        is_active INTEGER DEFAULT 1,
        profile_image TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Staff table
    await db.execute('''
      CREATE TABLE staff (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_id TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        father_name TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        gender TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        position TEXT NOT NULL,
        department TEXT,
        qualification TEXT,
        experience_years INTEGER DEFAULT 0,
        joining_date TEXT NOT NULL,
        basic_salary REAL NOT NULL,
        allowances REAL DEFAULT 0.0,
        is_active INTEGER DEFAULT 1,
        profile_image TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Salary payments table
    await db.execute('''
      CREATE TABLE salary_payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        staff_id INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        basic_salary REAL NOT NULL,
        allowances REAL DEFAULT 0.0,
        deductions REAL DEFAULT 0.0,
        bonus REAL DEFAULT 0.0,
        total_salary REAL NOT NULL,
        payment_date TEXT,
        payment_status TEXT DEFAULT 'pending',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (staff_id) REFERENCES staff (id)
      )
    ''');

    // Student fees table
    await db.execute('''
      CREATE TABLE student_fees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        tuition_fee REAL NOT NULL,
        exam_fee REAL DEFAULT 0.0,
        transport_fee REAL DEFAULT 0.0,
        other_fees REAL DEFAULT 0.0,
        discount_amount REAL DEFAULT 0.0,
        total_amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0.0,
        due_amount REAL DEFAULT 0.0,
        payment_date TEXT,
        payment_status TEXT DEFAULT 'pending',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id)
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'present',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id),
        UNIQUE(student_id, date)
      )
    ''');

    // Accounting transactions table
    await db.execute('''
      CREATE TABLE accounting_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        reference_id INTEGER,
        reference_type TEXT,
        transaction_date TEXT NOT NULL,
        payment_method TEXT,
        receipt_number TEXT,
        created_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Data sync log table
    await db.execute('''
      CREATE TABLE sync_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        sync_status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL
      )
    ''');

    // Insert default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123', // In production, this should be hashed
      'role': 'admin',
      'full_name': 'System Administrator',
      'email': 'admin@madrasah.com',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Generic database operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(String table, Map<String, dynamic> data, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    data['updated_at'] = DateTime.now().toIso8601String();
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<Map<String, dynamic>?> queryFirst(String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final results = await query(table, where: where, whereArgs: whereArgs, limit: 1);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> count(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return result.first['count'] as int;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Export all data for synchronization
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    
    final data = <String, dynamic>{};
    final tables = [
      'students',
      'staff',
      'salary_payments',
      'student_fees',
      'attendance',
      'accounting_transactions',
    ];

    for (final table in tables) {
      data[table] = await db.query(table);
    }

    data['export_timestamp'] = DateTime.now().toIso8601String();
    return data;
  }

  // Import data from export
  Future<void> importData(Map<String, dynamic> data) async {
    final db = await database;
    
    await db.transaction((txn) async {
      final tables = [
        'students',
        'staff',
        'salary_payments',
        'student_fees',
        'attendance',
        'accounting_transactions',
      ];

      for (final table in tables) {
        if (data.containsKey(table)) {
          final records = data[table] as List<dynamic>;
          
          for (final record in records) {
            final recordMap = Map<String, dynamic>.from(record as Map);
            
            // Check if record exists
            final existingRecord = await txn.query(
              table,
              where: 'id = ?',
              whereArgs: [recordMap['id']],
            );

            if (existingRecord.isNotEmpty) {
              // Update existing record if imported data is newer
              final existingUpdatedAt = DateTime.parse(existingRecord.first['updated_at'] as String);
              final importedUpdatedAt = DateTime.parse(recordMap['updated_at'] as String);
              
              if (importedUpdatedAt.isAfter(existingUpdatedAt)) {
                await txn.update(
                  table,
                  recordMap,
                  where: 'id = ?',
                  whereArgs: [recordMap['id']],
                );
              }
            } else {
              // Insert new record
              await txn.insert(table, recordMap);
            }
          }
        }
      }
    });
  }
}
