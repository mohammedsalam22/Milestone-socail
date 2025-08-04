import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';
import '../../../generated/l10n.dart';
import '../../../core/utils/role_utils.dart';

class AttendanceView extends StatefulWidget {
  final UserModel user;

  const AttendanceView({super.key, required this.user});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  final List<Map<String, dynamic>> _students = [
    {
      'id': 1,
      'name': 'Ahmed Ali',
      'grade': 'Grade 3',
      'status': 'Present',
      'lastUpdated': 'Today, 9:00 AM',
    },
    {
      'id': 2,
      'name': 'Fatima Hassan',
      'grade': 'Grade 3',
      'status': 'Present',
      'lastUpdated': 'Today, 9:00 AM',
    },
    {
      'id': 3,
      'name': 'Omar Khalil',
      'grade': 'Grade 3',
      'status': 'Absent',
      'lastUpdated': 'Today, 9:00 AM',
    },
    {
      'id': 4,
      'name': 'Layla Mahmoud',
      'grade': 'Grade 3',
      'status': 'Late',
      'lastUpdated': 'Today, 9:15 AM',
    },
    {
      'id': 5,
      'name': 'Youssef Ibrahim',
      'grade': 'Grade 3',
      'status': 'Present',
      'lastUpdated': 'Today, 9:00 AM',
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Present', 'Absent', 'Late'];

  bool get _isAdmin => RoleUtils.isAdmin(widget.user.role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(S.of(context).attendance),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions.map((option) {
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      _getFilterIcon(option),
                      color: _getFilterColor(option),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _students.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                _buildSummaryCards(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _getFilteredStudents().length,
                    itemBuilder: (context, index) {
                      final student = _getFilteredStudents()[index];
                      return _buildStudentCard(student);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            S.of(context).noStudentsFound,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            S.of(context).checkBackLater,
            style: TextStyle(color: Colors.grey[500]!, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final presentCount = _students
        .where((s) => s['status'] == 'Present')
        .length;
    final absentCount = _students.where((s) => s['status'] == 'Absent').length;
    final lateCount = _students.where((s) => s['status'] == 'Late').length;
    final totalCount = _students.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Present',
              presentCount.toString(),
              totalCount.toString(),
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Absent',
              absentCount.toString(),
              totalCount.toString(),
              Colors.red,
              Icons.cancel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Late',
              lateCount.toString(),
              totalCount.toString(),
              Colors.orange,
              Icons.schedule,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String count,
    String total,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]!)),
          Text(
            'of $total',
            style: TextStyle(fontSize: 10, color: Colors.grey[500]!),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: _getStatusColor(student['status']),
          child: Text(
            student['name'][0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        title: Text(
          student['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              student['grade'],
              style: TextStyle(color: Colors.grey[600]!, fontSize: 14),
            ),
            Text(
              student['lastUpdated'],
              style: TextStyle(color: Colors.grey[500]!, fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(student['status']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getStatusColor(student['status'])),
          ),
          child: Text(
            student['status'],
            style: TextStyle(
              color: _getStatusColor(student['status']),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: _isAdmin ? () => _updateStudentStatus(student) : null,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Present':
        return Icons.check_circle;
      case 'Absent':
        return Icons.cancel;
      case 'Late':
        return Icons.schedule;
      default:
        return Icons.all_inclusive;
    }
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case 'Present':
        return Colors.green;
      case 'Absent':
        return Colors.red;
      case 'Late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    if (_selectedFilter == 'All') {
      return _students;
    }
    return _students
        .where((student) => student['status'] == _selectedFilter)
        .toList();
  }

  void _takeAttendance() {
    // TODO: Implement take attendance functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).takeAttendance + ' feature coming soon!'),
      ),
    );
  }

  void _exportAttendance() {
    // TODO: Implement export attendance functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).exportAttendance + ' feature coming soon!'),
      ),
    );
  }

  void _updateStudentStatus(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${student['name']}\'s Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Present'),
              onTap: () {
                setState(() {
                  student['status'] = 'Present';
                  student['lastUpdated'] =
                      'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} AM';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).attendanceRecordedSuccessfully),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Absent'),
              onTap: () {
                setState(() {
                  student['status'] = 'Absent';
                  student['lastUpdated'] =
                      'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} AM';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).attendanceRecordedSuccessfully),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text('Late'),
              onTap: () {
                setState(() {
                  student['status'] = 'Late';
                  student['lastUpdated'] =
                      'Today, ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} AM';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).attendanceRecordedSuccessfully),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
