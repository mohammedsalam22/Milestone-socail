import '../api/incident_api.dart';
import '../model/incident_model.dart';

class IncidentRepo {
  final IncidentApi _incidentApi;

  IncidentRepo(this._incidentApi);

  Future<List<IncidentModel>> getIncidents({int? sectionId}) async {
    try {
      return await _incidentApi.getIncidents(sectionId: sectionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<IncidentModel>> getStudentIncidents({
    required int studentId,
  }) async {
    try {
      return await _incidentApi.getStudentIncidents(studentId: studentId);
    } catch (e) {
      rethrow;
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
      return await _incidentApi.createIncident(
        studentIds: studentIds,
        title: title,
        procedure: procedure,
        note: note,
        date: date,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteIncident(int incidentId) async {
    try {
      await _incidentApi.deleteIncident(incidentId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
