import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';

class CreateGroupScreen extends StatelessWidget {
  final UserModel user;
  final Function(Map<String, dynamic>) onGroupCreated;

  const CreateGroupScreen({
    super.key,
    required this.user,
    required this.onGroupCreated,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simulate group creation
            final newGroup = {
              'id': DateTime.now().millisecondsSinceEpoch,
              'name': 'New Group',
              'avatar': 'NG',
              'lastMessage': 'Group created!',
              'lastMessageTime': 'Now',
              'unreadCount': 0,
              'isGroup': true,
              'members': [user.firstName + ' ' + user.lastName],
              'isMuted': false,
              'isPinned': false,
            };
            onGroupCreated(newGroup);
            Navigator.pop(context);
          },
          child: const Text('Create Group (Placeholder)'),
        ),
      ),
    );
  }
}
