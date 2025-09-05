import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/model/attendance_model.dart';
import '../../../../bloc/attendance/attendance_cubit.dart';

class EditAttendanceBottomSheet extends StatefulWidget {
  final AttendanceModel attendance;
  final VoidCallback onAttendanceUpdated;

  const EditAttendanceBottomSheet({
    super.key,
    required this.attendance,
    required this.onAttendanceUpdated,
  });

  @override
  State<EditAttendanceBottomSheet> createState() =>
      _EditAttendanceBottomSheetState();
}

class _EditAttendanceBottomSheetState extends State<EditAttendanceBottomSheet> {
  late bool _absent;
  late bool _excused;
  late TextEditingController _noteController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _absent = widget.attendance.absent;
    _excused = widget.attendance.excused;
    _noteController = TextEditingController(text: widget.attendance.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateAttendance() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      await context.read<AttendanceCubit>().updateAttendance(
        studentId: widget.attendance.studentId,
        date: widget.attendance.date,
        absent: _absent,
        excused: _excused,
        note: _noteController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onAttendanceUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance updated successfully!'),
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
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  Icons.edit_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Attendance',
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

          // Student info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      widget.attendance.studentName.isNotEmpty
                          ? widget.attendance.studentName[0].toUpperCase()
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
                          widget.attendance.studentName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Student ID: ${widget.attendance.studentId}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Attendance status options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Status',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Present option
                _buildStatusOption(
                  'Present',
                  Icons.check_circle,
                  Colors.green,
                  !_absent,
                  () => setState(() {
                    _absent = false;
                    _excused = false;
                  }),
                ),

                const SizedBox(height: 8),

                // Absent option
                _buildStatusOption(
                  'Absent (Unexcused)',
                  Icons.cancel,
                  Colors.red,
                  _absent && !_excused,
                  () => setState(() {
                    _absent = true;
                    _excused = false;
                  }),
                ),

                const SizedBox(height: 8),

                // Excused option
                _buildStatusOption(
                  'Absent (Excused)',
                  Icons.schedule,
                  Colors.orange,
                  _absent && _excused,
                  () => setState(() {
                    _absent = true;
                    _excused = true;
                  }),
                  isEnabled: _absent,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Note field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
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
                    onPressed: _isSubmitting ? null : _updateAttendance,
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
                        : const Text('Update Attendance'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled
              ? theme.colorScheme.surfaceVariant.withOpacity(0.2)
              : isSelected
              ? color.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
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
          children: [
            Icon(
              icon,
              size: 20,
              color: isDisabled
                  ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
                  : isSelected
                  ? color
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDisabled
                    ? theme.colorScheme.onSurfaceVariant.withOpacity(0.4)
                    : isSelected
                    ? color
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
