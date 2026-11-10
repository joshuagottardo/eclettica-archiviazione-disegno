import 'dart:ui';
import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';

/// Estensione del tema per definire le dimensioni e le spaziature dei controlli del Design System [jg_design_system].
///
/// Consente di configurare a livello di tema globale i padding, i raggi dei bordi e
/// le altezze per le tre varianti dimensionali (small, medium, large).
class JgSizesTheme extends ThemeExtension<JgSizesTheme> {
  // Altezze dei controlli
  final double controlHeightSmall;
  final double controlHeightMedium;
  final double controlHeightLarge;

  // Raggi dei bordi dei controlli
  final double borderRadiusSmall;
  final double borderRadiusMedium;
  final double borderRadiusLarge;

  // Padding interni bottoni
  final EdgeInsets buttonPaddingSmall;
  final EdgeInsets buttonPaddingMedium;
  final EdgeInsets buttonPaddingLarge;

  // Padding interni text fields
  final EdgeInsets textFieldPaddingSmall;
  final EdgeInsets textFieldPaddingMedium;
  final EdgeInsets textFieldPaddingLarge;

  // Dimensioni controlli di selezione (checkbox / radio button)
  final double checkboxSizeSmall;
  final double checkboxSizeMedium;
  final double checkboxSizeLarge;

  final double radioButtonSizeSmall;
  final double radioButtonSizeMedium;
  final double radioButtonSizeLarge;

  // Dimensioni degli switch
  final double switchWidthSmall;
  final double switchWidthMedium;
  final double switchWidthLarge;

  const JgSizesTheme({
    required this.controlHeightSmall,
    required this.controlHeightMedium,
    required this.controlHeightLarge,
    required this.borderRadiusSmall,
    required this.borderRadiusMedium,
    required this.borderRadiusLarge,
    required this.buttonPaddingSmall,
    required this.buttonPaddingMedium,
    required this.buttonPaddingLarge,
    required this.textFieldPaddingSmall,
    required this.textFieldPaddingMedium,
    required this.textFieldPaddingLarge,
    required this.checkboxSizeSmall,
    required this.checkboxSizeMedium,
    required this.checkboxSizeLarge,
    required this.radioButtonSizeSmall,
    required this.radioButtonSizeMedium,
    required this.radioButtonSizeLarge,
    required this.switchWidthSmall,
    required this.switchWidthMedium,
    required this.switchWidthLarge,
  });

  /// Costruisce l'estensione con le dimensioni geometriche predefinite.
  factory JgSizesTheme.defaultSizes() {
    return const JgSizesTheme(
      controlHeightSmall: 32.0,
      controlHeightMedium: 48.0,
      controlHeightLarge: 56.0,
      borderRadiusSmall: JgSizes.radiusSmall,
      borderRadiusMedium: JgSizes.radiusMedium,
      borderRadiusLarge: JgSizes.radiusLarge,
      buttonPaddingSmall: EdgeInsets.symmetric(horizontal: JgSizes.space16, vertical: JgSizes.space8),
      buttonPaddingMedium: EdgeInsets.symmetric(horizontal: JgSizes.space24, vertical: JgSizes.space16),
      buttonPaddingLarge: EdgeInsets.symmetric(horizontal: JgSizes.space32, vertical: JgSizes.space20),
      textFieldPaddingSmall: EdgeInsets.symmetric(horizontal: JgSizes.space12, vertical: JgSizes.space8),
      textFieldPaddingMedium: EdgeInsets.symmetric(horizontal: JgSizes.space16, vertical: JgSizes.space16),
      textFieldPaddingLarge: EdgeInsets.symmetric(horizontal: JgSizes.space20, vertical: JgSizes.space20),
      checkboxSizeSmall: 14.0,
      checkboxSizeMedium: 18.0,
      checkboxSizeLarge: 22.0,
      radioButtonSizeSmall: 14.0,
      radioButtonSizeMedium: 18.0,
      radioButtonSizeLarge: 22.0,
      switchWidthSmall: 38.0,
      switchWidthMedium: 48.0,
      switchWidthLarge: 58.0,
    );
  }

