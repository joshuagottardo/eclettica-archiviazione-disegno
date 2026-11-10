import 'package:flutter/material.dart';
import '../../foundations/jg_colors.dart';

/// Estensione del tema per definire la tavolozza di colori del Design System [jg_design_system].
///
/// Gestisce in modo dinamico le variazioni cromatiche tra i diversi temi (Light e Dark),
/// consentendo la sfumatura graduale (lerp) durante le transizioni.
class JgColorTheme extends ThemeExtension<JgColorTheme> {
  final Color background;
  final Color surface;
  final Color surfaceCard;
  final Color accent;
  final Color accentMuted;
  final Color border;
  final Color borderLight;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color glassBackground;
  final Color glassBorderStart;
  final Color glassBorderEnd;
  final Color hoverOverlay;

  const JgColorTheme({
    required this.background,
    required this.surface,
    required this.surfaceCard,
    required this.accent,
    required this.accentMuted,
    required this.border,
    required this.borderLight,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.glassBackground,
    required this.glassBorderStart,
    required this.glassBorderEnd,
    required this.hoverOverlay,
  });

  /// Costruisce l'estensione con i colori predefiniti per la Dark Mode (OLED).
  factory JgColorTheme.darkDefault() {
    return const JgColorTheme(
      background: JgColors.darkBackground,
      surface: JgColors.darkSurface,
      surfaceCard: JgColors.darkSurfaceCard,
      accent: JgColors.darkAccent,
      accentMuted: JgColors.darkAccentMuted,
      border: JgColors.darkBorder,
      borderLight: JgColors.darkBorderLight,
      divider: JgColors.darkDivider,
      textPrimary: JgColors.darkTextPrimary,
      textSecondary: JgColors.darkTextSecondary,
      textMuted: JgColors.darkTextMuted,
      textDisabled: JgColors.darkTextDisabled,
      success: JgColors.darkSuccess,
      warning: JgColors.darkWarning,
      error: JgColors.darkError,
      info: JgColors.darkInfo,
      glassBackground: JgColors.darkGlassBackground,
      glassBorderStart: JgColors.darkGlassBorderStart,
      glassBorderEnd: JgColors.darkGlassBorderEnd,
      hoverOverlay: JgColors.darkHoverOverlay,
    );
  }

  /// Costruisce l'estensione con i colori predefiniti per la Light Mode (Swiss Minimal).
  factory JgColorTheme.lightDefault() {
    return const JgColorTheme(
      background: JgColors.lightBackground,
      surface: JgColors.lightSurface,
      surfaceCard: JgColors.lightSurfaceCard,
      accent: JgColors.lightAccent,
      accentMuted: JgColors.lightAccentMuted,
      border: JgColors.lightBorder,
      borderLight: JgColors.lightBorderLight,
      divider: JgColors.lightDivider,
      textPrimary: JgColors.lightTextPrimary,
      textSecondary: JgColors.lightTextSecondary,
      textMuted: JgColors.lightTextMuted,
      textDisabled: JgColors.lightTextDisabled,
      success: JgColors.lightSuccess,
      warning: JgColors.lightWarning,
      error: JgColors.lightError,
      info: JgColors.lightInfo,
      glassBackground: JgColors.lightGlassBackground,
      glassBorderStart: JgColors.lightGlassBorderStart,
      glassBorderEnd: JgColors.lightGlassBorderEnd,
      hoverOverlay: JgColors.lightHoverOverlay,
    );
  }

  @override
  ThemeExtension<JgColorTheme> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceCard,
    Color? accent,
    Color? accentMuted,
    Color? border,
    Color? borderLight,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? glassBackground,
    Color? glassBorderStart,
    Color? glassBorderEnd,
    Color? hoverOverlay,
  }) {
    return JgColorTheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      glassBackground: glassBackground ?? this.glassBackground,
      glassBorderStart: glassBorderStart ?? this.glassBorderStart,
      glassBorderEnd: glassBorderEnd ?? this.glassBorderEnd,
      hoverOverlay: hoverOverlay ?? this.hoverOverlay,
    );
  }

  @override
  ThemeExtension<JgColorTheme> lerp(ThemeExtension<JgColorTheme>? other, double t) {
    if (other is! JgColorTheme) return this;
    return JgColorTheme(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t) ?? surfaceCard,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t) ?? accentMuted,
      border: Color.lerp(border, other.border, t) ?? border,
      borderLight: Color.lerp(borderLight, other.borderLight, t) ?? borderLight,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
      glassBackground: Color.lerp(glassBackground, other.glassBackground, t) ?? glassBackground,
      glassBorderStart: Color.lerp(glassBorderStart, other.glassBorderStart, t) ?? glassBorderStart,
      glassBorderEnd: Color.lerp(glassBorderEnd, other.glassBorderEnd, t) ?? glassBorderEnd,
      hoverOverlay: Color.lerp(hoverOverlay, other.hoverOverlay, t) ?? hoverOverlay,
    );
  }
}

/// Permette di accedere rapidamente ai colori del tema corretto tramite `context.jgColors`.
extension JgThemeContext on BuildContext {
  JgColorTheme get jgColors => Theme.of(this).extension<JgColorTheme>() ?? JgColorTheme.darkDefault();
}
