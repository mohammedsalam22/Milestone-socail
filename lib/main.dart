import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bloc/login/login_cubit.dart';
import 'bloc/posts/posts_cubit.dart';
import 'bloc/sections/sections_cubit.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. build the dependency graph
  DIContainer.setup();

  // 2. Initialize locale from preferences
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('language_code') ?? 'en';
  localeNotifier.value = Locale(languageCode);

  // 3. start the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>?> _getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_info');
    if (token != null && userJson != null) {
      return jsonDecode(userJson) as Map<String, dynamic>;
    }
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
