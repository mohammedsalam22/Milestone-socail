import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/model/user_model.dart';
import '../../../../bloc/schedule/schedule_cubit.dart';
import '../../../../bloc/schedule/schedule_state.dart';
import 'schedule_card.dart';
import 'empty_schedule.dart';

class StudentScheduleView extends StatefulWidget {
  final UserModel user;

  const StudentScheduleView({super.key, required this.user});

  @override
  State<StudentScheduleView> createState() => _StudentScheduleViewState();
}

class _StudentScheduleViewState extends State<StudentScheduleView> {
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
        _loadStudentSchedule();
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

  void _loadStudentSchedule() {
    if (_mounted) {
      if (widget.user.sectionId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Section ID not found. Please contact support.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<ScheduleCubit>().getStudentSchedule(
        sectionId: widget.user.sectionId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '${widget.user.studentFullName} - Schedule',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_mounted) {
                _loadStudentSchedule();
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<ScheduleCubit, ScheduleState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Section Info Header
                if (state is ScheduleLoaded && state.sectionInfo.isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.school_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Academic Schedule',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.sectionInfo,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                // Day Switcher Header
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Previous day button
                      IconButton(
                        onPressed: _goToPreviousDay,
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: _getDayColor(
                            _selectedDay,
                          ).withOpacity(0.1),
                          foregroundColor: _getDayColor(_selectedDay),
                        ),
                        tooltip: 'Previous Day',
                      ),

                      const SizedBox(width: 16),

                      // Day display
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _getDayDisplayName(_selectedDay),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getDayColor(_selectedDay),
                              ),
                            ),
                            Text(
                              'Class Schedule',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Next day button
                      IconButton(
                        onPressed: _goToNextDay,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: _getDayColor(
                            _selectedDay,
                          ).withOpacity(0.1),
                          foregroundColor: _getDayColor(_selectedDay),
                        ),
                        tooltip: 'Next Day',
                      ),
                    ],
                  ),
                ),

                // Schedule Content
                if (state is ScheduleLoading)
                  const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is ScheduleLoaded)
                  _buildScheduleContent(state)
                else if (state is ScheduleError)
                  SizedBox(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (_mounted) {
                                _loadStudentSchedule();
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox(
                    height: 400,
                    child: Center(child: Text('Loading schedule...')),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleContent(ScheduleLoaded state) {
    if (state.schedules.isEmpty) {
      return SizedBox(
        height: 400,
        child: EmptySchedule(
          studentName: widget.user.studentFullName,
          onRefresh: _loadStudentSchedule,
        ),
      );
    }

    // Filter schedules by selected day
    final daySchedules = state.schedules
        .where((schedule) => schedule.day == _selectedDay)
        .toList();

    if (daySchedules.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Classes on ${_getDayDisplayName(_selectedDay)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting a different day',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Day Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _getDayColor(_selectedDay).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getDayColor(_selectedDay).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: _getDayColor(_selectedDay),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getDayDisplayName(_selectedDay),
                  style: TextStyle(
                    color: _getDayColor(_selectedDay),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  '${daySchedules.length} class${daySchedules.length > 1 ? 'es' : ''}',
                  style: TextStyle(
                    color: _getDayColor(_selectedDay).withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Day Schedules
          ...daySchedules.map((schedule) {
            return ScheduleCard(
              schedule: schedule,
              isLast: daySchedules.last == schedule,
            );
          }).toList(),
        ],
      ),
    );
  }
}
