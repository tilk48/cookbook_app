import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AppTheme {
  // Color palette inspired by cooking/food
  static const Color _primaryColor = Color(0xFFE57373); // Warm red
  static const Color _primaryVariant = Color(0xFFD32F2F);
  static const Color _secondary = Color(0xFFFF8A65); // Orange accent
  static const Color _secondaryVariant = Color(0xFFFF5722);

  static const Color _surface = Colors.white;
  static const Color _background = Color(0xFFFAFAFA);
  static const Color _error = Color(0xFFB00020);

  static const Color _onPrimary = Colors.white;
  static const Color _onSecondary = Colors.white;
  static const Color _onSurface = Color(0xFF1A1A1A);
  static const Color _onBackground = Color(0xFF1A1A1A);
  static const Color _onError = Colors.white;

  // Dark theme colors
  static const Color _darkPrimary = Color(0xFFEF5350);
  static const Color _darkPrimaryVariant = Color(0xFFD32F2F);
  static const Color _darkSecondary = Color(0xFFFF7043);
  static const Color _darkSecondaryVariant = Color(0xFFFF5722);

  static const Color _darkSurface = Color(0xFF1E1E1E);
  static const Color _darkBackground = Color(0xFF121212);
  static const Color _darkError = Color(0xFFCF6679);

  static const Color _darkOnPrimary = Colors.black;
  static const Color _darkOnSecondary = Colors.black;
  static const Color _darkOnSurface = Color(0xFFE1E1E1);
  static const Color _darkOnBackground = Color(0xFFE1E1E1);
  static const Color _darkOnError = Colors.black;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _primaryColor,
        onPrimary: _onPrimary,
        secondary: _secondary,
        onSecondary: _onSecondary,
        error: _error,
        onError: _onError,
        surface: _surface,
        onSurface: _onSurface,
        background: _background,
        onBackground: _onBackground,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _surface,
        foregroundColor: _onSurface,
        titleTextStyle: TextStyle(
          color: _onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.smallPadding),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 8,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _secondary,
        foregroundColor: _onSecondary,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade200,
        selectedColor: _primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: _onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        secondary: _darkSecondary,
        onSecondary: _darkOnSecondary,
        error: _darkError,
        onError: _darkOnError,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        background: _darkBackground,
        onBackground: _darkOnBackground,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnSurface,
        titleTextStyle: TextStyle(
          color: _darkOnSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.smallPadding),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.largePadding,
            vertical: AppConstants.defaultPadding,
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: const BorderSide(color: _darkError, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        elevation: 8,
        backgroundColor: _darkSurface,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkSecondary,
        foregroundColor: _darkOnSecondary,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade800,
        selectedColor: _darkPrimary.withOpacity(0.3),
        labelStyle: const TextStyle(color: _darkOnSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        ),
      ),
    );
  }
}
