import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/user_model.dart';
import '../../../../data/model/mark_model.dart';
import '../../../../bloc/marks/marks_cubit.dart';
import '../../../../bloc/marks/marks_state.dart';
import 'marks_data_table.dart';
import 'empty_student_marks.dart';

class StudentMarksView extends StatefulWidget {
  final UserModel user;

  const StudentMarksView({super.key, required this.user});

  @override
  State<StudentMarksView> createState() => _StudentMarksViewState();
}

class _StudentMarksViewState extends State<StudentMarksView> {
  bool _mounted = true;
  late DateTime _selectedMonth;
  bool _showDataTable = true; // Toggle between card view and data table

  @override
  void initState() {
    super.initState();
    _mounted = true;
    // Start with current month
    _selectedMonth = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        _loadStudentMarks();
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _loadStudentMarks() {
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
      context.read<MarksCubit>().getStudentMarks(
        studentId: widget.user.studentId,
      );
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadStudentMarks();
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
      _loadStudentMarks();
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

  List<MarkModel> _filterMarksByMonth(List<MarkModel> marks) {
    return marks.where((mark) {
      return mark.date.year == _selectedMonth.year &&
          mark.date.month == _selectedMonth.month;
    }).toList();
  }

  Widget _buildMarksContent(MarksLoaded state) {
    // Filter marks by selected month
    final filteredMarks = _filterMarksByMonth(state.marks);

    if (filteredMarks.isEmpty) {
      return SizedBox(
        height: 400,
        child: EmptyStudentMarks(
          studentName: widget.user.studentFullName,
          onRefresh: _loadStudentMarks,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: _showDataTable
          ? MarksDataTable(
              marks: filteredMarks,
              studentName: widget.user.studentFullName,
            )
          : Column(
              children: filteredMarks.map((mark) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: mark.gradeColor.withOpacity(0.1),
                      child: Text(
                        mark.grade,
                        style: TextStyle(
                          color: mark.gradeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      mark.subjectName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${mark.examType.displayName} • ${DateFormat('MMM dd, yyyy').format(mark.date)}',
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${mark.mark}/${mark.topMark} (${mark.percentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: mark.isPassed
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              mark.isPassed ? Icons.check_circle : Icons.cancel,
                              color: mark.isPassed ? Colors.green : Colors.red,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '${widget.user.studentFullName} - Marks',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_showDataTable ? Icons.view_list : Icons.table_chart),
            onPressed: () {
              setState(() {
                _showDataTable = !_showDataTable;
              });
            },
            tooltip: _showDataTable
                ? 'Switch to Card View'
                : 'Switch to Data Table',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_mounted) {
                _loadStudentMarks();
              }
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocBuilder<MarksCubit, MarksState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
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
                        onPressed: _canGoToPreviousMonth
                            ? _goToPreviousMonth
                            : null,
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
                              'Academic Marks',
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

                // Marks content
                if (state is MarksLoading)
                  const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is MarksLoaded)
                  _buildMarksContent(state)
                else if (state is MarksError)
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
                                _loadStudentMarks();
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
                    child: Center(child: Text('Loading marks...')),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
