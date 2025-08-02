import 'package:flutter/material.dart';

class AppColors {
  static const Color ashGray = Color(0xFFBCD4CC);
  static const Color darkBlue = Color(0xFF002F45);
  static const Color earth = Color(0xFFE3A750);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.darkBlue,
      scaffoldBackgroundColor: AppColors.ashGray,
      colorScheme: ColorScheme.light(
        primary: AppColors.darkBlue,
        secondary: AppColors.earth,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.darkBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.earth, width: 2),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.earth,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.ashGray,
      scaffoldBackgroundColor: AppColors.darkBlue,
      colorScheme: ColorScheme.dark(
        primary: AppColors.ashGray,
        secondary: AppColors.earth,
        surface: AppColors.darkBlue,
        onPrimary: AppColors.darkBlue,
        onSecondary: AppColors.earth,
        onSurface: AppColors.ashGray,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ashGray,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBlue,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.ashGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.earth, width: 2),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.earth,
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}
