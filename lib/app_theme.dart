import 'package:flutter/material.dart';

class AppTheme {
  static const Color burgundy = Color(0xFF4A0C2A);
  static const Color peach = Color(0xFFF5AFA5);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF666666);
  static const Color googleRed = Color(0xFFDB4437);
  static const Color facebookBlue = Color(0xFF4267B2);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: burgundy,
      scaffoldBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyMedium: TextStyle(
          color: darkGray,
          fontSize: 16,
        ),
        labelMedium: TextStyle(
          color: peach,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: peach,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: peach,
        hintStyle: TextStyle(color: darkGray),
        labelStyle: TextStyle(color: darkGray),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      // Added for a new screen with a FloatingActionButton
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: peach,
        foregroundColor: Colors.white,
      ),
    );
  }
}