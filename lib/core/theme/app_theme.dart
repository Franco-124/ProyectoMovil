import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.bgDark,
      onPrimary: AppColors.textWhite,
      secondary: AppColors.accentTeal,
      onSecondary: AppColors.bgDark,
      surface: AppColors.bgDark,
      onSurface: AppColors.textWhite,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'Roboto',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentTeal,
        foregroundColor: AppColors.bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      hintStyle: const TextStyle(color: AppColors.textGray),
      labelStyle: const TextStyle(color: AppColors.bgDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    // Esto asegura que el texto dentro del TextField sea oscuro (legible sobre fondo blanco)
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textWhite),
      titleMedium: TextStyle(color: AppColors.darkButton), // Usado por TextField por defecto
    ),
  );
}
