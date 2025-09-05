import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/model/section_model.dart';
import '../../../../data/model/student_model.dart';
import '../../../../data/model/attendance_model.dart';
import '../../../../bloc/sections/sections_cubit.dart';
import '../../../../bloc/students/students_cubit.dart';
import '../../../../bloc/students/students_state.dart';
import '../../../../bloc/attendance/attendance_cubit.dart';
import 'section_selection_bottom_sheet.dart';

class TakeAttendanceBottomSheet extends StatefulWidget {
  final VoidCallback onAttendanceCreated;

  const TakeAttendanceBottomSheet({
    super.key,
    required this.onAttendanceCreated,
  });

  @override
  State<TakeAttendanceBottomSheet> createState() =>
      _TakeAttendanceBottomSheetState();
}

class _TakeAttendanceBottomSheetState extends State<TakeAttendanceBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  SectionModel? _selectedSection;
  final Map<int, AttendanceModel> _attendanceMap = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SectionsCubit>().getSections();
    });
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _onSectionChanged(SectionModel? section) {
    setState(() {
      _selectedSection = section;
      _attendanceMap.clear(); // Clear previous attendance data
    });

    if (section != null) {
      context.read<StudentsCubit>().getStudents(sectionId: section.id);
    }
  }

  void _updateStudentAttendance(
    StudentModel student,
    bool absent,
    bool excused,
    String note,
  ) {
    setState(() {
      _attendanceMap[student.id] = AttendanceModel(
        studentId: student.id,
        studentName: student.fullName,
        date: _selectedDate,
        absent: absent,
        excused: excused,
        note: note,
      );
    });
  }

  Future<void> _submitAttendance() async {
    if (_selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a section'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_attendanceMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please mark attendance for at least one student'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<AttendanceCubit>().createAttendances(
        attendances: _attendanceMap.values.toList(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onAttendanceCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance recorded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.people_alt_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Take Attendance',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Date and Section Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Date selector
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _showDatePicker(),
                    leading: Icon(
                      Icons.calendar_today_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text('Select date'),
                    trailing: const Icon(Icons.arrow_drop_down),
                  ),
                ),

                const SizedBox(height: 12),

                // Section selector
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: () => _showSectionSelection(),
                    leading: Icon(
                      Icons.school_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(
                      _selectedSection?.displayName ?? 'Select Section',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _selectedSection != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    subtitle: _selectedSection != null
                        ? Text(
                            '${_selectedSection!.grade.studyStage.name} - ${_selectedSection!.grade.studyYear.name}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          )
                        : const Text('Choose a section'),
                    trailing: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Students list
          Expanded(child: _buildStudentsList()),

          // Submit button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAttendance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text('Submit (${_attendanceMap.length})'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_selectedSection == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Select a section to view students',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<StudentsCubit, StudentsState>(
      builder: (context, state) {
        if (state is StudentsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StudentsLoaded) {
          if (state.students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No students found in this section',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.students.length,
            itemBuilder: (context, index) {
              final student = state.students[index];
              final attendance = _attendanceMap[student.id];

              return _buildStudentAttendanceCard(student, attendance);
            },
          );
        } else if (state is StudentsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading students',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStudentAttendanceCard(
    StudentModel student,
    AttendanceModel? attendance,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: attendance != null
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.2),
          width: attendance != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    student.fullName.isNotEmpty
                        ? student.fullName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${student.gradeName} - ${student.studyStageName}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (attendance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(attendance).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(attendance),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(attendance),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Attendance options
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceOption(
                    'Present',
                    Icons.check_circle,
                    Colors.green,
                    attendance?.absent == false,
                    () => _updateStudentAttendance(
                      student,
                      false,
                      false,
                      attendance?.note ?? '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAttendanceOption(
                    'Absent',
                    Icons.cancel,
                    Colors.red,
                    attendance?.absent == true && attendance?.excused == false,
                    () => _updateStudentAttendance(
                      student,
                      true,
                      false,
                      attendance?.note ?? '',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAttendanceOption(
                    'Excused',
                    Icons.schedule,
                    Colors.orange,
                    attendance?.absent == true && attendance?.excused == true,
                    () => _updateStudentAttendance(
                      student,
                      true,
                      true,
                      attendance?.note ?? '',
                    ),
                    isEnabled: attendance?.absent == true,
                  ),
                ),
              ],
            ),

            // Note field - always show for any student
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a note for ${student.fullName}...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                // Get current attendance status or default to present
                final currentAttendance = _attendanceMap[student.id];
                _updateStudentAttendance(
                  student,
                  currentAttendance?.absent ?? false,
                  currentAttendance?.excused ?? false,
                  value,
                );
              },
              controller: TextEditingController(text: attendance?.note ?? ''),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceOption(
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap, {
    bool isEnabled = true,
  }) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? theme.colorScheme.surfaceVariant.withOpacity(0.2)
              : isSelected
              ? color.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDisabled
                ? theme.colorScheme.outline.withOpacity(0.1)
                : isSelected
                ? color
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDisabled
                  ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
                  : isSelected
                  ? color
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDisabled
                    ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
                    : isSelected
                    ? color
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((date) {
      if (date != null) {
        _onDateChanged(date);
      }
    });
  }

  void _showSectionSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SectionSelectionBottomSheet(
        selectedSection: _selectedSection,
        onSectionSelected: _onSectionChanged,
      ),
    );
  }

  Color _getStatusColor(AttendanceModel attendance) {
    if (attendance.absent) {
      return attendance.excused ? Colors.orange : Colors.red;
    }
    return Colors.green;
  }

  String _getStatusText(AttendanceModel attendance) {
    if (attendance.absent) {
      return attendance.excused ? 'Excused' : 'Absent';
    }
    return 'Present';
  }
}
