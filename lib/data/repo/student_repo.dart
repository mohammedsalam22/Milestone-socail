import '../api/student_api.dart';
import '../model/student_model.dart';

class StudentRepo {
  final StudentApi _studentApi;

  StudentRepo(this._studentApi);

  Future<List<StudentModel>> getStudents({int? sectionId}) async {
    try {
      return await _studentApi.getStudents(sectionId: sectionId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<StudentModel>> getAllStudents() async {
    try {
      return await _studentApi.getAllStudents();
    } catch (e) {
      rethrow;
    }
  }
}
