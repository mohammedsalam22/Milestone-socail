import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/user_model.dart';
import '../../../../data/model/attendance_model.dart';
import '../../../../bloc/attendance/attendance_cubit.dart';
import '../../../../bloc/attendance/attendance_state.dart';
import 'student_attendance_card.dart';
import 'empty_student_attendance.dart';

class StudentAttendanceView extends StatefulWidget {
  final UserModel user;

  const StudentAttendanceView({super.key, required this.user});

  @override
  State<StudentAttendanceView> createState() => _StudentAttendanceViewState();
}

class _StudentAttendanceViewState extends State<StudentAttendanceView> {
  bool _mounted = true;
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _mounted = true;
    // Start with current month
    _selectedMonth = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        _loadStudentAttendance();
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _loadStudentAttendance() {
    if (_mounted) {
      if (widget.user.studentId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Error: Student ID not found. Please contact support.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      context.read<AttendanceCubit>().getStudentAttendances(
        studentId: widget.user.studentId,
      );
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadStudentAttendance();
  }

  void _goToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);

    // Don't allow going beyond current month
    if (nextMonth.year < now.year ||
        (nextMonth.year == now.year && nextMonth.month <= now.month)) {
      setState(() {
        _selectedMonth = nextMonth;
      });
      _loadStudentAttendance();
    }
  }

  bool get _canGoToPreviousMonth {
    final firstMonthOfYear = DateTime(_selectedMonth.year, 1);
    return _selectedMonth.isAfter(firstMonthOfYear);
  }

  bool get _canGoToNextMonth {
    final now = DateTime.now();
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    return nextMonth.year < now.year ||
        (nextMonth.year == now.year && nextMonth.month <= now.month);
  }

  List<AttendanceModel> _filterAttendancesByMonth(
    List<AttendanceModel> attendances,
  ) {
    return attendances.where((attendance) {
      return attendance.date.year == _selectedMonth.year &&
          attendance.date.month == _selectedMonth.month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '${widget.user.studentFullName} - Attendance',
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
                _loadStudentAttendance();
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Previous month button
                IconButton(
                  onPressed: _canGoToPreviousMonth ? _goToPreviousMonth : null,
                  icon: const Icon(Icons.chevron_left),
                  style: IconButton.styleFrom(
                    backgroundColor: _canGoToPreviousMonth
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    foregroundColor: _canGoToPreviousMonth
                        ? theme.colorScheme.primary
                        : Colors.grey,
                  ),
                  tooltip: 'Previous Month',
                ),

                const SizedBox(width: 16),

                // Month display
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Attendance Records',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Next month button
                IconButton(
                  onPressed: _canGoToNextMonth ? _goToNextMonth : null,
                  icon: const Icon(Icons.chevron_right),
                  style: IconButton.styleFrom(
                    backgroundColor: _canGoToNextMonth
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    foregroundColor: _canGoToNextMonth
                        ? theme.colorScheme.primary
                        : Colors.grey,
                  ),
                  tooltip: 'Next Month',
                ),
              ],
            ),
          ),

          // Attendance content
          Expanded(
            child: BlocBuilder<AttendanceCubit, AttendanceState>(
              builder: (context, state) {
                if (state is AttendanceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AttendanceLoaded) {
                  // Filter attendances by selected month
                  final filteredAttendances = _filterAttendancesByMonth(
                    state.attendances,
                  );

                  if (filteredAttendances.isEmpty) {
                    return EmptyStudentAttendance(
                      studentName: widget.user.studentFullName,
                      onRefresh: _loadStudentAttendance,
                    );
                  }

                  // Group filtered attendances by month for better organization
                  final groupedAttendances = _groupAttendancesByMonth(
                    filteredAttendances,
                  );

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_mounted) {
                        _loadStudentAttendance();
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: groupedAttendances.length,
                      itemBuilder: (context, index) {
                        final monthData = groupedAttendances[index];
                        return _buildMonthSection(theme, monthData);
                      },
                    ),
                  );
                } else if (state is AttendanceError) {
                  return Center(
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
                              _loadStudentAttendance();
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('Loading attendance records...'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(ThemeData theme, Map<String, dynamic> monthData) {
    final String month = monthData['month'];
    final List<AttendanceModel> attendances = monthData['attendances'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Text(
              month,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),

          // Attendance records
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: attendances.length,
            itemBuilder: (context, index) {
              final attendance = attendances[index];
              return StudentAttendanceCard(
                attendance: attendance,
                isLast: index == attendances.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupAttendancesByMonth(
    List<AttendanceModel> attendances,
  ) {
    final Map<String, List<AttendanceModel>> grouped = {};

    for (final attendance in attendances) {
      final monthKey = DateFormat('MMMM yyyy').format(attendance.date);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(attendance);
    }

    // Sort months in descending order (newest first)
    final sortedMonths = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return sortedMonths
        .map(
          (month) => {
            'month': month,
            'attendances': grouped[month]!
              ..sort((a, b) => b.date.compareTo(a.date)),
          },
        )
        .toList();
  }
}
