import '../../data/model/attendance_model.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceModel> attendances;

  AttendanceLoaded(this.attendances);
}

class AttendanceCreated extends AttendanceState {
  final List<AttendanceModel> attendances;

  AttendanceCreated(this.attendances);
}

class AttendanceUpdated extends AttendanceState {
  final AttendanceModel attendance;

  AttendanceUpdated(this.attendance);
}

class AttendanceError extends AttendanceState {
  final String message;

  AttendanceError(this.message);
}
