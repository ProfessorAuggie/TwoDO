import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF7C3AED); // Vibrant Purple
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color primaryContainer = Color(0xFFF3E8FF);

  // Secondary Colors
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryContainer = Color(0xFFCFFAFE);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF10B981); // Emerald
  static const Color tertiaryLight = Color(0xFF34D399);
  static const Color tertiaryDark = Color(0xFF059669);
  static const Color tertiaryContainer = Color(0xFFD1FAE5);

  // Error Colors
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFCA5A5);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);

  // Warning Colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  // Success Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFA7F3D0);
  static const Color successDark = Color(0xFF059669);

  // Info Colors
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);
  static const Color infoDark = Color(0xFF1D4ED8);

  // Neutral Colors - Light Theme
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF9FAFB);
  static const Color lightGray2 = Color(0xFFF3F4F6);
  static const Color lightGray3 = Color(0xFFE5E7EB);
  static const Color lightGray4 = Color(0xFFD1D5DB);
  static const Color gray = Color(0xFF9CA3AF);
  static const Color darkGray = Color(0xFF6B7280);

  // Neutral Colors - Dark Theme
  static const Color darkBg = Color(0xFF0F172A); // Slate 900
  static const Color darkBg2 = Color(0xFF1E293B); // Slate 800
  static const Color darkBg3 = Color(0xFF334155); // Slate 700
  static const Color darkBg4 = Color(0xFF475569); // Slate 600
  static const Color darkText = Color(0xFFF1F5F9); // Slate 100
  static const Color darkText2 = Color(0xFFCBD5E1); // Slate 200
  static const Color black = Color(0xFF000000);

  // Gradient Colors
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
}

class AppTheme {
  // Light Theme Colors
  static final lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.white,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.secondaryDark,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.white,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.tertiaryDark,
    error: AppColors.error,
    onError: AppColors.white,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.errorDark,
    background: AppColors.white,
    onBackground: AppColors.black,
    surface: AppColors.lightGray,
    onSurface: AppColors.black,
    outline: AppColors.lightGray4,
    outlineVariant: AppColors.lightGray3,
    surfaceVariant: AppColors.lightGray2,
  );

  // Dark Theme Colors
  static final darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.primaryDark,
    primaryContainer: Color(0xFF5B21B6),
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.secondaryDark,
    secondaryContainer: Color(0xFF0D5F6F),
    onSecondaryContainer: AppColors.secondaryLight,
    tertiary: AppColors.tertiaryLight,
    onTertiary: AppColors.tertiaryDark,
    tertiaryContainer: Color(0xFF0A5F3E),
    onTertiaryContainer: AppColors.tertiaryLight,
    error: AppColors.errorLight,
    onError: AppColors.errorDark,
    errorContainer: Color(0xFF7C2D21),
    onErrorContainer: AppColors.errorLight,
    background: AppColors.darkBg,
    onBackground: AppColors.darkText,
    surface: AppColors.darkBg2,
    onSurface: AppColors.darkText,
    outline: AppColors.darkBg3,
    outlineVariant: AppColors.darkBg4,
    surfaceVariant: AppColors.darkBg3,
  );

  // Light Theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _titleMedium(AppColors.black),
      ),
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightGray3),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightGray2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightGray3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: _bodyMedium(AppColors.darkGray),
        labelStyle: _bodyMedium(AppColors.black),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: _labelLarge(AppColors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: _labelLarge(AppColors.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: _labelLarge(AppColors.primary),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.lightGray3,
        thickness: 1,
        space: 16,
      ),
      textTheme: _buildLightTextTheme(),
    );
  }

  // Dark Theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg2,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: _titleMedium(AppColors.darkText),
      ),
      cardTheme: CardTheme(
        color: AppColors.darkBg2,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBg3),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.primaryDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBg3,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBg4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBg4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.errorLight, width: 2),
        ),
        hintStyle: _bodyMedium(AppColors.darkText2),
        labelStyle: _bodyMedium(AppColors.darkText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primaryDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: _labelLarge(AppColors.primaryDark),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: _labelLarge(AppColors.primaryLight),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: _labelLarge(AppColors.primaryLight),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.darkBg3,
        thickness: 1,
        space: 16,
      ),
      textTheme: _buildDarkTextTheme(),
    );
  }

  // Text Themes
  static TextTheme _buildLightTextTheme() {
    return TextTheme(
      displayLarge: _displayLarge(AppColors.black),
      displayMedium: _displayMedium(AppColors.black),
      displaySmall: _displaySmall(AppColors.black),
      headlineLarge: _headlineLarge(AppColors.black),
      headlineMedium: _headlineMedium(AppColors.black),
      headlineSmall: _headlineSmall(AppColors.black),
      titleLarge: _titleLarge(AppColors.black),
      titleMedium: _titleMedium(AppColors.black),
      titleSmall: _titleSmall(AppColors.black),
      bodyLarge: _bodyLarge(AppColors.black),
      bodyMedium: _bodyMedium(AppColors.black),
      bodySmall: _bodySmall(AppColors.darkGray),
      labelLarge: _labelLarge(AppColors.black),
      labelMedium: _labelMedium(AppColors.black),
      labelSmall: _labelSmall(AppColors.darkGray),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: _displayLarge(AppColors.darkText),
      displayMedium: _displayMedium(AppColors.darkText),
      displaySmall: _displaySmall(AppColors.darkText),
      headlineLarge: _headlineLarge(AppColors.darkText),
      headlineMedium: _headlineMedium(AppColors.darkText),
      headlineSmall: _headlineSmall(AppColors.darkText),
      titleLarge: _titleLarge(AppColors.darkText),
      titleMedium: _titleMedium(AppColors.darkText),
      titleSmall: _titleSmall(AppColors.darkText2),
      bodyLarge: _bodyLarge(AppColors.darkText),
      bodyMedium: _bodyMedium(AppColors.darkText),
      bodySmall: _bodySmall(AppColors.darkText2),
      labelLarge: _labelLarge(AppColors.darkText),
      labelMedium: _labelMedium(AppColors.darkText),
      labelSmall: _labelSmall(AppColors.darkText2),
    );
  }

  // Text Styles
  static TextStyle _displayLarge(Color color) => TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _displayMedium(Color color) => TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _displaySmall(Color color) => TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _headlineLarge(Color color) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _headlineMedium(Color color) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _headlineSmall(Color color) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _titleLarge(Color color) => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _titleMedium(Color color) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _titleSmall(Color color) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: color,
    fontFamily: 'Poppins',
  );

  static TextStyle _bodyLarge(Color color) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: color,
    fontFamily: 'Inter',
  );

  static TextStyle _bodyMedium(Color color) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color,
    fontFamily: 'Inter',
  );

  static TextStyle _bodySmall(Color color) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color,
    fontFamily: 'Inter',
  );

  static TextStyle _labelLarge(Color color) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: color,
    fontFamily: 'Inter',
  );

  static TextStyle _labelMedium(Color color) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: color,
    fontFamily: 'Inter',
  );

  static TextStyle _labelSmall(Color color) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: color,
    fontFamily: 'Inter',
  );
}
