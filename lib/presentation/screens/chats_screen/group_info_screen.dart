import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/group_model.dart';
import '../../../data/model/user_model.dart';
import '../../../bloc/groups/groups_cubit.dart';
import '../../../bloc/groups/groups_state.dart';
import '../../../bloc/students/students_cubit.dart';
import '../../../bloc/employees/employees_cubit.dart';
import '../../../core/utils/role_utils.dart';
import '../../../di_container.dart';
import 'edit_group_screen.dart';

class GroupInfoScreen extends StatefulWidget {
  final GroupModel group;
  final UserModel currentUser;

  const GroupInfoScreen({
    super.key,
    required this.group,
    required this.currentUser,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  bool get _canEditGroup =>
      RoleUtils.isAdmin(widget.currentUser.role) ||
      RoleUtils.isTeacher(widget.currentUser.role);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: _canEditGroup
            ? [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editGroup();
                    } else if (value == 'delete') {
                      _deleteGroup();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Edit Group'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Group'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: BlocListener<GroupsCubit, GroupsState>(
        listener: (context, state) {
          if (state is GroupDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(
              context,
              true,
            ); // Return true to indicate group was deleted
          } else if (state is GroupDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error deleting group: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGroupHeader(),
              const SizedBox(height: 24),
              _buildGroupStats(),
              const SizedBox(height: 24),
              _buildMembersSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.green,
            child: Text(
              widget.group.name.isNotEmpty
                  ? widget.group.name[0].toUpperCase()
                  : 'G',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.group.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Created by ${widget.group.owner.name}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (!_canEditGroup) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 4),
                  Text(
                    'View Only',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Students',
            '${widget.group.students.length}',
            Icons.school,
            Colors.blue,
          ),
          _buildStatItem(
            'Employees',
            '${widget.group.employees.length}',
            Icons.work,
            Colors.green,
          ),
          _buildStatItem(
            'Total',
            '${widget.group.totalMembers}',
            Icons.people,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildMembersList(),
      ],
    );
  }

  Widget _buildMembersList() {
    final allMembers = widget.group.allMembers;

    if (allMembers.isEmpty) {
      return const Center(
        child: Text(
          'No members in this group',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allMembers.length,
      itemBuilder: (context, index) {
        final member = allMembers[index];
        final isOwner = member.id == widget.group.owner.id;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isOwner ? Colors.red : Colors.blue,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : 'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: member.role != null
                ? Text(
                    member.role!.toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(member.role!),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  )
                : const Text('Student'),
            trailing: isOwner
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  void _editGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => DIContainer.get<StudentsCubit>()),
            BlocProvider(
              create: (context) => DIContainer.get<EmployeesCubit>(),
            ),
            BlocProvider(create: (context) => DIContainer.get<GroupsCubit>()),
          ],
          child: EditGroupScreen(
            group: widget.group,
            currentUser: widget.currentUser,
            onGroupUpdated: (updatedGroup) {
              setState(() {
                // Update the group data
                // This will be handled by the parent widget
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  void _deleteGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text(
          'Are you sure you want to delete "${widget.group.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GroupsCubit>().deleteGroup(widget.group.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
