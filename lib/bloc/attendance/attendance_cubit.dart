import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/attendance_repo.dart';
import '../../data/model/attendance_model.dart';
import '../../data/services/network_connectivity_manager.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepo _attendanceRepo;
  List<AttendanceModel> _allAttendances = [];
  bool _isOnline = false;

  AttendanceCubit(this._attendanceRepo) : super(AttendanceInitial()) {
    _initializeConnectivity();
  }

  void _initializeConnectivity() async {
    _isOnline = await NetworkConnectivityManager.checkOnline();

    // Listen to connectivity changes
    NetworkConnectivityManager.connectivityStream.listen((isOnline) {
      _isOnline = isOnline;
      if (isOnline) {
        // Network reconnected - try to sync pending records
        _syncPendingRecords();
      }
    });
  }

  Future<void> getAttendances({
    required int sectionId,
    required DateTime date,
  }) async {
    if (isClosed) return;
    emit(AttendanceLoading());
    try {
      final attendances = await _attendanceRepo.getAttendances(
        sectionId: sectionId,
        date: date,
      );
      if (isClosed) return;
      _allAttendances = attendances;
      emit(AttendanceLoaded(_allAttendances));
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> getStudentAttendances({required int studentId}) async {
    if (isClosed) return;
    emit(AttendanceLoading());
    try {
      final attendances = await _attendanceRepo.getStudentAttendances(
        studentId: studentId,
      );
      if (isClosed) return;
      _allAttendances = attendances;
      emit(AttendanceLoaded(_allAttendances));
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> createAttendances({
    required List<AttendanceModel> attendances,
  }) async {
    if (isClosed) return;
    emit(AttendanceLoading());

    try {
      // Create attendances with offline support
      await _attendanceRepo.createAttendances(attendances: attendances);
      if (isClosed) return;

      _allAttendances.addAll(attendances);
      emit(AttendanceCreated(attendances));
      emit(AttendanceLoaded(_allAttendances));

      // Show appropriate message based on connectivity
      if (_isOnline) {
        emit(
          AttendanceMessage(
            'Attendance records created and synced successfully',
          ),
        );
      } else {
        emit(
          AttendanceMessage(
            'Attendance records saved offline - will sync when connected',
          ),
        );
      }
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> updateAttendance({
    required int studentId,
    required DateTime date,
    required bool absent,
    required bool excused,
    required String note,
  }) async {
    if (isClosed) return;
    emit(AttendanceLoading());

    try {
      await _attendanceRepo.updateAttendance(
        studentId: studentId,
        date: date,
        absent: absent,
        excused: excused,
        note: note,
      );
      if (isClosed) return;

      // Update local list
      final index = _allAttendances.indexWhere(
        (attendance) =>
            attendance.studentId == studentId &&
            attendance.date.year == date.year &&
            attendance.date.month == date.month &&
            attendance.date.day == date.day,
      );

      if (index != -1) {
        _allAttendances[index] = _allAttendances[index].copyWith(
          absent: absent,
          excused: excused,
          note: note,
        );
        emit(AttendanceUpdated(_allAttendances[index]));
        emit(AttendanceLoaded(_allAttendances));

        // Show appropriate message based on connectivity
        if (_isOnline) {
          emit(AttendanceMessage('Attendance updated and synced successfully'));
        } else {
          emit(
            AttendanceMessage(
              'Attendance updated offline - will sync when connected',
            ),
          );
        }
      }
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> refreshAttendances({
    required int sectionId,
    required DateTime date,
  }) async {
    if (isClosed) return;
    await getAttendances(sectionId: sectionId, date: date);
  }

  // Offline-specific methods
  Future<void> getOfflineAttendances({
    required int sectionId,
    required DateTime date,
  }) async {
    if (isClosed) return;
    emit(AttendanceLoading());

    try {
      final attendances = await _attendanceRepo.getOfflineAttendances(
        sectionId: sectionId,
        date: date,
      );
      if (isClosed) return;
      _allAttendances = attendances;
      emit(AttendanceLoaded(_allAttendances));
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> getPendingRecords() async {
    if (isClosed) return;
    emit(AttendanceLoading());

    try {
      final pendingRecords = await _attendanceRepo.getPendingRecords();
      if (isClosed) return;
      _allAttendances = pendingRecords;
      emit(AttendanceLoaded(_allAttendances));
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> getFailedRecords() async {
    if (isClosed) return;
    emit(AttendanceLoading());

    try {
      final failedRecords = await _attendanceRepo.getFailedRecords();
      if (isClosed) return;
      _allAttendances = failedRecords;
      emit(AttendanceLoaded(_allAttendances));
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError(e.toString()));
    }
  }

  Future<void> syncPendingRecords() async {
    if (isClosed) return;
    emit(AttendanceLoading());

    try {
      await _attendanceRepo.syncPendingRecords();
      if (isClosed) return;
      emit(AttendanceMessage('Sync completed successfully'));
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError('Sync failed: ${e.toString()}'));
    }
  }

  Future<void> retryFailedRecord(AttendanceModel attendance) async {
    if (isClosed) return;
    emit(AttendanceLoading());

    try {
      await _attendanceRepo.retryFailedRecord(attendance);
      if (isClosed) return;
      emit(AttendanceMessage('Record synced successfully'));
    } catch (e) {
      if (isClosed) return;
      emit(AttendanceError('Retry failed: ${e.toString()}'));
    }
  }

  Future<Map<String, int>> getSyncStatistics() async {
    return await _attendanceRepo.getSyncStatistics();
  }

  Future<bool> hasPendingRecords() async {
    return await _attendanceRepo.hasPendingRecords();
  }

  // Private method to sync pending records when network reconnects
  Future<void> _syncPendingRecords() async {
    try {
      await _attendanceRepo.syncPendingRecords();
      print('🔄 Background sync completed');
    } catch (e) {
      print('❌ Background sync failed: $e');
    }
  }

  // Getters
  List<AttendanceModel> get attendances => _allAttendances;
  bool get isOnline => _isOnline;
}
