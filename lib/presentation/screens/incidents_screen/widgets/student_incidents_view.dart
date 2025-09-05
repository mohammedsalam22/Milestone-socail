import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../data/model/user_model.dart';
import '../../../../data/model/incident_model.dart';
import '../../../../bloc/incidents/incidents_cubit.dart';
import '../../../../bloc/incidents/incidents_state.dart';
import 'student_incident_card.dart';
import 'empty_student_incidents.dart';

class StudentIncidentsView extends StatefulWidget {
  final UserModel user;

  const StudentIncidentsView({super.key, required this.user});

  @override
  State<StudentIncidentsView> createState() => _StudentIncidentsViewState();
}

class _StudentIncidentsViewState extends State<StudentIncidentsView> {
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
        _loadStudentIncidents();
      }
    });
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _loadStudentIncidents() {
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
      context.read<IncidentsCubit>().getStudentIncidents(
        studentId: widget.user.studentId,
      );
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadStudentIncidents();
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
      _loadStudentIncidents();
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

  List<IncidentModel> _filterIncidentsByMonth(List<IncidentModel> incidents) {
    return incidents.where((incident) {
      return incident.date.year == _selectedMonth.year &&
          incident.date.month == _selectedMonth.month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '${widget.user.studentFullName} - Incidents',
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
                _loadStudentIncidents();
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
                        'Incident Records',
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

          // Incidents content
          Expanded(
            child: BlocBuilder<IncidentsCubit, IncidentsState>(
              builder: (context, state) {
                if (state is IncidentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is IncidentsLoaded) {
                  // Filter incidents by selected month
                  final filteredIncidents = _filterIncidentsByMonth(
                    state.incidents,
                  );

                  if (filteredIncidents.isEmpty) {
                    return EmptyStudentIncidents(
                      studentName: widget.user.studentFullName,
                      onRefresh: _loadStudentIncidents,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_mounted) {
                        _loadStudentIncidents();
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemCount: filteredIncidents.length,
                      itemBuilder: (context, index) {
                        final incident = filteredIncidents[index];
                        return StudentIncidentCard(
                          incident: incident,
                          isLast: index == filteredIncidents.length - 1,
                        );
                      },
                    ),
                  );
                } else if (state is IncidentsError) {
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
                              _loadStudentIncidents();
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('Loading incident records...'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
