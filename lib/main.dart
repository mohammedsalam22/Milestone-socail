import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/login/login_cubit.dart';
import 'bloc/posts/posts_cubit.dart';
import 'bloc/sections/sections_cubit.dart';
import 'bloc/chat/chat_cubit.dart';
import 'bloc/incidents/incidents_cubit.dart';
import 'bloc/students/students_cubit.dart';
import 'bloc/attendance/attendance_cubit.dart';
import 'bloc/marks/marks_cubit.dart';
import 'bloc/schedule/schedule_cubit.dart';

// theme / ui
import 'core/theme/app_theme.dart';
import 'di_container.dart';
import 'presentation/shared/theme_switcher.dart';
import 'presentation/shared/locale_notifier.dart';
import 'presentation/screens/login_screen/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'presentation/screens/navigation/role_based_navigation.dart';
import 'data/model/user_model.dart';
import 'generated/l10n.dart';
import 'data/services/attendance_notification_service.dart';
import 'data/services/network_connectivity_manager.dart';
import 'data/services/attendance_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. build the dependency graph
  DIContainer.setup();

  // 2. Initialize offline services
  await _initializeOfflineServices();

  // 3. Initialize locale from preferences
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language_code') ?? 'en';
  localeNotifier.value = Locale(languageCode);

  // 4. start the app
  runApp(const MyApp());
}

Future<void> _initializeOfflineServices() async {
  try {
    // Initialize notification service
    await AttendanceNotificationService.initialize();

    // Initialize network connectivity manager
    await NetworkConnectivityManager.initialize();

    // Initialize sync service
    await DIContainer.get<AttendanceSyncService>().initialize();

    print('✅ Offline services initialized successfully');
  } catch (e) {
    print('❌ Error initializing offline services: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_info');
    final studentDataJson = prefs.getString('student_data');

    print('🔍 Loading stored user data...');
    print('📱 Token exists: ${token != null}');
    print('👤 User info exists: ${userJson != null}');
    print('🎓 Student data exists: ${studentDataJson != null}');

    if (token != null) {
      // If we have student data, use it as the primary source
      if (studentDataJson != null) {
        print('🎓 Using student data as primary source');
        final studentData = jsonDecode(studentDataJson) as Map<String, dynamic>;
        print('📊 Student data keys: ${studentData.keys.toList()}');
        return studentData;
      }

      // Fallback to user info if no student data
      if (userJson != null) {
        print('👤 Using user info as fallback');
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        print('📊 User data keys: ${userData.keys.toList()}');
        return userData;
      }
    }

    print('❌ No stored user data found');
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginCubit>(create: (_) => DIContainer.get<LoginCubit>()),
        BlocProvider<PostsCubit>(create: (_) => DIContainer.get<PostsCubit>()),
        BlocProvider<SectionsCubit>(
          create: (_) => DIContainer.get<SectionsCubit>(),
        ),
        BlocProvider<ChatCubit>(create: (_) => DIContainer.get<ChatCubit>()),
        BlocProvider<IncidentsCubit>(
          create: (_) => DIContainer.get<IncidentsCubit>(),
        ),
        BlocProvider<StudentsCubit>(
          create: (_) => DIContainer.get<StudentsCubit>(),
        ),
        BlocProvider<AttendanceCubit>(
          create: (_) => DIContainer.get<AttendanceCubit>(),
        ),
        BlocProvider<MarksCubit>(create: (_) => DIContainer.get<MarksCubit>()),
        BlocProvider<ScheduleCubit>(
          create: (_) => DIContainer.get<ScheduleCubit>(),
        ),
      ],
      child: ValueListenableBuilder<bool>(
        valueListenable: isDarkMode,
        builder: (context, isDark, _) {
          return ValueListenableBuilder<Locale>(
            valueListenable: localeNotifier,
            builder: (context, locale, _) {
              return MaterialApp(
                title: 'Milestone Demo',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                debugShowCheckedModeBanner: false,
                localizationsDelegates: [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                locale: locale,
                home: FutureBuilder<Map<String, dynamic>?>(
                  future: _getStoredUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasData && snapshot.data != null) {
                      final user = UserModel.fromJson(snapshot.data!);
                      return RoleBasedNavigation(user: user);
                    }
                    return const LoginView();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
