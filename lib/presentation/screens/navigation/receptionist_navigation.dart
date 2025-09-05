import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';
import '../chats_screen/chat_view.dart';
import '../incidents_screen/incidents_view.dart';
import '../attendance_screen/attendance_view.dart';
import '../profile_screen/profile_view.dart';

class ReceptionistNavigation extends StatefulWidget {
  final UserModel user;

  const ReceptionistNavigation({super.key, required this.user});

  @override
  State<ReceptionistNavigation> createState() => _ReceptionistNavigationState();
}

class _ReceptionistNavigationState extends State<ReceptionistNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      ChatsView(user: widget.user),
      IncidentsView(user: widget.user),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Incidents',
          ),
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
