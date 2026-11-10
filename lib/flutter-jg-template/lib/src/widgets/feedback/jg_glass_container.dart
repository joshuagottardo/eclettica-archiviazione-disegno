import 'dart:ui';
import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../../theme/extensions/jg_effects.dart';
import '../../theme/jg_performance.dart';

/// Un contenitore ad effetto vetro sfocato (Glassmorphism) in stile Apple.
///
/// Disegna un pannello semi-trasparente con sfocatura dello sfondo,
/// un bordo micro-sottile (hairline) sfumato e un'ombra scura volumetrica.
class JgGlassContainer extends StatelessWidget {
  /// Il contenuto del contenitore.
  final Widget child;

  /// Larghezza personalizzata del contenitore.
  final double? width;

  /// Altezza personalizzata del contenitore.
  final double? height;

  /// Raggio dei bordi per l'arrotondamento del vetro. Default a [JgSizes.radiusXLarge].
  final BorderRadius? borderRadius;

  /// Spaziatura interna del contenuto. Default a [JgSizes.paddingMedium].
  final EdgeInsetsGeometry? padding;

  /// Margine esterno del contenitore. Default a [EdgeInsets.zero].
  final EdgeInsetsGeometry? margin;

  /// Forza la sfocatura orizzontale. Se nullo, usa [JgEffects].
  final double? blurX;

  /// Forza la sfocatura verticale. Se nullo, usa [JgEffects].
  final double? blurY;

  /// Gradiente personalizzato per il bordo sottile. Se nullo, usa [JgEffects].
  final Gradient? borderGradient;

  /// Colore di sfondo del vetro. Se nullo, usa [JgEffects].
  final Color? backgroundColor;

  /// Lista di ombreggiature esterne del vetro. Se nullo, usa [JgEffects].
  final List<BoxShadow>? shadows;

  const JgGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.margin,
    this.blurX,
    this.blurY,
    this.borderGradient,
    this.backgroundColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    // Recupera gli effetti dal tema corrente o ripiega su quelli predefiniti
    final effects = Theme.of(context).extension<JgEffects>() ?? JgEffects.darkDefault();

    final effectiveColor = backgroundColor ?? effects.glassColor;
    final effectiveBorderGradient = borderGradient ?? effects.glassBorderGradient;
    final effectiveShadows = shadows ?? effects.glassShadow;
    
    // Default a 20.0 (radiusXLarge) come tipico delle card Apple
    final effectiveRadius = borderRadius ?? BorderRadius.circular(JgSizes.radiusXLarge);

    return ValueListenableBuilder<bool>(
      valueListenable: JgPerformance.lowPerformanceNotifier,
      builder: (context, lowPerf, _) {
        final double effectiveBlurX = lowPerf ? 0.0 : (blurX ?? effects.glassBlurX);
        final double effectiveBlurY = lowPerf ? 0.0 : (blurY ?? effects.glassBlurY);

        return Container(
          margin: margin,
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            boxShadow: effectiveShadows,
          ),
          child: ClipRRect(
            borderRadius: effectiveRadius,
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // 1. Sfocatura dello sfondo sottostante con colore semi-trasparente (o fallback solido/opaco)
                Positioned.fill(
                  child: (effectiveBlurX == 0.0 || effectiveBlurY == 0.0)
                      ? Container(
                          // In modalità basse prestazioni (senza sfocatura), usiamo il colore di superficie solido
                          // del tema corrente per garantire una leggibilità perfetta del testo.
                          color: backgroundColor ?? context.jgColors.surface,
                        )
                      : BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: effectiveBlurX, sigmaY: effectiveBlurY),
                          child: Container(
                            color: effectiveColor,
                          ),
                        ),
                ),
                
                // 2. Micro-bordo a gradiente inciso (Hairline border) dipinto sopra il vetro
                Positioned.fill(
                  child: CustomPaint(
                    painter: _JgGradientBorderPainter(
                      borderRadius: effectiveRadius,
                      gradient: effectiveBorderGradient,
                      strokeWidth: JgSizes.borderHairline,
                    ),
                  ),
                ),
                
                // 3. Contenuto effettivo con padding
                Padding(
                  padding: padding ?? JgSizes.paddingMedium,
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// CustomPainter per disegnare una linea di bordo microscopica e sfumata.
///
/// Previene i difetti di renderizzazione dei bordi spessi di Flutter
/// e simula il riflesso della luce sui bordi fisici del vetro.
class _JgGradientBorderPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Gradient gradient;
  final double strokeWidth;

  const _JgGradientBorderPainter({
    required this.borderRadius,
    required this.gradient,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..shader = gradient.createShader(rect)
      ..isAntiAlias = true;

    final rrect = borderRadius.toRRect(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _JgGradientBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.gradient != gradient ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
