import 'package:flutter/material.dart';
import '../../../data/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen/login_view.dart';
import '../../shared/theme_switcher.dart';
import '../../shared/language_switcher.dart';
import '../../../generated/l10n.dart';

class ProfileView extends StatelessWidget {
  final UserModel user;

  const ProfileView({super.key, required this.user});

  bool get _isAdmin => user.role.toLowerCase() == 'admin';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                user.firstName.isNotEmpty
                                    ? user.firstName[0].toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Material(
                              color: theme.colorScheme.primary,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _showEditProfile(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '@${user.username}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                user.email,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileActionButton(
                        icon: Icons.edit,
                        label: S.of(context).editProfile,
                        onTap: () => _showEditProfile(context),
                        color: theme.colorScheme.primary,
                      ),
                      _ProfileActionButton(
                        icon: Icons.settings,
                        label: S.of(context).settings,
                        onTap: () => _showSettings(context),
                        color: Colors.blueGrey,
                      ),
                      _ProfileActionButton(
                        icon: Icons.logout,
                        label: S.of(context).logout,
                        onTap: () => _showLogout(context),
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ProfileSection(
                    title: S.of(context).settings,
                    children: [
                      _ProfileInfoTile(
                        icon: Icons.dark_mode,
                        label: S.of(context).darkMode,
                        value: '',
                        onTap: null,
                        trailing: const ThemeSwitcher(),
                      ),
                      _ProfileInfoTile(
                        icon: Icons.language,
                        label: S.of(context).language,
                        value: '',
                        onTap: null,
                        trailing: const LanguageSwitcher(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  if (_isAdmin)
                    _ProfileSection(
                      title: 'Admin Actions',
                      children: [
                        _ProfileInfoTile(
                          icon: Icons.people,
                          label: 'Manage Users',
                          value: '',
                          onTap: () => _showComingSoon(context, 'Manage Users'),
                        ),
                        _ProfileInfoTile(
                          icon: Icons.settings,
                          label: 'System Settings',
                          value: '',
                          onTap: () =>
                              _showComingSoon(context, 'System Settings'),
                        ),
                        _ProfileInfoTile(
                          icon: Icons.analytics,
                          label: 'Reports & Analytics',
                          value: '',
                          onTap: () =>
                              _showComingSoon(context, 'Reports & Analytics'),
                        ),
                        _ProfileInfoTile(
                          icon: Icons.backup,
                          label: 'Backup & Restore',
                          value: '',
                          onTap: () =>
                              _showComingSoon(context, 'Backup & Restore'),
                        ),
                      ],
                    )
                  else
                    _ProfileSection(
                      title: 'Parent Features',
                      children: [
                        _ProfileInfoTile(
                          icon: Icons.school,
                          label: 'View Child Progress',
                          value: '',
                          onTap: () =>
                              _showComingSoon(context, 'View Child Progress'),
                        ),
                        _ProfileInfoTile(
                          icon: Icons.message,
                          label: 'Contact Teachers',
                          value: '',
                          onTap: () =>
                              _showComingSoon(context, 'Contact Teachers'),
                        ),
                        _ProfileInfoTile(
                          icon: Icons.calendar_today,
                          label: 'View Attendance',
                          value: '',
                          onTap: () =>
                              _showComingSoon(context, 'View Attendance'),
                        ),
                        _ProfileInfoTile(
                          icon: Icons.event,
                          label: 'School Calendar',
                          value: '',
                          onTap: () =>
                              _showComingSoon(context, 'School Calendar'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).editProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: S.of(context).firstName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: S.of(context).lastName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: S.of(context).email,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings coming soon!')));
  }

  void _showLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).logout),
        content: Text(S.of(context).areYouSureLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('auth_token');
              await prefs.remove('user_info');
              // Navigate to login page and clear stack
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(S.of(context).loggedOutSuccessfully)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(S.of(context).logout),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(S.of(context).comingSoon(feature))));
  }
}

class _ProfileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ProfileActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color.withOpacity(0.1),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Icon(icon, color: color, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, color: color)),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 1,
          margin: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: value.isNotEmpty ? Text(value) : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: Colors.grey)
              : null),
      onTap: onTap,
    );
  }
}
