import 'package:flutter/material.dart';
import '../../../../data/model/user_model.dart';
import 'package:intl/intl.dart';

class StudentInfoCard extends StatelessWidget {
  final UserModel user;

  const StudentInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentCard = user.studentCard;

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
          children: [
            // Student Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user.studentName.isNotEmpty
                      ? user.studentName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Student Name
            Text(
              user.studentFullName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Student ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'ID: ${user.studentId}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Academic Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildAcademicInfo(
                    context,
                    Icons.school_rounded,
                    'Section',
                    user.sectionDisplayName,
                  ),
                  const SizedBox(height: 8),
                  _buildAcademicInfo(
                    context,
                    Icons.grade_rounded,
                    'Grade',
                    user.gradeInfo?['name'] ?? 'Unknown',
                  ),
                  const SizedBox(height: 8),
                  _buildAcademicInfo(
                    context,
                    Icons.category_rounded,
                    'Study Stage',
                    user.studyStageInfo?['name'] ?? 'Unknown',
                  ),
                  const SizedBox(height: 8),
                  _buildAcademicInfo(
                    context,
                    Icons.calendar_today_rounded,
                    'Study Year',
                    user.studyYearInfo?['name'] ?? 'Unknown',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Full Info Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showFullInfoBottomSheet(context),
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('Full Information'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Student Details
            if (studentCard != null) ...[
              _buildInfoRow(
                context,
                Icons.person_rounded,
                'Gender',
                _capitalizeFirst(studentCard['gender'] ?? 'Unknown'),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.cake_rounded,
                'Birth Date',
                _formatDate(studentCard['birth_date']),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.flag_rounded,
                'Nationality',
                studentCard['nationality'] ?? 'Unknown',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.location_city_rounded,
                'Birth City',
                studentCard['birth_city'] ?? 'Unknown',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.phone_rounded,
                'Phone',
                studentCard['phone'] ?? 'Unknown',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                context,
                Icons.location_on_rounded,
                'Address',
                studentCard['address'] ?? 'Unknown',
                isMultiline: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isMultiline = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Widget _buildAcademicInfo(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showFullInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FullInfoBottomSheet(user: user),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

class _FullInfoBottomSheet extends StatelessWidget {
  final UserModel user;

  const _FullInfoBottomSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentCard = user.studentCard;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_rounded,
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
                        'Full Student Information',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.studentFullName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information
                  _buildSection(
                    context,
                    'Personal Information',
                    Icons.person_rounded,
                    [
                      _buildInfoItem('Full Name', user.studentFullName),
                      _buildInfoItem('Student ID', user.studentId.toString()),
                      _buildInfoItem(
                        'Gender',
                        _capitalizeFirst(studentCard?['gender'] ?? 'Unknown'),
                      ),
                      _buildInfoItem(
                        'Birth Date',
                        _formatDate(studentCard?['birth_date']),
                      ),
                      _buildInfoItem(
                        'Birth City',
                        studentCard?['birth_city'] ?? 'Unknown',
                      ),
                      _buildInfoItem(
                        'Nationality',
                        studentCard?['nationality'] ?? 'Unknown',
                      ),
                      _buildInfoItem(
                        'National Number',
                        studentCard?['national_no'] ?? 'Unknown',
                      ),
                      _buildInfoItem(
                        'Phone',
                        studentCard?['phone'] ?? 'Unknown',
                      ),
                      _buildInfoItem(
                        'Address',
                        studentCard?['address'] ?? 'Unknown',
                      ),
                      _buildInfoItem(
                        'Place of Register',
                        studentCard?['place_of_register'] ?? 'Unknown',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Academic Information
                  _buildSection(
                    context,
                    'Academic Information',
                    Icons.school_rounded,
                    [
                      _buildInfoItem('Section', user.sectionDisplayName),
                      _buildInfoItem(
                        'Grade',
                        user.gradeInfo?['name'] ?? 'Unknown',
                      ),
                      _buildInfoItem(
                        'Study Stage',
                        user.studyStageInfo?['name'] ?? 'Unknown',
                      ),
                      _buildInfoItem(
                        'Study Year',
                        user.studyYearInfo?['name'] ?? 'Unknown',
                      ),
                      _buildInfoItem('Section ID', user.sectionId.toString()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Account Information
                  _buildSection(
                    context,
                    'Account Information',
                    Icons.account_circle_rounded,
                    [
                      _buildInfoItem('Username', user.username),
                      _buildInfoItem(
                        'Email',
                        user.email.isNotEmpty ? user.email : 'Not provided',
                      ),
                      _buildInfoItem('User ID', user.pk.toString()),
                      _buildInfoItem(
                        'Role',
                        user.role.isNotEmpty ? user.role : 'Student',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
