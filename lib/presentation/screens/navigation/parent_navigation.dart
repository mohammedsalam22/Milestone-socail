import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';
import '../chats_screen/chat_view.dart';
import '../posts_screen/posts_view.dart';
import '../profile_screen/profile_view.dart';

class ParentNavigation extends StatefulWidget {
  final UserModel user;

  const ParentNavigation({super.key, required this.user});

  @override
  State<ParentNavigation> createState() => _ParentNavigationState();
}

class _ParentNavigationState extends State<ParentNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      PostsView(user: widget.user),
      ChatsView(user: widget.user),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
