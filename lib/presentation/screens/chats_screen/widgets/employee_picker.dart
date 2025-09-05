import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/employees/employees_cubit.dart';
import '../../../../bloc/employees/employees_state.dart';
import '../../../../data/model/employee_model.dart';

class EmployeePicker extends StatefulWidget {
  final List<EmployeeModel> selectedEmployees;
  final Function(List<EmployeeModel>) onSelectionChanged;

  const EmployeePicker({
    super.key,
    required this.selectedEmployees,
    required this.onSelectionChanged,
  });

  @override
  State<EmployeePicker> createState() => _EmployeePickerState();
}

class _EmployeePickerState extends State<EmployeePicker> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRole = 'All';

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
    return BlocBuilder<EmployeesCubit, EmployeesState>(
      builder: (context, state) {
        if (state is EmployeesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EmployeesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading employees',
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
                      context.read<EmployeesCubit>().getEmployees(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is EmployeesLoaded) {
          final employees = _filterEmployees(state.employees);
          return Column(
            children: [
              _buildSearchAndFilter(),
              const SizedBox(height: 16),
              Expanded(child: _buildEmployeeList(employees)),
            ],
          );
        }

        return const Center(child: Text('No employees available'));
      },
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search employees...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRoleChip('All'),
              const SizedBox(width: 8),
              _buildRoleChip('teacher'),
              const SizedBox(width: 8),
              _buildRoleChip('cooperator'),
              const SizedBox(width: 8),
              _buildRoleChip('admin'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip(String role) {
    final isSelected = _selectedRole == role;
    return FilterChip(
      label: Text(role == 'All' ? 'All' : role.toUpperCase()),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedRole = role;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildEmployeeList(List<EmployeeModel> employees) {
    if (employees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No employees found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            if (_searchQuery.isNotEmpty || _selectedRole != 'All')
              Text(
                'Try adjusting your search or filter',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final isSelected = widget.selectedEmployees.any(
          (selected) => selected.id == employee.id,
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: CheckboxListTile(
            value: isSelected,
            onChanged: (selected) {
              _toggleEmployeeSelection(employee);
            },
            title: Text(
              employee.fullName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.role.toUpperCase(),
                  style: TextStyle(
                    color: _getRoleColor(employee.role),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (employee.phone.isNotEmpty)
                  Text(
                    employee.phone,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            secondary: CircleAvatar(
              backgroundColor: _getRoleColor(employee.role).withOpacity(0.1),
              child: Text(
                employee.firstName.isNotEmpty
                    ? employee.firstName[0].toUpperCase()
                    : 'E',
                style: TextStyle(
                  color: _getRoleColor(employee.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleEmployeeSelection(EmployeeModel employee) {
    final isSelected = widget.selectedEmployees.any(
      (selected) => selected.id == employee.id,
    );

    List<EmployeeModel> newSelection;
    if (isSelected) {
      newSelection = widget.selectedEmployees
          .where((selected) => selected.id != employee.id)
          .toList();
    } else {
      newSelection = [...widget.selectedEmployees, employee];
    }

    widget.onSelectionChanged(newSelection);
  }

  List<EmployeeModel> _filterEmployees(List<EmployeeModel> employees) {
    var filtered = employees;

    // Filter by role
    if (_selectedRole != 'All') {
      filtered = filtered
          .where(
            (employee) =>
                employee.role.toLowerCase() == _selectedRole.toLowerCase(),
          )
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (employee) =>
                employee.fullName.toLowerCase().contains(_searchQuery) ||
                employee.role.toLowerCase().contains(_searchQuery) ||
                employee.phone.contains(_searchQuery),
          )
          .toList();
    }

    return filtered;
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'teacher':
        return Colors.blue;
      case 'cooperator':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
