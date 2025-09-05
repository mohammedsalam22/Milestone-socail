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
}
