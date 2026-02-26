import 'package:flutter/material.dart';

class AppColors {

  static final lightScheme = ColorScheme.light(
    primary: Color(0xFF0050E3),
    onPrimary: Colors.white,
    secondary: Color(0xFF23F323),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Color(0xFF1E293B),
    surfaceContainerHighest: Color(0xFFF1F5F9),
    error: Color(0xFFFF0000),
  );



  static final darkScheme = ColorScheme.dark(
    primary: Color(0xFFF1F5F9),
    onPrimary: Color(0xFF0F172A),
    secondary: Color(0xFF0050E3),
    onSecondary: Color(0xFF0F172A),
    surface: Color(0xFF2B2D30),
    onSurface: Color(0xFFF1F5F9),
    surfaceContainerHighest: Color(0xFF334155),
    error: Color(0xFFFF0000),
  );

}