import 'package:flutter/material.dart';
import '../../../data/model/attendance_model.dart';
import '../../../data/repo/attendance_repo.dart';

class LocalDataScreen extends StatefulWidget {
  final AttendanceRepo attendanceRepo;

  const LocalDataScreen({Key? key, required this.attendanceRepo})
    : super(key: key);

  @override
  _LocalDataScreenState createState() => _LocalDataScreenState();
}

class _LocalDataScreenState extends State<LocalDataScreen> {
  List<AttendanceModel> pendingRecords = [];
  List<AttendanceModel> syncedRecords = [];
  List<AttendanceModel> failedRecords = [];
  bool isLoading = true;
  Map<String, int> syncStats = {};

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => isLoading = true);

    try {
      pendingRecords = await widget.attendanceRepo.getPendingRecords();
      syncedRecords = await widget.attendanceRepo
          .getFailedRecords(); // This should be synced records
      failedRecords = await widget.attendanceRepo.getFailedRecords();
      syncStats = await widget.attendanceRepo.getSyncStatistics();
    } catch (e) {
      print('Error loading records: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading records: $e')));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Attendance Data'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: () => _manualSync()),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadRecords(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Sync status summary
                _buildSyncStatusCard(),
                SizedBox(height: 16),

                // Records list
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).primaryColor,
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.schedule, size: 16),
                                  SizedBox(width: 4),
                                  Text('Pending (${pendingRecords.length})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 16),
                                  SizedBox(width: 4),
                                  Text('Synced (${syncStats['synced'] ?? 0})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, size: 16),
                                  SizedBox(width: 4),
                                  Text('Failed (${failedRecords.length})'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildRecordsList(pendingRecords, 'pending'),
                              _buildRecordsList(syncedRecords, 'synced'),
                              _buildRecordsList(failedRecords, 'failed'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSyncStatusCard() {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sync Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(
                  _getSyncStatusIcon(),
                  color: _getSyncStatusColor(),
                  size: 32,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  'Pending',
                  syncStats['pending'] ?? 0,
                  Colors.orange,
                  Icons.schedule,
                ),
                _buildStatusItem(
                  'Synced',
                  syncStats['synced'] ?? 0,
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatusItem(
                  'Failed',
                  syncStats['failed'] ?? 0,
                  Colors.red,
                  Icons.error,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _manualSync,
                  icon: Icon(Icons.sync),
                  label: Text('Sync Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _loadRecords,
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildRecordsList(List<AttendanceModel> records, String status) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getEmptyIcon(status), size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'No $status records',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _getEmptyMessage(status),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(record.syncStatus ?? status),
              child: Icon(
                _getStatusIcon(record.syncStatus ?? status),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              record.studentName,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text('Date: ${record.date.toIso8601String().split('T')[0]}'),
                if (record.note.isNotEmpty) Text('Note: ${record.note}'),
                if (record.syncStatus == 'failed' &&
                    record.errorMessage != null)
                  Text(
                    'Error: ${record.errorMessage}',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                if (record.retryCount != null && record.retryCount! > 0)
                  Text(
                    'Retry attempts: ${record.retryCount}/3',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                if (record.localTimestamp != null)
                  Text(
                    'Created: ${_formatDateTime(record.localTimestamp!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            trailing: status == 'failed'
                ? IconButton(
                    icon: Icon(Icons.refresh, color: Colors.orange),
                    onPressed: () => _retrySync(record),
                    tooltip: 'Retry sync',
                  )
                : null,
            isThreeLine: true,
          ),
        );
      },
    );
  }

  IconData _getEmptyIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'synced':
        return Icons.check_circle_outline;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.inbox;
    }
  }

  String _getEmptyMessage(String status) {
    switch (status) {
      case 'pending':
        return 'No records waiting to sync';
      case 'synced':
        return 'No successfully synced records';
      case 'failed':
        return 'No failed sync records';
      default:
        return 'No records found';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'synced':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'synced':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSyncStatusIcon() {
    if (syncStats['failed']! > 0) return Icons.error;
    if (syncStats['pending']! > 0) return Icons.schedule;
    return Icons.check_circle;
  }

  Color _getSyncStatusColor() {
    if (syncStats['failed']! > 0) return Colors.red;
    if (syncStats['pending']! > 0) return Colors.orange;
    return Colors.green;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _manualSync() async {
    setState(() => isLoading = true);

    try {
      await widget.attendanceRepo.syncPendingRecords();
      await _loadRecords();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync completed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: $e'), backgroundColor: Colors.red),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> _retrySync(AttendanceModel record) async {
    try {
      await widget.attendanceRepo.retryFailedRecord(record);
      await _loadRecords();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${record.studentName} synced successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Retry failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
