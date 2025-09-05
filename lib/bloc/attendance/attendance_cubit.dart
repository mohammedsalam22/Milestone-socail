import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/attendance_repo.dart';
import '../../data/model/attendance_model.dart';
import 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepo _attendanceRepo;
  List<AttendanceModel> _allAttendances = [];

  AttendanceCubit(this._attendanceRepo) : super(AttendanceInitial());

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

  Future<void> createAttendances({
    required List<AttendanceModel> attendances,
  }) async {
    if (isClosed) return;
    try {
      await _attendanceRepo.createAttendances(attendances: attendances);
      if (isClosed) return;
      _allAttendances.addAll(attendances);
      emit(AttendanceCreated(attendances));
      emit(AttendanceLoaded(_allAttendances));
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
        _allAttendances[index] = AttendanceModel(
          studentId: studentId,
          studentName: _allAttendances[index].studentName,
          date: date,
          absent: absent,
          excused: excused,
          note: note,
        );
        emit(AttendanceUpdated(_allAttendances[index]));
        emit(AttendanceLoaded(_allAttendances));
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

  List<AttendanceModel> get attendances => _allAttendances;
}
