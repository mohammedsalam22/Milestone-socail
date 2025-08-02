import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';
import '../chats_screen/chat_view.dart';
import '../posts_screen/posts_view.dart';
import '../attendance_screen/attendance_view.dart';
import '../profile_screen/profile_view.dart';

class AdminNavigation extends StatefulWidget {
  final UserModel user;

  const AdminNavigation({super.key, required this.user});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      PostsView(user: widget.user),
      ChatsView(user: widget.user),
      AttendanceView(user: widget.user),
      ProfileView(user: widget.user),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
