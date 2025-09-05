import '../../data/model/employee_model.dart';

abstract class EmployeesState {}

class EmployeesInitial extends EmployeesState {}

class EmployeesLoading extends EmployeesState {}

class EmployeesLoaded extends EmployeesState {
  final List<EmployeeModel> employees;

  EmployeesLoaded(this.employees);
}

class EmployeesError extends EmployeesState {
  final String message;

  EmployeesError(this.message);
}
