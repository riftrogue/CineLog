import 'package:flutter/material.dart';
import 'package:cinelog/config/app_constants.dart';

/// App theme configuration for light and dark modes
class AppTheme {
  /// Dark theme (primary theme)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryColor,
        surface: AppConstants.surfaceColor,
        error: AppConstants.errorColor,
        onPrimary: Colors.black,
        onSurface: AppConstants.textPrimaryColor,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppConstants.backgroundColor,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.backgroundColor,
        foregroundColor: AppConstants.textPrimaryColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppConstants.primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: AppConstants.primaryColor,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.backgroundColor,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppConstants.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppConstants.borderColor,
            width: 1,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppConstants.primaryColor),
        ),
        hintStyle: const TextStyle(color: AppConstants.textHintColor),
        labelStyle: const TextStyle(color: AppConstants.textSecondaryColor),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppConstants.textPrimaryColor),
        displayMedium: TextStyle(color: AppConstants.textPrimaryColor),
        displaySmall: TextStyle(color: AppConstants.textPrimaryColor),
        headlineLarge: TextStyle(color: AppConstants.textPrimaryColor),
        headlineMedium: TextStyle(color: AppConstants.textPrimaryColor),
        headlineSmall: TextStyle(color: AppConstants.textPrimaryColor),
        titleLarge: TextStyle(color: AppConstants.textPrimaryColor),
        titleMedium: TextStyle(color: AppConstants.textPrimaryColor),
        titleSmall: TextStyle(color: AppConstants.textPrimaryColor),
        bodyLarge: TextStyle(color: AppConstants.textPrimaryColor),
        bodyMedium: TextStyle(color: AppConstants.textPrimaryColor),
        bodySmall: TextStyle(color: AppConstants.textSecondaryColor),
        labelLarge: TextStyle(color: AppConstants.textPrimaryColor),
        labelMedium: TextStyle(color: AppConstants.textSecondaryColor),
        labelSmall: TextStyle(color: AppConstants.textHintColor),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppConstants.textPrimaryColor,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppConstants.textHintColor.withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }

  /// Light theme (optional for future use)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppConstants.primaryColor,
        surface: Colors.grey,
        error: AppConstants.errorColor,
      ),
      scaffoldBackgroundColor: Colors.white,
    );
  }
}