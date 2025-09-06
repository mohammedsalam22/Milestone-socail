import '../api/attendance_api.dart';
import '../model/attendance_model.dart';
import '../services/attendance_local_db.dart';
import '../services/attendance_sync_service.dart';
import '../services/network_connectivity_manager.dart';

class AttendanceRepo {
  final AttendanceApi _attendanceApi;
  final AttendanceLocalDb _localDb;
  final AttendanceSyncService _syncService;

  AttendanceRepo(this._attendanceApi, this._localDb, this._syncService);

  // Hybrid method - tries online first, falls back to offline
  Future<List<AttendanceModel>> getAttendances({
    required int sectionId,
    required DateTime date,
  }) async {
    try {
      // Try online first
      if (await NetworkConnectivityManager.checkOnline()) {
        final onlineAttendances = await _attendanceApi.getAttendances(
          sectionId: sectionId,
          date: date,
        );

        // Cache online data locally for offline access
        for (final attendance in onlineAttendances) {
          await _localDb.createAttendance(attendance);
        }

        return onlineAttendances;
      }
    } catch (e) {
      print('Online fetch failed, falling back to offline: $e');
    }

    // Fallback to offline data
    return await _localDb.getAttendancesBySectionAndDate(
      sectionId: sectionId,
      date: date,
    );
  }

  // Hybrid method for student attendances
  Future<List<AttendanceModel>> getStudentAttendances({
    required int studentId,
  }) async {
    try {
      // Try online first
      if (await NetworkConnectivityManager.checkOnline()) {
        final onlineAttendances = await _attendanceApi.getStudentAttendances(
          studentId: studentId,
        );

        // Cache online data locally
        for (final attendance in onlineAttendances) {
          await _localDb.createAttendance(attendance);
        }

        return onlineAttendances;
      }
    } catch (e) {
      print('Online fetch failed, falling back to offline: $e');
    }

    // Fallback to offline data
    return await _localDb.getStudentAttendances(studentId);
  }

  // Create attendances with offline support
  Future<void> createAttendances({
    required List<AttendanceModel> attendances,
  }) async {
    // Always save locally first and collect records with IDs
    List<AttendanceModel> attendancesWithIds = [];

    for (final attendance in attendances) {
      final attendanceWithTimestamp = attendance.copyWith(
        localTimestamp: DateTime.now(),
        createdAt: DateTime.now(),
        syncStatus: 'pending',
      );

      final localId = await _localDb.createAttendance(attendanceWithTimestamp);
      final attendanceWithId = attendanceWithTimestamp.copyWith(
        localId: localId,
      );
      attendancesWithIds.add(attendanceWithId);
    }

    // Try immediate sync if online
    if (await NetworkConnectivityManager.checkOnline()) {
      try {
        await _attendanceApi.createAttendances(attendances: attendances);

        // Mark as synced using the records with IDs
        for (final attendance in attendancesWithIds) {
          await _localDb.markAsSynced(attendance.localId!);
        }

        print('✅ Attendances created and synced immediately');
      } catch (e) {
        print('❌ Immediate sync failed, will retry later: $e');
        // Records are already marked as pending in local DB
      }
    } else {
      print('📱 Offline - attendances saved locally for later sync');
    }
  }

  // Update attendance with offline support
  Future<void> updateAttendance({
    required int studentId,
    required DateTime date,
    required bool absent,
    required bool excused,
    required String note,
  }) async {
    // Find the local record
    final localRecords = await _localDb.getAttendancesBySectionAndDate(
      sectionId: 0, // We'll need to pass sectionId or modify the query
      date: date,
    );

    final localRecord = localRecords.firstWhere(
      (record) => record.studentId == studentId,
      orElse: () => throw Exception('Record not found locally'),
    );

    // Update local record
    final updatedRecord = localRecord.copyWith(
      absent: absent,
      excused: excused,
      note: note,
      syncStatus: 'pending',
    );

    await _localDb.updateAttendance(updatedRecord);

    // Try immediate sync if online
    if (await NetworkConnectivityManager.checkOnline()) {
      try {
        await _attendanceApi.updateAttendance(
          studentId: studentId,
          date: date,
          absent: absent,
          excused: excused,
          note: note,
        );

        await _localDb.markAsSynced(updatedRecord.localId!);
        print('✅ Attendance updated and synced immediately');
      } catch (e) {
        print('❌ Immediate sync failed, will retry later: $e');
      }
    } else {
      print('📱 Offline - attendance updated locally for later sync');
    }
  }

  // Offline-only methods
  Future<List<AttendanceModel>> getOfflineAttendances({
    required int sectionId,
    required DateTime date,
  }) async {
    return await _localDb.getAttendancesBySectionAndDate(
      sectionId: sectionId,
      date: date,
    );
  }

  Future<List<AttendanceModel>> getPendingRecords() async {
    return await _localDb.getPendingRecords();
  }

  Future<List<AttendanceModel>> getFailedRecords() async {
    return await _localDb.getFailedRecords();
  }

  Future<Map<String, int>> getSyncStatistics() async {
    return await _localDb.getSyncStatistics();
  }

  // Sync methods
  Future<void> syncPendingRecords() async {
    await _syncService.syncPendingRecords();
  }

  Future<void> retryFailedRecord(AttendanceModel attendance) async {
    await _syncService.retryFailedRecord(attendance);
  }

  Future<bool> hasPendingRecords() async {
    return await _syncService.hasPendingRecords();
  }
}
