import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/students/students_cubit.dart';
import '../../../../bloc/students/students_state.dart';
import '../../../../data/model/student_model.dart';

class StudentPicker extends StatefulWidget {
  final List<StudentModel> selectedStudents;
  final Function(List<StudentModel>) onSelectionChanged;

  const StudentPicker({
    super.key,
    required this.selectedStudents,
    required this.onSelectionChanged,
  });

  @override
  State<StudentPicker> createState() => _StudentPickerState();
}

class _StudentPickerState extends State<StudentPicker> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentsCubit, StudentsState>(
      builder: (context, state) {
        if (state is StudentsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StudentsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading students',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      context.read<StudentsCubit>().getAllStudents(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is StudentsLoaded) {
          final students = _filterStudents(state.students);
          return Column(
            children: [
              _buildSearchField(),
              const SizedBox(height: 16),
              Expanded(child: _buildStudentList(students)),
            ],
          );
        }

        return const Center(child: Text('No students available'));
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search students...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildStudentList(List<StudentModel> students) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No students found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            if (_searchQuery.isNotEmpty)
              Text(
                'Try adjusting your search',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final isSelected = widget.selectedStudents.any(
          (selected) => selected.id == student.id,
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (selected) {
              _toggleStudentSelection(student);
            },
            title: Text(
              student.fullName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.sectionName,
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${student.gradeName} - ${student.studyStageName}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            secondary: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Text(
                student.fullName.isNotEmpty
                    ? student.fullName.split(' ').first[0].toUpperCase()
                    : 'S',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleStudentSelection(StudentModel student) {
    final isSelected = widget.selectedStudents.any(
      (selected) => selected.id == student.id,
    );

    List<StudentModel> newSelection;
    if (isSelected) {
      newSelection = widget.selectedStudents
          .where((selected) => selected.id != student.id)
          .toList();
    } else {
      newSelection = [...widget.selectedStudents, student];
    }

    widget.onSelectionChanged(newSelection);
  }

  List<StudentModel> _filterStudents(List<StudentModel> students) {
    if (_searchQuery.isEmpty) return students;

    return students
        .where(
          (student) =>
              student.fullName.toLowerCase().contains(_searchQuery) ||
              student.sectionName.toLowerCase().contains(_searchQuery) ||
              student.gradeName.toLowerCase().contains(_searchQuery) ||
              student.studyStageName.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }
}
