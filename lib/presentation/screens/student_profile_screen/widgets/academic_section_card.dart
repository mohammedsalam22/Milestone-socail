import 'package:flutter/material.dart';
import '../../../../data/model/user_model.dart';
import '../../attendance_screen/widgets/student_attendance_view.dart';
import '../../incidents_screen/widgets/student_incidents_view.dart';
import '../../marks_screen/widgets/student_marks_view.dart';
import '../../schedule_screen/widgets/student_schedule_view.dart';

class AcademicSectionCard extends StatelessWidget {
  final UserModel user;

  const AcademicSectionCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        user.academicInfo,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Academic Options
            _buildAcademicOption(
              context,
              'Attendance',
              'View attendance records and history',
              Icons.people_alt_rounded,
              Colors.blue,
              () => _navigateToAttendance(context),
            ),

            const SizedBox(height: 16),

            _buildAcademicOption(
              context,
              'Incidents',
              'View incidents and disciplinary records',
              Icons.report_problem_rounded,
              Colors.orange,
              () => _navigateToIncidents(context),
            ),

            const SizedBox(height: 16),

            _buildAcademicOption(
              context,
              'Marks',
              'View grades and academic performance',
              Icons.grade_rounded,
              Colors.green,
              () => _navigateToMarks(context),
            ),

            const SizedBox(height: 16),

            _buildAcademicOption(
              context,
              'Schedule',
              'View class schedule and timetable',
              Icons.schedule_rounded,
              Colors.purple,
              () => _navigateToSchedule(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
        ),
      ),
    );
  }

  void _navigateToAttendance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentAttendanceView(user: user),
      ),
    );
  }

  void _navigateToIncidents(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentIncidentsView(user: user)),
    );
  }

  void _navigateToMarks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentMarksView(user: user)),
    );
  }

  void _navigateToSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StudentScheduleView(user: user)),
    );
  }
}
