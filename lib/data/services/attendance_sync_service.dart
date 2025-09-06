import '../model/attendance_model.dart';
import '../api/attendance_api.dart';
import 'attendance_local_db.dart';
import 'network_connectivity_manager.dart';
import 'attendance_notification_service.dart';

class AttendanceSyncService {
  final AttendanceApi _apiService;
  final AttendanceLocalDb _localDb;

  AttendanceSyncService({
    required AttendanceApi apiService,
    required AttendanceLocalDb localDb,
    required AttendanceNotificationService notificationService,
  }) : _apiService = apiService,
       _localDb = localDb;

  // Initialize sync service and set up network callbacks
  Future<void> initialize() async {
    // Set up network reconnection callback
    NetworkConnectivityManager.setOnReconnectedCallback(() async {
      await _onNetworkReconnected();
    });
  }

  // Immediate sync when user marks absence (if online)
  Future<void> syncImmediately(AttendanceModel attendance) async {
    if (attendance.localId == null) {
      print('❌ Cannot sync attendance without localId');
      return;
    }

    if (!await NetworkConnectivityManager.checkOnline()) {
      // Offline - mark as pending
      await _localDb.markForRetry(attendance.localId!);
      print(
        '📱 Offline - marked ${attendance.studentName} as pending for later sync',
      );
      return;
    }

    try {
      await _syncSingleRecord(attendance);
      await _localDb.markAsSynced(attendance.localId!);

      // Show immediate success notification
      await AttendanceNotificationService.showSyncSuccess(1);
      print('✅ Immediate sync successful: ${attendance.studentName}');
    } catch (e) {
      // Mark for retry
      await _localDb.markAsFailed(attendance.localId!, e.toString());
      print('❌ Immediate sync failed for ${attendance.studentName}: $e');
    }
  }

  // Sync all pending records (called when network reconnects)
  Future<void> syncPendingRecords() async {
    if (!await NetworkConnectivityManager.checkOnline()) {
      print('📱 No internet connection - skipping sync');
      return;
    }

    try {
      final pendingRecords = await _localDb.getPendingRecords();
      final failedRecords = await _localDb.getRetryableRecords();

      if (pendingRecords.isEmpty && failedRecords.isEmpty) {
        print('📱 No records to sync');
        return;
      }

      print(
        '🔄 Starting sync: ${pendingRecords.length} pending, ${failedRecords.length} retryable',
      );

      int syncedCount = 0;
      int failedCount = 0;
      List<String> errors = [];

      // Sync pending records
      for (final record in pendingRecords) {
        try {
          await _syncSingleRecord(record);
          await _localDb.markAsSynced(record.localId!);
          syncedCount++;
          print('✅ Synced: ${record.studentName} on ${record.date}');
        } catch (e) {
          await _localDb.markAsFailed(record.localId!, e.toString());
          failedCount++;
          errors.add('${record.studentName}: $e');
          print('❌ Failed to sync ${record.studentName}: $e');
        }
      }

      // Retry failed records (max 3 attempts)
      for (final record in failedRecords) {
        try {
          await _syncSingleRecord(record);
          await _localDb.markAsSynced(record.localId!);
          syncedCount++;
          print('✅ Retry successful: ${record.studentName} on ${record.date}');
        } catch (e) {
          await _localDb.incrementRetryCount(record.localId!);
          failedCount++;
          errors.add('${record.studentName}: $e');
          print('❌ Retry failed for ${record.studentName}: $e');
        }
      }

      // Show notifications
      if (syncedCount > 0) {
        await AttendanceNotificationService.showSyncSuccess(syncedCount);
      }

      if (failedCount > 0) {
        await AttendanceNotificationService.showSyncError(
          '${failedCount} record${failedCount > 1 ? 's' : ''} failed to sync',
        );
      }

      // Show summary notification
      await AttendanceNotificationService.showSyncCompleted(
        syncedCount: syncedCount,
        failedCount: failedCount,
      );
    } catch (e) {
      await AttendanceNotificationService.showSyncError('Sync failed: $e');
      print('❌ Sync process failed: $e');
    }
  }

  // Sync single record
  Future<void> _syncSingleRecord(AttendanceModel attendance) async {
    if (attendance.localId == null) {
      throw Exception('Cannot sync attendance without localId');
    }

    try {
      // Check if record exists on server
      final serverRecord = await _apiService.getAttendanceRecord(
        studentId: attendance.studentId,
        date: attendance.date,
      );

      if (serverRecord != null) {
        // Conflict: Server already has this record
        // Server wins - delete local record
        await _localDb.deleteRecord(attendance.localId!);
        print(
          '⚠️ Conflict resolved: Server record kept for ${attendance.studentName} on ${attendance.date}',
        );
      } else {
        // No conflict - create on server
        await _apiService.createAttendance(attendance);
        print(
          '✅ Created on server: ${attendance.studentName} on ${attendance.date}',
        );
      }
    } catch (e) {
      print('❌ Error syncing ${attendance.studentName}: $e');
      rethrow;
    }
  }

  // Retry specific failed record
  Future<void> retryFailedRecord(AttendanceModel attendance) async {
    if (attendance.localId == null) {
      throw Exception('Cannot retry attendance without localId');
    }

    if (!await NetworkConnectivityManager.checkOnline()) {
      throw Exception('No internet connection');
    }

    try {
      await _syncSingleRecord(attendance);
      await _localDb.markAsSynced(attendance.localId!);
      await AttendanceNotificationService.showSyncSuccess(1);
      print('✅ Retry successful: ${attendance.studentName}');
    } catch (e) {
      await _localDb.incrementRetryCount(attendance.localId!);
      await AttendanceNotificationService.showSyncError('Retry failed: $e');
      print('❌ Retry failed for ${attendance.studentName}: $e');
      rethrow;
    }
  }

  // Network reconnected callback
  Future<void> _onNetworkReconnected() async {
    print('🌐 Network reconnected - starting sync...');
    await AttendanceNotificationService.showNetworkReconnected();
    await syncPendingRecords();
  }

  // Get sync statistics
  Future<Map<String, int>> getSyncStatistics() async {
    return await _localDb.getSyncStatistics();
  }

  // Check if there are pending records
  Future<bool> hasPendingRecords() async {
    final pendingRecords = await _localDb.getPendingRecords();
    final retryableRecords = await _localDb.getRetryableRecords();
    return pendingRecords.isNotEmpty || retryableRecords.isNotEmpty;
  }

  // Force sync all records
  Future<void> forceSyncAll() async {
    print('🔄 Force syncing all records...');
    await syncPendingRecords();
  }

  // Clear all synced records (cleanup)
  Future<void> clearSyncedRecords() async {
    final syncedRecords = await _localDb.getRecordsByStatus('synced');
    for (final record in syncedRecords) {
      await _localDb.deleteRecord(record.localId!);
    }
    print('🧹 Cleared ${syncedRecords.length} synced records');
  }
}
