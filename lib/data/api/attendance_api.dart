import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/attendance_model.dart';

class AttendanceApi {
  final ApiService _apiService;

  AttendanceApi(this._apiService);

  Future<List<AttendanceModel>> getAttendances({
    required int sectionId,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.attendances,
        params: {
          'student__section': sectionId.toString(),
          'date': date.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final attendances = data
            .map((json) => AttendanceModel.fromJson(json))
            .toList();
        return attendances;
      } else {
        throw Exception('Failed to load attendances: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting attendances: $e');
    }
  }

  Future<List<AttendanceModel>> getStudentAttendances({
    required int studentId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.attendances,
        params: {'student': studentId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final attendances = data
            .map((json) => AttendanceModel.fromJson(json))
            .toList();
        return attendances;
      } else {
        throw Exception(
          'Failed to load student attendances: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting student attendances: $e');
    }
  }

  Future<void> createAttendances({
    required List<AttendanceModel> attendances,
  }) async {
    try {
      final body = attendances
          .map((attendance) => attendance.toCreateJson())
          .toList();

      final response = await _apiService.post(
        ApiEndpoints.attendances,
        data: body,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create attendances: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating attendances: $e');
    }
  }

  Future<void> updateAttendance({
    required int studentId,
    required DateTime date,
    required bool absent,
    required bool excused,
    required String note,
  }) async {
    try {
      final body = {
        'student_id': studentId,
        'date': date.toIso8601String().split('T')[0],
        'absent': absent,
        'excused': excused,
        'note': note,
      };

      final response = await _apiService.put(
        '${ApiEndpoints.attendances}/$studentId',
        data: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update attendance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating attendance: $e');
    }
  }

  // Check if attendance record exists on server
  Future<AttendanceModel?> getAttendanceRecord({
    required int studentId,
    required DateTime date,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.attendances,
        params: {
          'student': studentId.toString(),
          'date': date.toIso8601String().split('T')[0],
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isNotEmpty) {
          return AttendanceModel.fromJson(data.first);
        }
      }
      return null;
    } catch (e) {
      return null; // Record doesn't exist
    }
  }

  // Create single attendance record
  Future<void> createAttendance(AttendanceModel attendance) async {
    try {
      // Wrap single record in a list as the API expects
      final body = [attendance.toCreateJson()];

      final response = await _apiService.post(
        ApiEndpoints.attendances,
        data: body,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to create attendance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating attendance: $e');
    }
  }
}
