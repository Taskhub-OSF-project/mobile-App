import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Dark background colors (matching reference image)
  static const Color background = Color(0xFF0F1B2D);   // Deep navy
  static const Color surface = Color(0xFF162236);       // Card surface
  static const Color surfaceElevated = Color(0xFF1C2D42); // Slightly lighter

  // Accent / Primary colors
  static const Color primary = Color(0xFF00C896);       // Bright teal-green
  static const Color primaryDark = Color(0xFF00A87E);
  static const Color primaryLight = Color(0xFF1A3A4A);
  static const Color accent = Color(0xFF00E5B0);        // Lighter teal
  static const Color accentBlue = Color(0xFF3B82F6);    // Blue accent

  // Status colors
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color success = Color(0xFF00C896);

  // Text colors
  static const Color textPrimary = Color(0xFFEEF2FF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color border = Color(0xFF1E3A5F);

  // Wallet card gradient colors
  static const Color walletGrad1 = Color(0xFF0EA5E9); // sky-500
  static const Color walletGrad2 = Color(0xFF6366F1); // indigo-500
  static const Color walletGrad3 = Color(0xFF8B5CF6); // violet-500

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
          color: textPrimary, fontWeight: FontWeight.w800),
      displayMedium: GoogleFonts.nunito(
          color: textPrimary, fontWeight: FontWeight.w700),
      headlineLarge: GoogleFonts.nunito(
          color: textPrimary, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.nunito(
          color: textPrimary, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.nunito(
          color: textPrimary, fontWeight: FontWeight.w700, fontSize: 20),
      titleMedium: GoogleFonts.nunito(
          color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: GoogleFonts.nunito(
          color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: GoogleFonts.nunito(color: textPrimary, fontSize: 21),
      bodyMedium: GoogleFonts.nunito(color: textSecondary, fontSize: 19),
      bodySmall: GoogleFonts.nunito(color: textTertiary, fontSize: 17),
      labelLarge: GoogleFonts.nunito(
          color: textPrimary, fontWeight: FontWeight.w700, fontSize: 19),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: accent,
        error: error,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
        surfaceContainerHighest: surfaceElevated,
      ),
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border.withOpacity(0.6), width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textTertiary, fontSize: 19),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.nunito(
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border.withOpacity(0.5),
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: textSecondary),
    );
  }

  // Keep a lightTheme alias pointing to darkTheme for compatibility
  static ThemeData get lightTheme => darkTheme;
}
