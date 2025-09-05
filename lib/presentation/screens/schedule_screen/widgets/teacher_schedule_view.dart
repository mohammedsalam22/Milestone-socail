import 'package:flutter/material.dart';
import '../../../../data/model/user_model.dart';
import 'schedule_view.dart';

class TeacherScheduleView extends StatelessWidget {
  final UserModel user;

  const TeacherScheduleView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ScheduleView(
      user: user,
      type: ScheduleType.teacher,
      title: 'Teacher Schedule',
    );
  }
}
