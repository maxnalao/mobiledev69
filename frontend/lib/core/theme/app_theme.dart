import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// โทนสีได้แรงบันดาลใจจาก "สมุดบัญชีธนาคาร": เขียวเข้มสื่อถึงการออม,
/// ทองสำหรับรายรับ, ดินเผาสำหรับรายจ่าย บนพื้นกระดาษอุ่นแทนสีเทาซ้ำซาก
class AppColors {
  static const jade = Color(0xFF1F6F5C);
  static const gold = Color(0xFFB8862B);
  static const clay = Color(0xFFA64B3B);
  static const paper = Color(0xFFF2EEE3);
  static const ink = Color(0xFF17242B);
  static const paperDark = Color(0xFF11181A);
  static const inkLight = Color(0xFFE9E4D8);
}

class AppTheme {
  static TextTheme _textTheme(Color base) {
    return TextTheme(
      headlineSmall: GoogleFonts.kanit(fontWeight: FontWeight.w600, color: base),
      titleLarge: GoogleFonts.kanit(fontWeight: FontWeight.w600, color: base),
      titleMedium: GoogleFonts.kanit(fontWeight: FontWeight.w500, color: base),
      bodyLarge: GoogleFonts.sarabun(color: base),
      bodyMedium: GoogleFonts.sarabun(color: base),
      labelLarge: GoogleFonts.sarabun(fontWeight: FontWeight.w600, color: base),
    );
  }

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.paper,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.jade).copyWith(
      primary: AppColors.jade,
      secondary: AppColors.gold,
      error: AppColors.clay,
      surface: Colors.white,
    ),
    textTheme: _textTheme(AppColors.ink),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      elevation: 0,
      titleTextStyle: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.ink.withValues(alpha: 0.06)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.jade,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.sarabun(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.12))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.ink.withValues(alpha: 0.12))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.jade, width: 1.6)),
      labelStyle: GoogleFonts.sarabun(color: AppColors.ink.withValues(alpha: 0.7)),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.paperDark,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.jade, brightness: Brightness.dark).copyWith(
      primary: const Color(0xFF57B79D),
      secondary: AppColors.gold,
      error: const Color(0xFFE07A63),
      surface: const Color(0xFF182224),
    ),
    textTheme: _textTheme(AppColors.inkLight),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.paperDark,
      foregroundColor: AppColors.inkLight,
      elevation: 0,
      titleTextStyle: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.inkLight),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF182224),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
    ),
  );
}