import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette from Reference Image
  static const Color primaryColor = Color(0xFFC6E941); // Lime Green
  static const Color secondaryColor = Color(0xFF052822); // Dark Green/Black
  static const Color backgroundColor = Color(0xFFF8F9FB); // Light Gray/White
  static const Color surfaceColor = Colors.white; 
  static const Color errorColor = Color(0xFFE53935);
  
  static const Color textDark = Color(0xFF1F2937); // Dark Gray for text
  static const Color textLight = Color(0xFF9CA3AF); // Light Gray for subtitles

  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentGreen = Color(0xFF22C55E);
  static const Color accentPurple = Color(0xFFA855F7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: secondaryColor, // Text on Lime Green should be Dark
        onSecondary: Colors.white,
        onSurface: textDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(color: textDark, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.inter(color: textDark),
        bodyMedium: GoogleFonts.inter(color: textLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: secondaryColor,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
