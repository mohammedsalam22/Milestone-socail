import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/model/user_model.dart';
import '../../../bloc/notifications/notification_cubit.dart';
import '../chats_screen/chat_view.dart';
import '../posts_screen/posts_view.dart';
import '../student_profile_screen/student_profile_view.dart';
import '../notifications_screen/notifications_screen.dart';
import '../../shared/notification_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      StudentProfileView(user: widget.user),
      PostsView(user: widget.user),
      ChatsView(user: widget.user),
      const NotificationsScreen(),
    ]);

    // Connect to notification WebSocket for parents
    _connectToNotifications();
  }

  Future<void> _connectToNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        // Only connect if user is a parent
        if (widget.user.role.toLowerCase() == 'parent') {
          final cubit = context.read<NotificationCubit>();
          // Only connect if not already connected
          if (!cubit.isConnected) {
            cubit.connectWebSocket(token);
          }
        }
      }
    } catch (e) {
      print('Error connecting to notifications: $e');
    }
  }

  @override
  void dispose() {
    // Disconnect from notifications when parent navigation is disposed
    if (widget.user.role.toLowerCase() == 'parent') {
      context.read<NotificationCubit>().disconnectWebSocket();
    }
    super.dispose();
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
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'المنشورات',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat),
            label: 'المحادثات',
          ),
          BottomNavigationBarItem(
            icon: NotificationBadge(
              child: const Icon(Icons.notifications_outlined),
            ),
            activeIcon: NotificationBadge(
              child: const Icon(Icons.notifications),
            ),
            label: 'الإشعارات',
          ),
        ],
      ),
    );
  }
}
