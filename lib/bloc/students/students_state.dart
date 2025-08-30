import '../../data/model/student_model.dart';

abstract class StudentsState {}

class StudentsInitial extends StudentsState {}

class StudentsLoading extends StudentsState {}

class StudentsLoaded extends StudentsState {
  final List<StudentModel> students;

  StudentsLoaded(this.students);
}

class StudentsError extends StudentsState {
  final String message;

  StudentsError(this.message);
}
