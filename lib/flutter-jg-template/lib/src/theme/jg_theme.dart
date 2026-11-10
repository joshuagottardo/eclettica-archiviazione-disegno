import 'package:flutter/material.dart';
import '../foundations/jg_colors.dart';
import '../foundations/jg_sizes.dart';
import '../foundations/jg_typography.dart';
import 'extensions/jg_color_theme.dart';
import 'extensions/jg_effects.dart';
import 'extensions/jg_sizes_theme.dart';

/// Configurazione del tema principale del Design System [jg_design_system].
///
/// Espone i temi Dark e Light pronti per essere applicati a [MaterialApp].
class JgTheme {
  JgTheme._();

  /// Ottiene il tema scuro predefinito del Design System.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: JgColors.darkBackground,
      canvasColor: JgColors.darkBackground,
      cardColor: JgColors.darkSurface,
      dividerColor: JgColors.darkDivider,
      iconTheme: const IconThemeData(color: JgColors.darkTextPrimary),

      // Tipografia
      textTheme: JgTypography.createTextTheme(
        textPrimary: JgColors.darkTextPrimary,
        textSecondary: JgColors.darkTextSecondary,
        textMuted: JgColors.darkTextMuted,
      ),

      // Schema Colori Standard
      colorScheme: const ColorScheme.dark(
        primary: JgColors.darkAccent,
        onPrimary: Color(0xFF000000), // Nero su pulsanti bianchi
        secondary: JgColors.darkAccentMuted,
        onSecondary: Color(0xFF000000),
        surface: JgColors.darkBackground,
        onSurface: JgColors.darkTextPrimary,
        error: JgColors.darkError,
        onError: Color(0xFF000000),
      ),

      // Estensioni del Tema
      extensions: [
        JgColorTheme.darkDefault(),
        JgEffects.darkDefault(),
        JgSizesTheme.defaultSizes(),
      ],

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: JgColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
          color: JgColors.darkTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: JgColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
          side: const BorderSide(color: JgColors.darkBorder, width: JgSizes.borderThin),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: JgColors.darkDivider,
        thickness: JgSizes.borderThin,
        space: 1.0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JgColors.darkAccent,
          foregroundColor: const Color(0xFF000000),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: JgSizes.space24,
            vertical: JgSizes.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }

  /// Ottiene il tema chiaro predefinito del Design System (Swiss Minimal Light).
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: JgColors.lightBackground,
      canvasColor: JgColors.lightBackground,
      cardColor: JgColors.lightSurface,
      dividerColor: JgColors.lightDivider,
      iconTheme: const IconThemeData(color: JgColors.lightTextPrimary),

      // Tipografia
      textTheme: JgTypography.createTextTheme(
        textPrimary: JgColors.lightTextPrimary,
        textSecondary: JgColors.lightTextSecondary,
        textMuted: JgColors.lightTextMuted,
      ),

      // Schema Colori Standard
      colorScheme: const ColorScheme.light(
        primary: JgColors.lightAccent,
        onPrimary: Color(0xFFFFFFFF), // Bianco su pulsanti neri
        secondary: JgColors.lightAccentMuted,
        onSecondary: Color(0xFFFFFFFF),
        surface: JgColors.lightBackground,
        onSurface: JgColors.lightTextPrimary,
        error: JgColors.lightError,
        onError: Color(0xFFFFFFFF),
      ),

      // Estensioni del Tema
      extensions: [
        JgColorTheme.lightDefault(),
        JgEffects.lightDefault(),
        JgSizesTheme.defaultSizes(),
      ],

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: JgColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w800,
          color: JgColors.lightTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: JgColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
          side: const BorderSide(color: JgColors.lightBorder, width: JgSizes.borderThin),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: JgColors.lightDivider,
        thickness: JgSizes.borderThin,
        space: 1.0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: JgColors.lightAccent,
          foregroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: JgSizes.space24,
            vertical: JgSizes.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
