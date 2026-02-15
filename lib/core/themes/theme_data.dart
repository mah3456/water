import 'package:flutter/material.dart';

class AppColors {

  static final lightScheme = ColorScheme.light(
    primary: Color(0xFF04DC04),
    onPrimary: Colors.white,
    secondary: Color(0xFF23F323),
    onSecondary: Colors.white,
    background: Color(0xFFF5F5F5),
    onBackground: Color(0xFF1E293B),
    surface: Colors.white,
    onSurface: Color(0xFF1E293B),
    surfaceVariant: Color(0xFFF1F5F9),
    error: Color(0xFFFF0000),
  );



  static final darkScheme = ColorScheme.dark(
    primary: Color(0xFF1E1F22),
    onPrimary: Color(0xFF0F172A),
    secondary: Color(0xFF0050E3),
    onSecondary: Color(0xFF0F172A),
    background: Color(0xFF1E1F22),
    onBackground: Color(0xFFF1F5F9),
    surface: Color(0xFF2B2D30),
    onSurface: Color(0xFFF1F5F9),
    surfaceVariant: Color(0xFF334155),
    error: Color(0xFFFF0000),
  );

}