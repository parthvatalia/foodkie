// core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors - More subtle for minimal design
  static const Color primaryColor = Color(0xFF5D6CC6); // Soft blue
  static const Color accentColor = Color(0xFF64B5F6); // Light blue
  static const Color secondaryColor = Color(0xFF81C784); // Soft green

  // Semantic Colors - More muted
  static const Color successColor = Color(0xFF81C784); // Soft green
  static const Color warningColor = Color(0xFFFFD54F); // Soft amber
  static const Color errorColor = Color(0xFFE57373); // Soft red
  static const Color infoColor = Color(0xFF64B5F6); // Soft blue

  // Background Colors - Pure white for main background
  static const Color lightBackground = Colors.white;
  static const Color darkBackground = Color(0xFF121212);

  // Text Colors - Softer black for better readability
  static const Color lightTextColor = Color(0xFF424242); // Dark grey instead of pure black
  static const Color darkTextColor = Color(0xFFF5F5F5);
  static const Color lightSubtextColor = Color(0xFF9E9E9E); // Medium grey
  static const Color darkSubtextColor = Color(0xFFBDBDBD);

  // Other Colors
  static const Color cardLightColor = Colors.white;
  static const Color cardDarkColor = Color(0xFF1E1E1E);
  static const Color dividerColor = Color(0xFFEEEEEE); // Very light grey for subtle dividers

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600, // Slightly lighter for minimal feel
  );

  static TextStyle get subheadingStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium weight for subtlety
  );

  static TextStyle get bodyStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get smallStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Light Theme - Minimalist white design
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: secondaryColor,
        background: lightBackground,
        surface: Colors.white,
        onSurface: lightTextColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: lightBackground,
      cardColor: cardLightColor,
      dividerColor: dividerColor,
      textTheme: TextTheme(
        displayLarge: headingStyle.copyWith(color: lightTextColor),
        displayMedium: subheadingStyle.copyWith(color: lightTextColor),
        bodyLarge: bodyStyle.copyWith(color: lightTextColor),
        bodyMedium: smallStyle.copyWith(color: lightSubtextColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: lightTextColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(color: lightTextColor),
        titleTextStyle: subheadingStyle.copyWith(color: lightTextColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0, // No shadow for minimal look
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200), // Lighter border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200), // Lighter border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 1.5), // Thinner focus border
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: errorColor.withOpacity(0.7)), // Softer error
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: cardLightColor,
        elevation: 0.5, // Very subtle shadow
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100), // Very subtle border
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2, // Minimal shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconTheme: IconThemeData(
        color: lightTextColor,
        size: 24,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        disabledColor: Colors.grey.shade200,
        selectedColor: primaryColor.withOpacity(0.1),
        secondarySelectedColor: primaryColor.withOpacity(0.2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        labelStyle: smallStyle.copyWith(color: lightTextColor),
        secondaryLabelStyle: smallStyle.copyWith(color: primaryColor),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // Subtle divider that won't stand out too much
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Dark Theme - Keeping this for completeness but focusing on light theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: secondaryColor,
        background: darkBackground,
        surface: cardDarkColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: darkBackground,
      cardColor: cardDarkColor,
      dividerColor: dividerColor.withOpacity(0.3),
      textTheme: TextTheme(
        displayLarge: headingStyle.copyWith(color: darkTextColor),
        displayMedium: subheadingStyle.copyWith(color: darkTextColor),
        bodyLarge: bodyStyle.copyWith(color: darkTextColor),
        bodyMedium: smallStyle.copyWith(color: darkSubtextColor),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardDarkColor,
        foregroundColor: darkTextColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: cardDarkColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        color: cardDarkColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}