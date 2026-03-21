import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color accentColor = Color(0xFF6DA34D);
  static const Color backgroundColor = Color(0xFFF6FAF2);
  static const Color highlightColor = Color(0xFFE2F0D9);
  
  static ThemeData get themeData {
    return ThemeData(
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: backgroundColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
