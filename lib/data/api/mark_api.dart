import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/mark_model.dart';

class MarkApi {
  final ApiService _apiService;

  MarkApi(this._apiService);

  Future<List<MarkModel>> getStudentMarks({required int studentId}) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.marks,
        params: {'student': studentId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final marks = data.map((json) => MarkModel.fromJson(json)).toList();
        return marks;
      } else {
        throw Exception('Failed to load student marks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting student marks: $e');
    }
  }
}
