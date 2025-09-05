import '../api/attendance_api.dart';
import '../model/attendance_model.dart';

class AttendanceRepo {
  final AttendanceApi _attendanceApi;

  AttendanceRepo(this._attendanceApi);

  Future<List<AttendanceModel>> getAttendances({
    required int sectionId,
    required DateTime date,
  }) async {
    return await _attendanceApi.getAttendances(
      sectionId: sectionId,
      date: date,
    );
  }

  Future<List<AttendanceModel>> getStudentAttendances({
    required int studentId,
  }) async {
    return await _attendanceApi.getStudentAttendances(studentId: studentId);
  }

  Future<void> createAttendances({
    required List<AttendanceModel> attendances,
  }) async {
    return await _attendanceApi.createAttendances(attendances: attendances);
  }

  Future<void> updateAttendance({
    required int studentId,
    required DateTime date,
    required bool absent,
    required bool excused,
    required String note,
  }) async {
    return await _attendanceApi.updateAttendance(
      studentId: studentId,
      date: date,
      absent: absent,
      excused: excused,
      note: note,
    );
  }
}
