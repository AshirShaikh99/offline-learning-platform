import 'package:flutter/material.dart';

/// Sleek black theme configuration for the application
class BlackTheme {
  // Core Colors
  static Color get backgroundColor => const Color(0xFF000000);
  static Color get surfaceColor => const Color(0xFF121212);
  static Color get cardColor => const Color(0xFF1E1E1E);
  static Color get primaryColor =>
      const Color(0xFFFF2D95); // Vibrant pink from existing theme
  static Color get accentColor => const Color(0xFF00E5FF); // Cyan accent
  static Color get secondaryAccentColor =>
      const Color(0xFF39FF14); // Neon green from existing theme
  static Color get textColor => const Color(0xFFFFFFFF);
  static Color get subtitleColor => const Color(0xFFB0B0B0);
  static Color get dividerColor => const Color(0xFF2C2C2C);

  // Success/Error Colors
  static Color get successColor => const Color(0xFF00E676); // Green
  static Color get errorColor =>
      const Color(0xFFFF3131); // Bright red from existing theme
  static Color get warningColor => const Color(0xFFFFD600); // Yellow

  // Text Styles
  static TextStyle get headlineLarge => const TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins',
    letterSpacing: -0.5,
    color: Color(0xFFFFFFFF),
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins',
    letterSpacing: -0.5,
    color: Color(0xFFFFFFFF),
  );

  static TextStyle get titleLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: Color(0xFFFFFFFF),
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    fontFamily: 'Poppins',
    color: Color(0xFFFFFFFF),
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    fontFamily: 'Poppins',
    color: Color(0xFFB0B0B0), // Subtle gray for body text
  );

  static TextStyle get labelLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
    color: Color(0xFFFFFFFF),
  );

  // Sleek Black Theme
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: secondaryAccentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        titleTextStyle: titleLarge.copyWith(color: textColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: primaryColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: surfaceColor,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: titleLarge,
        contentTextStyle: bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: bodyMedium.copyWith(color: textColor),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      iconTheme: IconThemeData(color: primaryColor, size: 28),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
        labelStyle: TextStyle(color: Colors.grey[300], fontSize: 16),
        suffixStyle: const TextStyle(color: Colors.white),
        prefixStyle: const TextStyle(color: Colors.white),
      ),
      dividerTheme: DividerThemeData(color: Colors.grey[800], thickness: 0.5),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFFAAAAAA),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return Colors.grey.withOpacity(0.5);
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accentColor),
    );
  }
}
