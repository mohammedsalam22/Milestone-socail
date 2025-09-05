import '../api/employee_api.dart';
import '../model/employee_model.dart';

class EmployeeRepo {
  final EmployeeApi _employeeApi;

  EmployeeRepo(this._employeeApi);

  Future<List<EmployeeModel>> getEmployees() async {
    try {
      return await _employeeApi.getEmployees();
    } catch (e) {
      rethrow;
    }
  }
}
