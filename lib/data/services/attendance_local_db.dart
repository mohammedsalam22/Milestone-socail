import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/attendance_model.dart';

class AttendanceLocalDb {
  static Database? _database;
  static const String _tableName = 'attendance_records';
  static const int _version = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'attendance.db');
    return await openDatabase(path, version: _version, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        student_name TEXT NOT NULL,
        date TEXT NOT NULL,
        absent INTEGER NOT NULL,
        excused INTEGER NOT NULL,
        note TEXT,
        local_id INTEGER,
        server_id TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        retry_count INTEGER DEFAULT 0,
        error_message TEXT,
        local_timestamp TEXT,
        created_at TEXT NOT NULL,
        UNIQUE(student_id, date)
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_attendance_student_date ON $_tableName(student_id, date)
    ''');

    await db.execute('''
      CREATE INDEX idx_attendance_sync_status ON $_tableName(sync_status)
    ''');

    await db.execute('''
      CREATE INDEX idx_attendance_retry_count ON $_tableName(retry_count)
    ''');
  }

  // Create attendance record
  Future<int> createAttendance(AttendanceModel attendance) async {
    final db = await database;
    final attendanceWithTimestamp = attendance.copyWith(
      localTimestamp: DateTime.now(),
      createdAt: DateTime.now(),
      syncStatus: 'pending',
    );

    return await db.insert(
      _tableName,
      attendanceWithTimestamp.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all attendance records
  Future<List<AttendanceModel>> getAllAttendances() async {
    final db = await database;
    final result = await db.query(_tableName, orderBy: 'created_at DESC');
    return result.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  // Get attendances by section and date
  Future<List<AttendanceModel>> getAttendancesBySectionAndDate({
    required int sectionId,
    required DateTime date,
  }) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'date = ?',
      whereArgs: [date.toIso8601String().split('T')[0]],
      orderBy: 'student_name ASC',
    );
    return result.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  // Get student attendances
  Future<List<AttendanceModel>> getStudentAttendances(int studentId) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'date DESC',
    );
    return result.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  // Get records by sync status
  Future<List<AttendanceModel>> getRecordsByStatus(String status) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'sync_status = ?',
      whereArgs: [status],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  // Get pending records
  Future<List<AttendanceModel>> getPendingRecords() async {
    return await getRecordsByStatus('pending');
  }

  // Get failed records
  Future<List<AttendanceModel>> getFailedRecords() async {
    return await getRecordsByStatus('failed');
  }

  // Get retryable records (retry_count < 3)
  Future<List<AttendanceModel>> getRetryableRecords() async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'sync_status = ? AND retry_count < ?',
      whereArgs: ['failed', 3],
      orderBy: 'created_at ASC',
    );
    return result.map((map) => AttendanceModel.fromMap(map)).toList();
  }

  // Update attendance record
  Future<void> updateAttendance(AttendanceModel attendance) async {
    final db = await database;
    await db.update(
      _tableName,
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.localId],
    );
  }

  // Mark as synced
  Future<void> markAsSynced(int localId) async {
    final db = await database;
    await db.update(
      _tableName,
      {'sync_status': 'synced', 'retry_count': 0, 'error_message': null},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Mark as failed
  Future<void> markAsFailed(int localId, String errorMessage) async {
    final db = await database;
    await db.update(
      _tableName,
      {'sync_status': 'failed', 'error_message': errorMessage},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Mark for retry
  Future<void> markForRetry(int localId) async {
    final db = await database;
    await db.update(
      _tableName,
      {'sync_status': 'pending', 'retry_count': 0, 'error_message': null},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Increment retry count
  Future<void> incrementRetryCount(int localId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $_tableName SET retry_count = retry_count + 1 WHERE id = ?',
      [localId],
    );
  }

  // Delete record
  Future<void> deleteRecord(int localId) async {
    final db = await database;
    await db.delete(_tableName, where: 'id = ?', whereArgs: [localId]);
  }

  // Check if record exists
  Future<bool> recordExists(int studentId, DateTime date) async {
    final db = await database;
    final result = await db.query(
      _tableName,
      where: 'student_id = ? AND date = ?',
      whereArgs: [studentId, date.toIso8601String().split('T')[0]],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Get sync statistics
  Future<Map<String, int>> getSyncStatistics() async {
    final db = await database;

    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE sync_status = ?',
      ['pending'],
    );

    final syncedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE sync_status = ?',
      ['synced'],
    );

    final failedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $_tableName WHERE sync_status = ?',
      ['failed'],
    );

    return {
      'pending': pendingResult.first['count'] as int,
      'synced': syncedResult.first['count'] as int,
      'failed': failedResult.first['count'] as int,
    };
  }

  // Clear all records (for testing)
  Future<void> clearAllRecords() async {
    final db = await database;
    await db.delete(_tableName);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
