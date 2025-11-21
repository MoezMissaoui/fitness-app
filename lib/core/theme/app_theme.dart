import 'package:flutter/material.dart';

/// Thème de l'application basé sur le design fourni
class AppTheme {
  AppTheme._();

  // Couleurs du design
  static const Color primaryBlack = Color(0xFF232020);
  static const Color lightBlue = Color(0xFFBAE5FF);
  static const Color lightPurple = Color(0xFFCDBBF8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.light(
        primary: lightPurple,
        secondary: lightBlue,
        surface: white,
        background: grey,
        error: Colors.red,
        onPrimary: primaryBlack,
        onSecondary: primaryBlack,
        onSurface: primaryBlack,
        onBackground: primaryBlack,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F1E8), // Fond beige/crème comme le header
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 57,
          fontWeight: FontWeight.w400,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 45,
          fontWeight: FontWeight.w400,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 36,
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 32,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryBlack),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          color: primaryBlack,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: lightPurple,
        unselectedItemColor: darkGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}

