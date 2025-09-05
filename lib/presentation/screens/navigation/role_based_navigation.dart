import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/login/login_cubit.dart';
import '../../../bloc/login/login_state.dart';
import '../../../data/model/user_model.dart';
import 'admin_navigation.dart';
import 'parent_navigation.dart';

class RoleBasedNavigation extends StatelessWidget {
  final UserModel user;

  const RoleBasedNavigation({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage)));
        }
      },
      child: _buildNavigationBasedOnRole(),
    );
  }

  Widget _buildNavigationBasedOnRole() {
    // Handle null or empty role
    if (user.role.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Unable to determine user role',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text('Please contact support'),
            ],
          ),
        ),
      );
    }

    switch (user.role.toLowerCase()) {
      case 'admin':
      case 'teacher':
      case 'cooperator':
        return AdminNavigation(user: user);
      case 'parent':
      case 'student':
        return ParentNavigation(user: user);
      default:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Unknown Role: ${user.role}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text('Please contact support'),
              ],
            ),
          ),
        );
    }
  }
}
