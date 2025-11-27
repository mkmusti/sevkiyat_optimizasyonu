// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Ana Renklerimiz (İstediğiniz mor-mavi geçişine uygun)
  static const Color primaryColor = Color(0xFF6A1B9A); // Mor
  static const Color secondaryColor = Color(0xFF1E88E5); // Mavi

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Colors.grey[100]!, // Açık tema arka planı
    ),
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor, // Koyu temada da ana rengimiz
      secondary: secondaryColor,
      background: Color(0xFF121212), // Koyu tema arka planı
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      elevation: 0,
    ),
  );
}