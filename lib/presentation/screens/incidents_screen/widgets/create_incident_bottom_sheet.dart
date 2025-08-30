import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/incidents/incidents_cubit.dart';
import '../../../../bloc/incidents/incidents_state.dart';
import '../../../../data/model/student_model.dart';
import '../../../../data/model/section_model.dart';
import '../../../../di_container.dart';
import 'package:intl/intl.dart';

class CreateIncidentBottomSheet extends StatefulWidget {
  final List<StudentModel> students;
  final SectionModel? selectedSection;
  final VoidCallback onIncidentCreated;

  const CreateIncidentBottomSheet({
    super.key,
    required this.students,
    required this.selectedSection,
    required this.onIncidentCreated,
  });

  @override
  State<CreateIncidentBottomSheet> createState() => _CreateIncidentBottomSheetState();
}

class _CreateIncidentBottomSheetState extends State<CreateIncidentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _procedureController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<int> _selectedStudentIds = [];
  late IncidentsCubit _incidentsCubit;

  @override
  void initState() {
    super.initState();
    _incidentsCubit = DIContainer.get<IncidentsCubit>();
    
    // Pre-select students from the selected section if available
    if (widget.selectedSection != null) {
      _selectedStudentIds = widget.students
          .where((student) => student.sectionId == widget.selectedSection!.id)
          .map((student) => student.id)
          .toList();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _procedureController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleStudent(int studentId) {
    setState(() {
      if (_selectedStudentIds.contains(studentId)) {
        _selectedStudentIds.remove(studentId);
      } else {
        _selectedStudentIds.add(studentId);
      }
    });
  }

  Future<void> _createIncident() async {
    if (_formKey.currentState!.validate() && _selectedStudentIds.isNotEmpty) {
      await _incidentsCubit.createIncident(
        studentIds: _selectedStudentIds,
        title: _titleController.text.trim(),
        procedure: _procedureController.text.trim(),
        note: _noteController.text.trim(),
        date: _selectedDate,
      );
      
      if (mounted) {
        Navigator.of(context).pop();
        widget.onIncidentCreated();
      }
    } else if (_selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one student'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<StudentModel> get _filteredStudents {
    if (widget.selectedSection != null) {
      return widget.students
          .where((student) => student.sectionId == widget.selectedSection!.id)
          .toList();
    }
    return widget.students;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          
          // Title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Create New Incident',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter incident title',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Procedure field
                    TextFormField(
                      controller: _procedureController,
                      decoration: const InputDecoration(
                        labelText: 'Procedure *',
                        border: OutlineInputBorder(),
                        hintText: 'Enter procedure to follow',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Procedure is required';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Note field
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                        hintText: 'Enter additional notes (optional)',
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Date picker
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              'Date: ${dateFormat.format(_selectedDate)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Students selection
                    Text(
                      'Select Students *',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    if (_filteredStudents.isEmpty)
                      const Text(
                        'No students available for the selected section',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            final isSelected = _selectedStudentIds.contains(student.id);
                            
                            return CheckboxListTile(
                              title: Text(student.fullName),
                              subtitle: Text('${student.gradeName} - ${student.sectionName}'),
                              value: isSelected,
                              onChanged: (_) => _toggleStudent(student.id),
                              controlAffinity: ListTileControlAffinity.leading,
                            );
                          },
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _createIncident,
                            child: const Text('Create Incident'),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
