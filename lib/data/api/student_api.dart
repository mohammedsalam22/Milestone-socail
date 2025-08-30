import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/student_model.dart';

class StudentApi {
  final ApiService _apiService;

  StudentApi(this._apiService);

  Future<List<StudentModel>> getStudents({int? sectionId}) async {
    try {
      String endpoint = ApiEndpoints.students;
      Map<String, dynamic> params = {};
      
      if (sectionId != null) {
        params['section'] = sectionId.toString();
      }
      
      final response = await _apiService.get(endpoint, params: params);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final students = data.map((json) => StudentModel.fromJson(json)).toList();
        return students;
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting students: $e');
    }
  }

  Future<List<StudentModel>> getAllStudents() async {
    try {
      final response = await _apiService.get(ApiEndpoints.students);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final students = data.map((json) => StudentModel.fromJson(json)).toList();
        return students;
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting students: $e');
    }
  }
}
