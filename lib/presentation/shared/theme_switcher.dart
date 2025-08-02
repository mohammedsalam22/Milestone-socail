import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global ValueNotifier for theme mode
final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    isDarkMode.value = isDark;
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    isDarkMode.value = value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkMode,
      builder: (context, value, child) {
        return Switch.adaptive(
          value: value,
          onChanged: _saveThemePreference,
          activeColor: Theme.of(context).colorScheme.secondary,
          inactiveThumbColor: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
