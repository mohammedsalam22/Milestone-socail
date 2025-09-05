import '../../core/servcies/api_service.dart';
import '../../core/constants/api_endpoints.dart';
import '../model/employee_model.dart';

class EmployeeApi {
  final ApiService _apiService;

  EmployeeApi(this._apiService);

  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await _apiService.get(ApiEndpoints.employees);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final employees = data
            .map((json) => EmployeeModel.fromJson(json))
            .toList();
        return employees;
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting employees: $e');
    }
  }
}
