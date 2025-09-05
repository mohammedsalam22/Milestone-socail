import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/schedule_model.dart';

class ScheduleApi {
  final ApiService _apiService;

  ScheduleApi(this._apiService);

  Future<List<ScheduleModel>> getStudentSchedule({
    required int sectionId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.schedules,
        params: {'section': sectionId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final schedules = data
            .map((json) => ScheduleModel.fromJson(json))
            .toList();
        return schedules;
      } else {
        throw Exception(
          'Failed to load student schedule: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting student schedule: $e');
    }
  }

  Future<List<ScheduleModel>> getTeacherSchedule({
    required int teacherId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.schedules,
        params: {'teacher': teacherId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final schedules = data
            .map((json) => ScheduleModel.fromJson(json))
            .toList();
        return schedules;
      } else {
        throw Exception(
          'Failed to load teacher schedule: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting teacher schedule: $e');
    }
  }
}