  @override
  ThemeExtension<JgSizesTheme> copyWith({
    double? controlHeightSmall,
    double? controlHeightMedium,
    double? controlHeightLarge,
    double? borderRadiusSmall,
    double? borderRadiusMedium,
    double? borderRadiusLarge,
    EdgeInsets? buttonPaddingSmall,
    EdgeInsets? buttonPaddingMedium,
    EdgeInsets? buttonPaddingLarge,
    EdgeInsets? textFieldPaddingSmall,
    EdgeInsets? textFieldPaddingMedium,
    EdgeInsets? textFieldPaddingLarge,
    double? checkboxSizeSmall,
    double? checkboxSizeMedium,
    double? checkboxSizeLarge,
    double? radioButtonSizeSmall,
    double? radioButtonSizeMedium,
    double? radioButtonSizeLarge,
    double? switchWidthSmall,
    double? switchWidthMedium,
    double? switchWidthLarge,
  }) {
    return JgSizesTheme(
      controlHeightSmall: controlHeightSmall ?? this.controlHeightSmall,
      controlHeightMedium: controlHeightMedium ?? this.controlHeightMedium,
      controlHeightLarge: controlHeightLarge ?? this.controlHeightLarge,
      borderRadiusSmall: borderRadiusSmall ?? this.borderRadiusSmall,
      borderRadiusMedium: borderRadiusMedium ?? this.borderRadiusMedium,
      borderRadiusLarge: borderRadiusLarge ?? this.borderRadiusLarge,
      buttonPaddingSmall: buttonPaddingSmall ?? this.buttonPaddingSmall,
      buttonPaddingMedium: buttonPaddingMedium ?? this.buttonPaddingMedium,
      buttonPaddingLarge: buttonPaddingLarge ?? this.buttonPaddingLarge,
      textFieldPaddingSmall: textFieldPaddingSmall ?? this.textFieldPaddingSmall,
      textFieldPaddingMedium: textFieldPaddingMedium ?? this.textFieldPaddingMedium,
      textFieldPaddingLarge: textFieldPaddingLarge ?? this.textFieldPaddingLarge,
      checkboxSizeSmall: checkboxSizeSmall ?? this.checkboxSizeSmall,
      checkboxSizeMedium: checkboxSizeMedium ?? this.checkboxSizeMedium,
      checkboxSizeLarge: checkboxSizeLarge ?? this.checkboxSizeLarge,
      radioButtonSizeSmall: radioButtonSizeSmall ?? this.radioButtonSizeSmall,
      radioButtonSizeMedium: radioButtonSizeMedium ?? this.radioButtonSizeMedium,
      radioButtonSizeLarge: radioButtonSizeLarge ?? this.radioButtonSizeLarge,
      switchWidthSmall: switchWidthSmall ?? this.switchWidthSmall,
      switchWidthMedium: switchWidthMedium ?? this.switchWidthMedium,
      switchWidthLarge: switchWidthLarge ?? this.switchWidthLarge,
    );
  }

  @override
  ThemeExtension<JgSizesTheme> lerp(ThemeExtension<JgSizesTheme>? other, double t) {
    if (other is! JgSizesTheme) return this;
    return JgSizesTheme(
      controlHeightSmall: lerpDouble(controlHeightSmall, other.controlHeightSmall, t) ?? controlHeightSmall,
      controlHeightMedium: lerpDouble(controlHeightMedium, other.controlHeightMedium, t) ?? controlHeightMedium,
      controlHeightLarge: lerpDouble(controlHeightLarge, other.controlHeightLarge, t) ?? controlHeightLarge,
      borderRadiusSmall: lerpDouble(borderRadiusSmall, other.borderRadiusSmall, t) ?? borderRadiusSmall,
      borderRadiusMedium: lerpDouble(borderRadiusMedium, other.borderRadiusMedium, t) ?? borderRadiusMedium,
      borderRadiusLarge: lerpDouble(borderRadiusLarge, other.borderRadiusLarge, t) ?? borderRadiusLarge,
      buttonPaddingSmall: EdgeInsets.lerp(buttonPaddingSmall, other.buttonPaddingSmall, t) ?? buttonPaddingSmall,
      buttonPaddingMedium: EdgeInsets.lerp(buttonPaddingMedium, other.buttonPaddingMedium, t) ?? buttonPaddingMedium,
      buttonPaddingLarge: EdgeInsets.lerp(buttonPaddingLarge, other.buttonPaddingLarge, t) ?? buttonPaddingLarge,
      textFieldPaddingSmall: EdgeInsets.lerp(textFieldPaddingSmall, other.textFieldPaddingSmall, t) ?? textFieldPaddingSmall,
      textFieldPaddingMedium: EdgeInsets.lerp(textFieldPaddingMedium, other.textFieldPaddingMedium, t) ?? textFieldPaddingMedium,
      textFieldPaddingLarge: EdgeInsets.lerp(textFieldPaddingLarge, other.textFieldPaddingLarge, t) ?? textFieldPaddingLarge,
      checkboxSizeSmall: lerpDouble(checkboxSizeSmall, other.checkboxSizeSmall, t) ?? checkboxSizeSmall,
      checkboxSizeMedium: lerpDouble(checkboxSizeMedium, other.checkboxSizeMedium, t) ?? checkboxSizeMedium,
      checkboxSizeLarge: lerpDouble(checkboxSizeLarge, other.checkboxSizeLarge, t) ?? checkboxSizeLarge,
      radioButtonSizeSmall: lerpDouble(radioButtonSizeSmall, other.radioButtonSizeSmall, t) ?? radioButtonSizeSmall,
      radioButtonSizeMedium: lerpDouble(radioButtonSizeMedium, other.radioButtonSizeMedium, t) ?? radioButtonSizeMedium,
      radioButtonSizeLarge: lerpDouble(radioButtonSizeLarge, other.radioButtonSizeLarge, t) ?? radioButtonSizeLarge,
      switchWidthSmall: lerpDouble(switchWidthSmall, other.switchWidthSmall, t) ?? switchWidthSmall,
      switchWidthMedium: lerpDouble(switchWidthMedium, other.switchWidthMedium, t) ?? switchWidthMedium,
      switchWidthLarge: lerpDouble(switchWidthLarge, other.switchWidthLarge, t) ?? switchWidthLarge,
    );
  }
}

/// Permette di accedere rapidamente alle dimensioni configurate tramite `context.jgSizes`.
extension JgSizesThemeContext on BuildContext {
  JgSizesTheme get jgSizes => Theme.of(this).extension<JgSizesTheme>() ?? JgSizesTheme.defaultSizes();
}
