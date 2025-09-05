import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';
import '../schedule_screen/widgets/teacher_schedule_view.dart';
import '../posts_screen/posts_view.dart';
import '../chats_screen/chat_view.dart';
import '../incidents_screen/incidents_view.dart';
import '../profile_screen/profile_view.dart';

class TeacherNavigation extends StatefulWidget {
  final UserModel user;

  const TeacherNavigation({super.key, required this.user});

  @override
  State<TeacherNavigation> createState() => _TeacherNavigationState();
}

class _TeacherNavigationState extends State<TeacherNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      TeacherScheduleView(user: widget.user),
      PostsView(user: widget.user),
      ChatsView(user: widget.user),
      IncidentsView(user: widget.user),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Posts'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Incidents',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
