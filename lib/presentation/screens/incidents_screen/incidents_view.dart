import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/incidents/incidents_cubit.dart';
import '../../../bloc/incidents/incidents_state.dart';
import '../../../bloc/students/students_cubit.dart';
import '../../../bloc/students/students_state.dart';
import '../../../bloc/sections/sections_cubit.dart';
import '../../../bloc/sections/sections_state.dart';
import '../../../data/model/user_model.dart';
import '../../../data/model/section_model.dart';
import 'widgets/incident_card.dart';
import 'widgets/create_incident_bottom_sheet.dart';
import 'widgets/empty_incidents.dart';
import 'widgets/incidents_skeleton.dart';

class IncidentsView extends StatefulWidget {
  final UserModel user;

  const IncidentsView({super.key, required this.user});

  @override
  State<IncidentsView> createState() => _IncidentsViewState();
}

class _IncidentsViewState extends State<IncidentsView> {
  SectionModel? _selectedSection;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _mounted = true;

    // Use the existing BlocProvider from main.dart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        // Load sections
        context.read<SectionsCubit>().getSections();

        // Load students
        context.read<StudentsCubit>().getAllStudents();

        // Load incidents
        context.read<IncidentsCubit>().getIncidents();
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

    // Filter incidents by section
    if (_mounted) {
      final incidentsCubit = context.read<IncidentsCubit>();
      if (section != null) {
        incidentsCubit.getIncidents(sectionId: section.id);
      } else {
        incidentsCubit.getIncidents();
      }
    }
  }

  void _showCreateIncident() {
    if (!_mounted) return;

    final studentsCubit = context.read<StudentsCubit>();
    final sectionsCubit = context.read<SectionsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateIncidentBottomSheet(
        students: studentsCubit.state is StudentsLoaded
            ? (studentsCubit.state as StudentsLoaded).students
            : [],
        selectedSection: _selectedSection,
        onIncidentCreated: () {
          if (_mounted) {
            final incidentsCubit = context.read<IncidentsCubit>();
            incidentsCubit.refreshIncidents(sectionId: _selectedSection?.id);
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
        title: const Text(
          'Incidents',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_mounted) {
                final incidentsCubit = context.read<IncidentsCubit>();
                incidentsCubit.refreshIncidents(
                  sectionId: _selectedSection?.id,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Section Filter
          BlocBuilder<SectionsCubit, SectionsState>(
            builder: (context, state) {
              if (state is SectionsLoading) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is SectionsLoaded) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<SectionModel>(
                    decoration: const InputDecoration(
                      labelText: 'Filter by Section',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedSection,
                    hint: const Text('All Sections'),
                    items: [
                      const DropdownMenuItem<SectionModel>(
                        value: null,
                        child: Text('All Sections'),
                      ),
                      ...state.sections.map(
                        (section) => DropdownMenuItem(
                          value: section,
                          child: Text(
                            section.displayName,
                          ), // Use the displayName getter
                        ),
                      ),
                    ],
                    onChanged: _onSectionChanged,
                  ),
                );
              } else if (state is SectionsError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading sections: ${state.message}'),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Incidents List
          Expanded(
            child: BlocBuilder<IncidentsCubit, IncidentsState>(
              builder: (context, state) {
                if (state is IncidentsLoading) {
                  return const IncidentsSkeleton();
                } else if (state is IncidentsLoaded) {
                  if (state.incidents.isEmpty) {
                    return EmptyIncidents(onAddIncident: _showCreateIncident);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (_mounted) {
                        final incidentsCubit = context.read<IncidentsCubit>();
                        incidentsCubit.refreshIncidents(
                          sectionId: _selectedSection?.id,
                        );
                      }
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.incidents.length,
                      itemBuilder: (context, index) {
                        final incident = state.incidents[index];

                        // Get student names directly from the incident model
                        final studentNames = incident.students
                            .map((s) => s.fullName)
                            .toList();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: IncidentCard(
                            incident: incident,
                            studentNames: studentNames,
                            onDelete: () {
                              if (_mounted) {
                                final incidentsCubit = context
                                    .read<IncidentsCubit>();
                                incidentsCubit.deleteIncident(incident.id);
                              }
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is IncidentsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_mounted) {
                              final incidentsCubit = context
                                  .read<IncidentsCubit>();
                              incidentsCubit.refreshIncidents(
                                sectionId: _selectedSection?.id,
                              );
                            }
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const IncidentsSkeleton();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateIncident,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Create New Incident',
        heroTag: 'create_incident_fab',
      ),
    );
  }
}
