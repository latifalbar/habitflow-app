import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Heading Styles (Poppins)
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextStyle h5 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle h6 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body Styles (Inter)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Label Styles
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Caption Styles
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: Colors.grey[600],
  );

  static TextStyle overline = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Button Styles
  static TextStyle buttonLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  static TextStyle buttonMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  // Number Styles (for stats, counters, etc.)
  static TextStyle numberLarge = GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    height: 1,
  );

  static TextStyle numberMedium = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1,
  );

  static TextStyle numberSmall = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1,
  );

  // Special Styles
  static TextStyle quote = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.6,
  );

  static TextStyle code = GoogleFonts.sourceCodePro(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Text Themes for Material Design
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: h1.copyWith(color: Colors.black87),
    displayMedium: h2.copyWith(color: Colors.black87),
    displaySmall: h3.copyWith(color: Colors.black87),
    headlineLarge: h4.copyWith(color: Colors.black87),
    headlineMedium: h5.copyWith(color: Colors.black87),
    headlineSmall: h6.copyWith(color: Colors.black87),
    titleLarge: bodyLarge.copyWith(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: bodyMedium.copyWith(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: bodySmall.copyWith(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: bodyLarge.copyWith(color: Colors.black87),
    bodyMedium: bodyMedium.copyWith(color: Colors.black87),
    bodySmall: bodySmall.copyWith(color: Colors.black54),
    labelLarge: labelLarge.copyWith(color: Colors.black87),
    labelMedium: labelMedium.copyWith(color: Colors.black87),
    labelSmall: labelSmall.copyWith(color: Colors.black54),
  );

  static TextTheme darkTextTheme = TextTheme(
    displayLarge: h1.copyWith(color: Colors.white),
    displayMedium: h2.copyWith(color: Colors.white),
    displaySmall: h3.copyWith(color: Colors.white),
    headlineLarge: h4.copyWith(color: Colors.white),
    headlineMedium: h5.copyWith(color: Colors.white),
    headlineSmall: h6.copyWith(color: Colors.white),
    titleLarge: bodyLarge.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: bodyMedium.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: bodySmall.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: bodyLarge.copyWith(color: Colors.white),
    bodyMedium: bodyMedium.copyWith(color: Colors.white),
    bodySmall: bodySmall.copyWith(color: Colors.white70),
    labelLarge: labelLarge.copyWith(color: Colors.white),
    labelMedium: labelMedium.copyWith(color: Colors.white),
    labelSmall: labelSmall.copyWith(color: Colors.white70),
  );
}
