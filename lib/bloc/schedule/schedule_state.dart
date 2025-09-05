import '../../data/model/schedule_model.dart';

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleModel> schedules;
  final String sectionInfo;

  ScheduleLoaded({required this.schedules, required this.sectionInfo});
}

class ScheduleError extends ScheduleState {
  final String message;

  ScheduleError({required this.message});
}
