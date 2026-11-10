import 'dart:ui';
import 'package:flutter/material.dart';
import '../../foundations/jg_colors.dart';
import '../../foundations/jg_sizes.dart';

/// Estensione del tema per effetti visivi avanzati (glassmorphism, animazioni, ombre).
///
/// Permette di gestire stili non supportati nativamente nei campi di [ThemeData].
class JgEffects extends ThemeExtension<JgEffects> {
  final double glassBlurX;
  final double glassBlurY;
  final Gradient glassBorderGradient;
  final List<BoxShadow> glassShadow;
  final Color glassColor;
  final Duration fluidDuration;
  final Curve fluidCurve;

  const JgEffects({
    required this.glassBlurX,
    required this.glassBlurY,
    required this.glassBorderGradient,
    required this.glassShadow,
    required this.glassColor,
    required this.fluidDuration,
    required this.fluidCurve,
  });

  /// Configurazione predefinita per l'effetto vetro Apple in Dark Mode.
  factory JgEffects.darkDefault() {
    return const JgEffects(
      glassBlurX: JgSizes.blurGlass,
      glassBlurY: JgSizes.blurGlass,
      glassColor: JgColors.darkGlassBackground,
      fluidDuration: Duration(milliseconds: 200),
      fluidCurve: Curves.easeOutQuart,
      glassBorderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          JgColors.darkGlassBorderStart,
          JgColors.darkGlassBorderEnd,
        ],
        stops: [0.0, 1.0],
      ),
      glassShadow: [
        BoxShadow(
          color: Color(0x7F000000), // Ombra scura e concentrata per fondi scuri
          blurRadius: 32.0,
          offset: Offset(0, 16),
          spreadRadius: -8.0,
        ),
      ],
    );
  }

  /// Configurazione predefinita per l'effetto vetro Apple in Light Mode.
  factory JgEffects.lightDefault() {
    return const JgEffects(
      glassBlurX: JgSizes.blurGlass,
      glassBlurY: JgSizes.blurGlass,
      glassColor: JgColors.lightGlassBackground,
      fluidDuration: Duration(milliseconds: 200),
      fluidCurve: Curves.easeOutQuart,
      glassBorderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          JgColors.lightGlassBorderStart,
          JgColors.lightGlassBorderEnd,
        ],
        stops: [0.0, 1.0],
      ),
      glassShadow: [
        BoxShadow(
          color: Color(0x1F000000), // Ombra molto più leggera (12% opacità) per fondi chiari
          blurRadius: 24.0,
          offset: Offset(0, 12),
          spreadRadius: -6.0,
        ),
      ],
    );
  }

  @override
  ThemeExtension<JgEffects> copyWith({
    double? glassBlurX,
    double? glassBlurY,
    Gradient? glassBorderGradient,
    List<BoxShadow>? glassShadow,
    Color? glassColor,
    Duration? fluidDuration,
    Curve? fluidCurve,
  }) {
    return JgEffects(
      glassBlurX: glassBlurX ?? this.glassBlurX,
      glassBlurY: glassBlurY ?? this.glassBlurY,
      glassBorderGradient: glassBorderGradient ?? this.glassBorderGradient,
      glassShadow: glassShadow ?? this.glassShadow,
      glassColor: glassColor ?? this.glassColor,
      fluidDuration: fluidDuration ?? this.fluidDuration,
      fluidCurve: fluidCurve ?? this.fluidCurve,
    );
  }

  @override
  ThemeExtension<JgEffects> lerp(ThemeExtension<JgEffects>? other, double t) {
    if (other is! JgEffects) return this;
    return JgEffects(
      glassBlurX: lerpDouble(glassBlurX, other.glassBlurX, t) ?? glassBlurX,
      glassBlurY: lerpDouble(glassBlurY, other.glassBlurY, t) ?? glassBlurY,
      glassBorderGradient: Gradient.lerp(glassBorderGradient, other.glassBorderGradient, t) ?? glassBorderGradient,
      glassShadow: BoxShadow.lerpList(glassShadow, other.glassShadow, t) ?? glassShadow,
      glassColor: Color.lerp(glassColor, other.glassColor, t) ?? glassColor,
      fluidDuration: t < 0.5 ? fluidDuration : other.fluidDuration,
      fluidCurve: t < 0.5 ? fluidCurve : other.fluidCurve,
    );
  }
}
