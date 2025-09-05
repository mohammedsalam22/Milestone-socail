import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/incident_model.dart';

class IncidentApi {
  final ApiService _apiService;

  IncidentApi(this._apiService);

  Future<List<IncidentModel>> getIncidents({int? sectionId}) async {
    try {
      String endpoint = ApiEndpoints.incidents;
      Map<String, dynamic> params = {};

      if (sectionId != null) {
        params['students__section'] = sectionId.toString();
      }

      final response = await _apiService.get(endpoint, params: params);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final incidents = data
            .map((json) => IncidentModel.fromJson(json))
            .toList();
        return incidents;
      } else {
        throw Exception('Failed to load incidents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting incidents: $e');
    }
  }

  Future<List<IncidentModel>> getStudentIncidents({
    required int studentId,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.incidents,
        params: {'students__id': studentId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final incidents = data
            .map((json) => IncidentModel.fromJson(json))
            .toList();
        return incidents;
      } else {
        throw Exception(
          'Failed to load student incidents: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting student incidents: $e');
    }
  }

  Future<IncidentModel> createIncident({
    required List<int> studentIds,
    required String title,
    required String procedure,
    required String note,
    required DateTime date,
  }) async {
    try {
      final body = {
        'students': studentIds,
        'title': title,
        'procedure': procedure,
        'note': note,
        'date': date.toIso8601String(),
      };

      final response = await _apiService.post(
        ApiEndpoints.incidents,
        data: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return IncidentModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create incident: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating incident: $e');
    }
  }

  Future<void> deleteIncident(int incidentId) async {
    try {
      final response = await _apiService.delete(
        '${ApiEndpoints.incidents}/$incidentId',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete incident: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting incident: $e');
    }
  }
}
