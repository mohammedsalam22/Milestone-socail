import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/employee_repo.dart';
import '../../data/model/employee_model.dart';
import 'employees_state.dart';

class EmployeesCubit extends Cubit<EmployeesState> {
  final EmployeeRepo _employeeRepo;
  List<EmployeeModel> _allEmployees = [];

  EmployeesCubit(this._employeeRepo) : super(EmployeesInitial());

  Future<void> getEmployees() async {
    if (isClosed) return;

    emit(EmployeesLoading());

    try {
      final employees = await _employeeRepo.getEmployees();
      _allEmployees = employees;
      if (isClosed) return;
      emit(EmployeesLoaded(employees));
    } catch (e) {
      if (isClosed) return;
      emit(EmployeesError(e.toString()));
    }
  }

  Future<void> refreshEmployees() async {
    await getEmployees();
  }

  List<EmployeeModel> get employees => _allEmployees;

  List<EmployeeModel> getEmployeesByRole(String role) {
    return _allEmployees
        .where((employee) => employee.role.toLowerCase() == role.toLowerCase())
        .toList();
  }

  List<EmployeeModel> getTeachers() {
    return getEmployeesByRole('teacher');
  }

  List<EmployeeModel> getCooperators() {
    return getEmployeesByRole('cooperator');
  }

  List<EmployeeModel> getAdmins() {
    return getEmployeesByRole('admin');
  }
}
