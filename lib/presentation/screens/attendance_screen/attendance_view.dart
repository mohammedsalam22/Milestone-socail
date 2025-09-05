import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/user_model.dart';
import '../../../data/model/section_model.dart';
import '../../../bloc/attendance/attendance_cubit.dart';
import '../../../bloc/attendance/attendance_state.dart';
import '../../../bloc/sections/sections_cubit.dart';
import '../../../generated/l10n.dart';
import '../../../core/utils/role_utils.dart';
import 'widgets/attendance_card.dart';
import 'widgets/empty_attendance.dart';
import 'widgets/section_selection_bottom_sheet.dart';
import 'widgets/take_attendance_bottom_sheet.dart';
import 'widgets/edit_attendance_bottom_sheet.dart';
import 'widgets/delete_attendance_dialog.dart';

class AttendanceView extends StatefulWidget {
  final UserModel user;

  const AttendanceView({super.key, required this.user});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  SectionModel? _selectedSection;
  DateTime _selectedDate = DateTime.now();
  bool _mounted = true;

  bool get _isAdmin => RoleUtils.isAdmin(widget.user.role);

  @override
  void initState() {
    super.initState();
    _mounted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        context.read<SectionsCubit>().getSections();
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _onSectionChanged(SectionModel? section) {
    if (!_mounted) return;
    setState(() {
      _selectedSection = section;
    });
    if (_mounted && section != null) {
      context.read<AttendanceCubit>().getAttendances(
        sectionId: section.id,
        date: _selectedDate,
      );
    }
  }

  void _onDateChanged(DateTime date) {
    if (!_mounted) return;
    setState(() {
      _selectedDate = date;
    });
    if (_mounted && _selectedSection != null) {
      context.read<AttendanceCubit>().getAttendances(
        sectionId: _selectedSection!.id,
        date: _selectedDate,
      );
    }
  }

  void _showSectionSelection() {
    if (!_mounted) return;
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

  void _showDatePicker() {
    if (!_mounted) return;
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

  void _takeAttendance() {
    if (!_mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TakeAttendanceBottomSheet(
        onAttendanceCreated: () {
          if (_mounted && _selectedSection != null) {
            context.read<AttendanceCubit>().refreshAttendances(
              sectionId: _selectedSection!.id,
              date: _selectedDate,
            );
          }
        },
      ),
    );
  }

  void _exportAttendance() {
    if (!_mounted) return;
    // TODO: Implement export attendance functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export attendance feature coming soon!')),
    );
  }

  void _editAttendance(attendance) {
    if (!_mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditAttendanceBottomSheet(
        attendance: attendance,
        onAttendanceUpdated: () {
          if (_mounted && _selectedSection != null) {
            context.read<AttendanceCubit>().refreshAttendances(
              sectionId: _selectedSection!.id,
              date: _selectedDate,
            );
          }
        },
      ),
    );
  }

  void _deleteAttendance(attendance) {
    if (!_mounted) return;
    showDialog(
      context: context,
      builder: (context) => DeleteAttendanceDialog(
        attendance: attendance,
        onAttendanceDeleted: () {
          if (_mounted && _selectedSection != null) {
            context.read<AttendanceCubit>().refreshAttendances(
              sectionId: _selectedSection!.id,
              date: _selectedDate,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          S.of(context).attendance,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          if (_isAdmin)
            IconButton(
              onPressed: _takeAttendance,
              icon: const Icon(Icons.add),
              tooltip: S.of(context).takeAttendance,
            ),
          IconButton(
            onPressed: _exportAttendance,
            icon: const Icon(Icons.download),
            tooltip: S.of(context).exportAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Section selector
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: _showSectionSelection,
                    leading: Icon(
                      Icons.school_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      _selectedSection?.displayName ?? 'Select Section',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _selectedSection != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                    subtitle: _selectedSection != null
                        ? Text(
                            '${_selectedSection!.grade.studyStage.name} - ${_selectedSection!.grade.studyYear.name}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          )
                        : const Text(
                            'Choose a section to view attendance',
                            style: TextStyle(fontSize: 12),
                          ),
                    trailing: const Icon(Icons.arrow_drop_down),
                  ),
                ),

                const SizedBox(height: 12),

                // Date selector
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    onTap: _showDatePicker,
                    leading: Icon(
                      Icons.calendar_today_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text(
                      'Select date to view attendance',
                      style: TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                  ),
                ),
              ],
            ),
          ),

          // Attendance list
          Expanded(
            child: BlocBuilder<AttendanceCubit, AttendanceState>(
              builder: (context, state) {
                if (state is AttendanceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AttendanceLoaded) {
                  if (state.attendances.isEmpty) {
                    return EmptyAttendance(onTakeAttendance: _takeAttendance);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_mounted && _selectedSection != null) {
                        context.read<AttendanceCubit>().refreshAttendances(
                          sectionId: _selectedSection!.id,
                          date: _selectedDate,
                        );
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.attendances.length,
                      itemBuilder: (context, index) {
                        final attendance = state.attendances[index];
                        return AttendanceCard(
                          attendance: attendance,
                          onEdit: () => _editAttendance(attendance),
                          onDelete: () => _deleteAttendance(attendance),
                        );
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
                          'Error loading attendance',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_mounted && _selectedSection != null) {
                              context
                                  .read<AttendanceCubit>()
                                  .refreshAttendances(
                                    sectionId: _selectedSection!.id,
                                    date: _selectedDate,
                                  );
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('Select a section and date to view attendance'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
