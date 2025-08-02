import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'locale_notifier.dart';

class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  Locale _currentLocale = const Locale('en');

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    setState(() {
      _currentLocale = Locale(languageCode);
    });
  }

  Future<void> _saveLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    // Update the global notifier for immediate language switching
    localeNotifier.value = Locale(languageCode);
    setState(() {
      _currentLocale = Locale(languageCode);
    });
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Radio<String>(
                  value: 'en',
                  groupValue: _currentLocale.languageCode,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _saveLanguagePreference(value!);
                  },
                ),
                title: const Text('English'),
                onTap: () {
                  Navigator.of(context).pop();
                  _saveLanguagePreference('en');
                },
              ),
              ListTile(
                leading: Radio<String>(
                  value: 'ar',
                  groupValue: _currentLocale.languageCode,
                  onChanged: (value) {
                    Navigator.of(context).pop();
                    _saveLanguagePreference(value!);
                  },
                ),
                title: const Text('العربية'),
                onTap: () {
                  Navigator.of(context).pop();
                  _saveLanguagePreference('ar');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.language),
      onPressed: _showLanguageDialog,
    );
  }
}
