import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/model/user_model.dart';
import '../../../../bloc/schedule/schedule_cubit.dart';
import '../../../../bloc/schedule/schedule_state.dart';
import 'schedule_card.dart';
import 'empty_schedule.dart';

enum ScheduleType { student, teacher }

class ScheduleView extends StatefulWidget {
  final UserModel user;
  final ScheduleType type;
  final String title;

  const ScheduleView({
    super.key,
    required this.user,
    required this.type,
    required this.title,
  });

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  bool _mounted = true;
  String _selectedDay = '';

  @override
  void initState() {
    super.initState();
    _mounted = true;
    // Start with current day
    _selectedDay = _getCurrentDay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        _loadSchedule();
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    return days[now.weekday % 7]; // Sunday is 0, Monday is 1, etc.
  }

  String _getDayDisplayName(String day) {
    switch (day.toLowerCase()) {
      case 'sun':
        return 'Sunday';
      case 'mon':
        return 'Monday';
      case 'tue':
        return 'Tuesday';
      case 'wed':
        return 'Wednesday';
      case 'thu':
        return 'Thursday';
      case 'fri':
        return 'Friday';
      case 'sat':
        return 'Saturday';
      default:
        return day;
    }
  }

  Color _getDayColor(String day) {
    switch (day.toLowerCase()) {
      case 'sun':
        return Colors.red;
      case 'mon':
        return Colors.blue;
      case 'tue':
        return Colors.green;
      case 'wed':
        return Colors.orange;
      case 'thu':
        return Colors.purple;
      case 'fri':
        return Colors.teal;
      case 'sat':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _goToPreviousDay() {
    final dayOrder = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    final currentIndex = dayOrder.indexOf(_selectedDay);
    if (currentIndex > 0) {
      setState(() {
        _selectedDay = dayOrder[currentIndex - 1];
      });
    } else {
      setState(() {
        _selectedDay = dayOrder.last; // Go to Saturday
      });
    }
  }

  void _goToNextDay() {
    final dayOrder = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    final currentIndex = dayOrder.indexOf(_selectedDay);
    if (currentIndex < dayOrder.length - 1) {
      setState(() {
        _selectedDay = dayOrder[currentIndex + 1];
      });
    } else {
      setState(() {
        _selectedDay = dayOrder.first; // Go to Sunday
      });
    }
  }

  void _loadSchedule() {
    if (_mounted) {
      if (widget.type == ScheduleType.student) {
        // For students, we need sectionId from user entity
        final sectionId = widget.user.entity?['section']?['id'];
        if (sectionId != null) {
          context.read<ScheduleCubit>().getStudentSchedule(
            sectionId: sectionId,
          );
        }
      } else {
        // For teachers, use user pk as teacherId
        context.read<ScheduleCubit>().getTeacherSchedule(
          teacherId: widget.user.pk,
        );
      }
    }
  }

  void _onDaySelected(String day) {
    if (_mounted) {
      setState(() {
        _selectedDay = day;
      });
    }
  }

  List<String> _getAvailableDays(List<dynamic> schedules) {
    final days = <String>{};
    for (final schedule in schedules) {
      days.add(schedule.day);
    }
    return days.toList()..sort((a, b) {
      const dayOrder = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
      return dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b));
    });
  }

  List<dynamic> _getSchedulesForDay(List<dynamic> schedules, String day) {
    return schedules.where((schedule) => schedule.day == day).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSchedule),
        ],
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ScheduleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading schedule',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadSchedule,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ScheduleLoaded) {
            final schedules = state.schedules;

            if (schedules.isEmpty) {
              return EmptySchedule(
                studentName: widget.type == ScheduleType.student
                    ? 'Student'
                    : 'Teacher',
                onRefresh: _loadSchedule,
              );
            }

            final availableDays = _getAvailableDays(schedules);

            // If no day is selected or selected day is not available, select first available day
            if (_selectedDay.isEmpty || !availableDays.contains(_selectedDay)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_mounted && availableDays.isNotEmpty) {
                  _onDaySelected(availableDays.first);
                }
              });
            }

            final daySchedules = _getSchedulesForDay(schedules, _selectedDay);

            return Column(
              children: [
                // Day selector with navigation arrows
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // Previous day button
                      IconButton(
                        onPressed: _goToPreviousDay,
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          foregroundColor: theme.primaryColor,
                        ),
                      ),

                      // Day selector
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableDays.length,
                          itemBuilder: (context, index) {
                            final day = availableDays[index];
                            final isSelected = day == _selectedDay;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: GestureDetector(
                                onTap: () => _onDaySelected(day),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _getDayColor(day)
                                        : theme.cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? _getDayColor(day)
                                          : theme.dividerColor,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getDayDisplayName(day),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : theme.textTheme.bodyMedium?.color,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Next day button
                      IconButton(
                        onPressed: _goToNextDay,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.primaryColor.withOpacity(0.1),
                          foregroundColor: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Schedule info
                if (state.sectionInfo.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.sectionInfo,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 16),

                // Schedule list
                Expanded(
                  child: daySchedules.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 64,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No classes scheduled for ${_getDayDisplayName(_selectedDay)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: daySchedules.length,
                          itemBuilder: (context, index) {
                            final schedule = daySchedules[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: ScheduleCard(
                                schedule: schedule,
                                isLast: index == daySchedules.length - 1,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const Center(child: Text('No schedule data available'));
        },
      ),
    );
  }
}
