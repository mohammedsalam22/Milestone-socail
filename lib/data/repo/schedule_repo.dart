import '../api/schedule_api.dart';
import '../model/schedule_model.dart';

class ScheduleRepository {
  final ScheduleApi _scheduleApi;

  ScheduleRepository({required ScheduleApi scheduleApi})
    : _scheduleApi = scheduleApi;

  Future<List<ScheduleModel>> getStudentSchedule({
    required int sectionId,
  }) async {
    try {
      return await _scheduleApi.getStudentSchedule(sectionId: sectionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScheduleModel>> getTeacherSchedule({
    required int teacherId,
  }) async {
    try {
      return await _scheduleApi.getTeacherSchedule(teacherId: teacherId);
    } catch (e) {
      rethrow;
    }
  }
}
