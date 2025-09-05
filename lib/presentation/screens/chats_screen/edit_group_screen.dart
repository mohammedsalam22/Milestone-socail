import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/group_model.dart';
import '../../../data/model/student_model.dart';
import '../../../data/model/employee_model.dart';
import '../../../data/model/user_model.dart';
import '../../../bloc/students/students_cubit.dart';
import '../../../bloc/students/students_state.dart';
import '../../../bloc/employees/employees_cubit.dart';
import '../../../bloc/employees/employees_state.dart';
import '../../../bloc/groups/groups_cubit.dart';
import '../../../bloc/groups/groups_state.dart';
import 'widgets/student_picker.dart';
import 'widgets/employee_picker.dart';

class EditGroupScreen extends StatefulWidget {
  final GroupModel group;
  final UserModel currentUser;
  final Function(GroupModel) onGroupUpdated;

  const EditGroupScreen({
    super.key,
    required this.group,
    required this.currentUser,
    required this.onGroupUpdated,
  });

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _groupNameController = TextEditingController();
  late TabController _tabController;

  List<StudentModel> _selectedStudents = [];
  List<EmployeeModel> _selectedEmployees = [];
  List<StudentModel> _allStudents = [];
  List<EmployeeModel> _allEmployees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize with current group data
    _groupNameController.text = widget.group.name;

    // Load data first, then match existing members
    _loadDataAndMatchMembers();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadDataAndMatchMembers() {
    // Load students and employees
    context.read<StudentsCubit>().getAllStudents();
    context.read<EmployeesCubit>().getEmployees();
  }

  void _matchMembersIfDataLoaded() {
    final studentsState = context.read<StudentsCubit>().state;
    final employeesState = context.read<EmployeesCubit>().state;

    if (studentsState is StudentsLoaded && employeesState is EmployeesLoaded) {
      _allStudents = studentsState.students;
      _allEmployees = employeesState.employees;

      // Match existing group members with loaded data
      _selectedStudents = _matchStudentsWithGroupMembers();
      _selectedEmployees = _matchEmployeesWithGroupMembers();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<StudentModel> _matchStudentsWithGroupMembers() {
    final List<StudentModel> matchedStudents = [];

    for (final groupMember in widget.group.students) {
      final student = _allStudents.firstWhere(
        (s) => s.id == groupMember.id,
        orElse: () => StudentModel(
          id: groupMember.id,
          fullName: groupMember.name,
          sectionId: 0,
          sectionName: '',
          gradeName: '',
          studyStageName: '',
          studyYearName: '',
        ),
      );
      matchedStudents.add(student);
    }

    return matchedStudents;
  }

  List<EmployeeModel> _matchEmployeesWithGroupMembers() {
    final List<EmployeeModel> matchedEmployees = [];

    for (final groupMember in widget.group.employees) {
      final employee = _allEmployees.firstWhere(
        (e) => e.id == groupMember.id,
        orElse: () => EmployeeModel(
          id: groupMember.id,
          username: '',
          phone: '',
          firstName: groupMember.name.split(' ').first,
          lastName: groupMember.name.split(' ').length > 1
              ? groupMember.name.split(' ').skip(1).join(' ')
              : '',
          role: groupMember.role ?? '',
          fatherName: '',
          motherName: '',
          nationality: '',
          gender: '',
          address: '',
          birthDate: '',
          familyStatus: '',
          nationalNo: '',
          salary: '',
          contractStart: '',
          contractEnd: '',
          dayStart: '',
          dayEnd: '',
        ),
      );
      matchedEmployees.add(employee);
    }

    return matchedEmployees;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Group'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'Students', icon: Icon(Icons.school, size: 20)),
                Tab(text: 'Employees', icon: Icon(Icons.work, size: 20)),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: MultiBlocListener(
        listeners: [
          BlocListener<GroupsCubit, GroupsState>(
            listener: (context, state) {
              if (state is GroupCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                widget.onGroupUpdated(state.group);
              } else if (state is GroupCreateError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating group: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          BlocListener<StudentsCubit, StudentsState>(
            listener: (context, state) {
              _matchMembersIfDataLoaded();
            },
          ),
          BlocListener<EmployeesCubit, EmployeesState>(
            listener: (context, state) {
              _matchMembersIfDataLoaded();
            },
          ),
        ],
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildGroupNameField(),
                  _buildSelectedMembersChips(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        StudentPicker(
                          selectedStudents: _selectedStudents,
                          onSelectionChanged: (students) {
                            setState(() {
                              _selectedStudents = students;
                            });
                          },
                        ),
                        EmployeePicker(
                          selectedEmployees: _selectedEmployees,
                          onSelectionChanged: (employees) {
                            setState(() {
                              _selectedEmployees = employees;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildUpdateButton(),
                ],
              ),
      ),
    );
  }

  Widget _buildGroupNameField() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: TextField(
        controller: _groupNameController,
        decoration: const InputDecoration(
          labelText: 'Group Name',
          hintText: 'Enter group name',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.group, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSelectedMembersChips() {
    final totalMembers = _selectedStudents.length + _selectedEmployees.length;

    if (totalMembers == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Selected Members ($totalMembers)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._selectedStudents.map(
                  (student) => _buildMemberChip(
                    student.fullName,
                    Colors.blue,
                    () => _removeStudent(student),
                  ),
                ),
                ..._selectedEmployees.map(
                  (employee) => _buildMemberChip(
                    employee.fullName,
                    _getRoleColor(employee.role),
                    () => _removeEmployee(employee),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberChip(String name, Color color, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        backgroundColor: color.withOpacity(0.1),
        deleteIcon: Icon(Icons.close, size: 16, color: color),
        onDeleted: onRemove,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildUpdateButton() {
    final totalMembers = _selectedStudents.length + _selectedEmployees.length;
    final canUpdate =
        _groupNameController.text.trim().isNotEmpty && totalMembers > 0;

    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        final isLoading = state is GroupCreating;

        return Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canUpdate && !isLoading ? _updateGroup : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Update Group${totalMembers > 0 ? ' ($totalMembers members)' : ''}',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _updateGroup() {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) return;

    final request = CreateGroupRequest(
      name: groupName,
      studentIds: _selectedStudents.map((s) => s.id).toList(),
      employeeIds: _selectedEmployees.map((e) => e.id).toList(),
    );

    context.read<GroupsCubit>().updateGroup(widget.group.id, request);
  }

  void _removeStudent(StudentModel student) {
    setState(() {
      _selectedStudents.removeWhere((s) => s.id == student.id);
    });
  }

  void _removeEmployee(EmployeeModel employee) {
    setState(() {
      _selectedEmployees.removeWhere((e) => e.id == employee.id);
    });
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
