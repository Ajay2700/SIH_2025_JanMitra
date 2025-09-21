import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Official Government Colors
  static const Color primaryColor = Color(
    0xFF1E40AF,
  ); // Deep blue - trustworthy
  static const Color secondaryColor = Color(0xFF059669); // Professional green
  static const Color accentColor = Color(0xFFDC2626); // Official red for alerts

  // Light Theme Colors - Professional & Clean
  static const Color _lightPrimaryColor = primaryColor;
  static const Color _lightSecondaryColor = secondaryColor;
  static const Color _lightAccentColor = accentColor;
  static const Color _lightBackgroundColor = Color(
    0xFFFAFBFC,
  ); // Clean light background
  static const Color _lightSurfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color _lightErrorColor = Color(0xFFDC2626); // Professional red
  static const Color _lightCardColor = Color(0xFFFFFFFF); // Pure white cards
  static const Color _lightDividerColor = Color(0xFFE5E7EB); // Subtle grey

  // Dark Theme Colors - Professional & Modern
  static const Color _darkPrimaryColor = Color(
    0xFF3B82F6,
  ); // Lighter blue for dark mode
  static const Color _darkSecondaryColor = Color(
    0xFF10B981,
  ); // Lighter green for dark mode
  static const Color _darkAccentColor = Color(
    0xFFEF4444,
  ); // Lighter red for dark mode
  static const Color _darkBackgroundColor = Color(
    0xFF0F172A,
  ); // Professional dark background
  static const Color _darkSurfaceColor = Color(
    0xFF1E293B,
  ); // Professional dark surface
  static const Color _darkErrorColor = Color(0xFFEF4444); // Professional red
  static const Color _darkCardColor = Color(
    0xFF1E293B,
  ); // Professional dark cards
  static const Color _darkDividerColor = Color(
    0xFF334155,
  ); // Professional dark divider

  // Professional Status Colors
  static const Color submittedColor = Color(0xFFF59E0B); // Professional amber
  static const Color acknowledgedColor = Color(0xFF3B82F6); // Professional blue
  static const Color inProgressColor = Color(0xFF8B5CF6); // Professional purple
  static const Color resolvedColor = Color(0xFF10B981); // Professional green
  static const Color rejectedColor = Color(0xFFEF4444); // Professional red

  // Priority Colors
  static const Color lowPriorityColor = Color(0xFF66BB6A);
  static const Color mediumPriorityColor = Color(0xFFFFA000);
  static const Color highPriorityColor = Color(0xFFEF5350);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Font Family
  static const String fontFamily = 'Poppins';

  // Text Styles - Light Theme
  static const TextStyle _lightHeadingTextStyle = TextStyle(
    color: grey900,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle _lightBodyTextStyle = TextStyle(
    color: grey800,
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
  );

  static const TextStyle _lightCaptionTextStyle = TextStyle(
    color: grey600,
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  // Text Styles - Dark Theme
  static const TextStyle _darkHeadingTextStyle = TextStyle(
    color: white,
    fontFamily: fontFamily,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle _darkBodyTextStyle = TextStyle(
    color: grey300,
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
  );

  static const TextStyle _darkCaptionTextStyle = TextStyle(
    color: grey400,
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    fontFamily: fontFamily,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: _lightHeadingTextStyle.copyWith(
        fontSize: 20,
        color: white,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shadowColor: _lightPrimaryColor.withValues(alpha: 0.3),
    ),

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      onPrimary: white,
      secondary: _lightSecondaryColor,
      onSecondary: white,
      tertiary: _lightAccentColor,
      error: _lightErrorColor,
      onError: white,
      background: _lightBackgroundColor,
      onBackground: grey900,
      surface: _lightSurfaceColor,
      onSurface: grey800,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: _lightHeadingTextStyle.copyWith(fontSize: 32, height: 1.2),
      displayMedium: _lightHeadingTextStyle.copyWith(fontSize: 28, height: 1.2),
      displaySmall: _lightHeadingTextStyle.copyWith(fontSize: 24, height: 1.2),
      headlineLarge: _lightHeadingTextStyle.copyWith(fontSize: 22, height: 1.3),
      headlineMedium: _lightHeadingTextStyle.copyWith(
        fontSize: 20,
        height: 1.3,
      ),
      headlineSmall: _lightHeadingTextStyle.copyWith(fontSize: 18, height: 1.3),
      titleLarge: _lightHeadingTextStyle.copyWith(fontSize: 16, height: 1.4),
      titleMedium: _lightHeadingTextStyle.copyWith(
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: _lightHeadingTextStyle.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: _lightBodyTextStyle.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: _lightBodyTextStyle.copyWith(fontSize: 14, height: 1.5),
      bodySmall: _lightBodyTextStyle.copyWith(fontSize: 12, height: 1.5),
      labelLarge: _lightBodyTextStyle.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: _lightBodyTextStyle.copyWith(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: _lightCaptionTextStyle.copyWith(fontSize: 11, height: 1.4),
    ),

    // Button Themes - Professional Government Style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: white,
        elevation: 3,
        shadowColor: _lightPrimaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: _lightBodyTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        side: BorderSide(color: _lightPrimaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: _lightBodyTextStyle.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: _lightBodyTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: grey300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: grey300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightErrorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightErrorColor, width: 2),
      ),
      labelStyle: _lightBodyTextStyle.copyWith(color: grey700, fontSize: 14),
      hintStyle: _lightBodyTextStyle.copyWith(color: grey500, fontSize: 14),
      errorStyle: _lightBodyTextStyle.copyWith(
        color: _lightErrorColor,
        fontSize: 12,
      ),
    ),

    // Card settings - Professional Government Style
    cardColor: _lightCardColor,

    // Divider Theme - Professional
    dividerTheme: DividerThemeData(
      color: _lightDividerColor,
      thickness: 1.5,
      space: 32,
      indent: 16,
      endIndent: 16,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: grey200,
      disabledColor: grey200,
      selectedColor: _lightPrimaryColor.withOpacity(0.2),
      secondarySelectedColor: _lightPrimaryColor.withOpacity(0.2),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: _lightBodyTextStyle.copyWith(fontSize: 13),
      secondaryLabelStyle: _lightBodyTextStyle.copyWith(fontSize: 13),
      brightness: Brightness.light,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    fontFamily: fontFamily,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: _darkPrimaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: _darkHeadingTextStyle.copyWith(
        fontSize: 20,
        color: white,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
      shadowColor: _darkPrimaryColor.withValues(alpha: 0.3),
    ),

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      onPrimary: white,
      secondary: _darkSecondaryColor,
      onSecondary: white,
      tertiary: _darkAccentColor,
      error: _darkErrorColor,
      onError: white,
      background: _darkBackgroundColor,
      onBackground: grey200,
      surface: _darkSurfaceColor,
      onSurface: grey300,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: _darkHeadingTextStyle.copyWith(fontSize: 32, height: 1.2),
      displayMedium: _darkHeadingTextStyle.copyWith(fontSize: 28, height: 1.2),
      displaySmall: _darkHeadingTextStyle.copyWith(fontSize: 24, height: 1.2),
      headlineLarge: _darkHeadingTextStyle.copyWith(fontSize: 22, height: 1.3),
      headlineMedium: _darkHeadingTextStyle.copyWith(fontSize: 20, height: 1.3),
      headlineSmall: _darkHeadingTextStyle.copyWith(fontSize: 18, height: 1.3),
      titleLarge: _darkHeadingTextStyle.copyWith(fontSize: 16, height: 1.4),
      titleMedium: _darkHeadingTextStyle.copyWith(
        fontSize: 15,
        height: 1.4,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: _darkHeadingTextStyle.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: _darkBodyTextStyle.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: _darkBodyTextStyle.copyWith(fontSize: 14, height: 1.5),
      bodySmall: _darkBodyTextStyle.copyWith(fontSize: 12, height: 1.5),
      labelLarge: _darkBodyTextStyle.copyWith(
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      labelMedium: _darkBodyTextStyle.copyWith(
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: _darkCaptionTextStyle.copyWith(fontSize: 11, height: 1.4),
    ),

    // Button Themes - Professional Government Style
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: white,
        elevation: 6,
        shadowColor: _darkPrimaryColor.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: _darkBodyTextStyle.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkAccentColor,
        side: BorderSide(color: _darkAccentColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: _darkBodyTextStyle.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkAccentColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: _darkBodyTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: grey700, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: grey700, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkAccentColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkErrorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkErrorColor, width: 2),
      ),
      labelStyle: _darkBodyTextStyle.copyWith(color: grey400, fontSize: 14),
      hintStyle: _darkBodyTextStyle.copyWith(color: grey600, fontSize: 14),
      errorStyle: _darkBodyTextStyle.copyWith(
        color: _darkErrorColor,
        fontSize: 12,
      ),
    ),

    // Card settings - Professional Government Style
    cardColor: _darkCardColor,

    // Divider Theme - Professional
    dividerTheme: DividerThemeData(
      color: _darkDividerColor,
      thickness: 1.5,
      space: 32,
      indent: 16,
      endIndent: 16,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: grey800,
      disabledColor: grey800,
      selectedColor: _darkPrimaryColor.withOpacity(0.3),
      secondarySelectedColor: _darkPrimaryColor.withOpacity(0.3),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: _darkBodyTextStyle.copyWith(fontSize: 13),
      secondaryLabelStyle: _darkBodyTextStyle.copyWith(fontSize: 13),
      brightness: Brightness.dark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
  );
}
