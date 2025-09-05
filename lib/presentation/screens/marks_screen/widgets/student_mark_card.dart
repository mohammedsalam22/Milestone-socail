import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/mark_model.dart';

class StudentMarkCard extends StatelessWidget {
  final MarkModel mark;
  final bool isLast;

  const StudentMarkCard({super.key, required this.mark, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16, left: 16, right: 16),
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
          // Header with subject and date
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: mark.gradeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mark.subjectName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: mark.gradeColor,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(mark.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: mark.gradeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: mark.gradeColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    mark.grade,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: mark.gradeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.grey.withOpacity(0.2)),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mark details
                _buildMarkSection(
                  context,
                  'Mark Obtained',
                  Icons.grade_rounded,
                  Colors.blue,
                  '${mark.mark}/${mark.topMark}',
                  '${mark.percentage.toStringAsFixed(1)}%',
                ),

                const SizedBox(height: 16),

                _buildMarkSection(
                  context,
                  'Exam Type',
                  Icons.quiz_rounded,
                  Colors.purple,
                  mark.examType.displayName,
                  '',
                ),

                const SizedBox(height: 16),

                _buildMarkSection(
                  context,
                  'Pass Mark',
                  Icons.check_circle_rounded,
                  mark.isPassed ? Colors.green : Colors.red,
                  '${mark.passMark}',
                  mark.isPassed ? 'Passed' : 'Failed',
                ),

                const SizedBox(height: 16),

                // Performance indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mark.isPassed
                        ? Colors.green.withOpacity(0.05)
                        : Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: mark.isPassed
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        mark.isPassed
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: mark.isPassed ? Colors.green : Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mark.isPassed
                                  ? 'Excellent Performance!'
                                  : 'Needs Improvement',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: mark.isPassed
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              mark.isPassed
                                  ? 'You have successfully passed this assessment.'
                                  : 'Please work harder to improve your performance.',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String value,
    String subtitle,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (subtitle.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
