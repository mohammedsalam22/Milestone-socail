import '../api/mark_api.dart';
import '../model/mark_model.dart';

class MarkRepo {
  final MarkApi _markApi;

  MarkRepo(this._markApi);

  Future<List<MarkModel>> getStudentMarks({required int studentId}) async {
    try {
      return await _markApi.getStudentMarks(studentId: studentId);
    } catch (e) {
      rethrow;
    }
  }
}
