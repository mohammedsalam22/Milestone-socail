import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/schedule_repo.dart';
import '../../data/model/schedule_model.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _scheduleRepository;

  ScheduleCubit({required ScheduleRepository scheduleRepository})
    : _scheduleRepository = scheduleRepository,
      super(ScheduleInitial());

  Future<void> getStudentSchedule({required int sectionId}) async {
    try {
      emit(ScheduleLoading());

      final schedules = await _scheduleRepository.getStudentSchedule(
        sectionId: sectionId,
      );

      // Group schedules by day and sort them
      final groupedSchedules = _groupSchedulesByDay(schedules);

      // Create section info from first schedule if available
      String sectionInfo = '';
      if (schedules.isNotEmpty) {
        final firstSchedule = schedules.first;
        sectionInfo =
            '${firstSchedule.section.grade.studyStage.name} / ${firstSchedule.section.grade.name} / Section ${firstSchedule.section.name}';
      }

      emit(
        ScheduleLoaded(schedules: groupedSchedules, sectionInfo: sectionInfo),
      );
    } catch (e) {
      emit(ScheduleError(message: e.toString()));
    }
  }

  Future<void> getTeacherSchedule({required int teacherId}) async {
    try {
      emit(ScheduleLoading());

      final schedules = await _scheduleRepository.getTeacherSchedule(
        teacherId: teacherId,
      );

      // Group schedules by day and sort them
      final groupedSchedules = _groupSchedulesByDay(schedules);

      // Create teacher info
      const String teacherInfo = 'Teacher Schedule';

      emit(
        ScheduleLoaded(schedules: groupedSchedules, sectionInfo: teacherInfo),
      );
    } catch (e) {
      emit(ScheduleError(message: e.toString()));
    }
  }

  List<ScheduleModel> _groupSchedulesByDay(List<ScheduleModel> schedules) {
    // Sort schedules by day and time
    final dayOrder = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];

    schedules.sort((a, b) {
      final dayComparison = dayOrder
          .indexOf(a.day)
          .compareTo(dayOrder.indexOf(b.day));
      if (dayComparison != 0) return dayComparison;
      return a.startTime.compareTo(b.startTime);
    });

    return schedules;
  }

  void clearSchedule() {
    emit(ScheduleInitial());
  }
}
