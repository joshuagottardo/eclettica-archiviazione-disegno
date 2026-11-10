import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';

/// Un indicatore di caricamento (Loader) sbalorditivo ed ultramoderno.
///
/// Sostituisce il classico indicatore rotante con un "Radar Orbitale" composto da:
/// 1. Un alone neon sfumato (glow) in sottofondo che pulsa di dimensioni ed opacità.
/// 2. Una traccia orbitale circolare microscopica (hairline).
/// 3. Un arco rotante che si contrae ed allunga in modo elastico.
/// 4. Un nucleo centrale (dot) che esegue una respirazione sincronizzata.
class JgLoader extends StatefulWidget {
  /// Dimensione del caricatore (larghezza ed altezza). Default a 48.0.
  final double size;

  /// Spessore della linea dell'orbita. Default a 1.5.
  final double strokeWidth;

  /// Se true, mostra l'alone luminoso sfocato colorato in background.
  final bool showGlow;

  const JgLoader({
    super.key,
    this.size = 48.0,
    this.strokeWidth = 1.5,
    this.showGlow = true,
  });

  @override
  State<JgLoader> createState() => _JgLoaderState();
}

class _JgLoaderState extends State<JgLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Loop infinito per gestire tutte le frequenze dell'animazione
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _JgRadarLoaderPainter(
              animationValue: _controller.value,
              strokeWidth: widget.strokeWidth,
              showGlow: widget.showGlow,
              accentColor: colors.accent,
              textPrimaryColor: colors.textPrimary,
              glassColor: colors.glassBackground,
            ),
          );
        },
      ),
    );
  }
}

class _JgRadarLoaderPainter extends CustomPainter {
  final double animationValue;
  final double strokeWidth;
  final bool showGlow;
  final Color accentColor;
  final Color textPrimaryColor;
  final Color glassColor;

  const _JgRadarLoaderPainter({
    required this.animationValue,
    required this.strokeWidth,
    required this.showGlow,
    required this.accentColor,
    required this.textPrimaryColor,
    required this.glassColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Frequenze d'animazione ricavate da oscillazioni trigonometriche sfasate
    final double rotationAngle = animationValue * 2 * math.pi;
    
    // Lunghezza dell'arco elastico (si allunga e si accorcia)
    final double sweepAngle = (math.pi / 3) + (math.sin(animationValue * 2 * math.pi) * (math.pi / 6));
    
    // Respirazione centrale (raggio e trasparenza)
    final double centralDotRadius = 3.0 + (math.sin(animationValue * 4 * math.pi + math.pi) * 1.0);
    final double centralDotOpacity = 0.6 + (math.sin(animationValue * 2 * math.pi) * 0.4);

    // 1. Disegno dell'alone luminoso sfocato (Neon Ambient Glow)
    if (showGlow && radius > 8.0) {
      final double glowPulse = 1.0 + (math.sin(animationValue * 2 * math.pi) * 0.2); // Pulsazione raggio 0.8x a 1.2x
      final double glowOpacity = 0.12 + (math.sin(animationValue * 2 * math.pi) * 0.06);

      // Usiamo una sfocatura a maschera sul Canvas per un effetto neon sfumato
      final Paint glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF8B5CF6).withValues(alpha: glowOpacity), // Viola / Magenta neon
            const Color(0xFF06B6D4).withValues(alpha: glowOpacity * 0.5), // Ciano neon
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5 * glowPulse))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.5);

      canvas.drawCircle(center, radius * 1.4 * glowPulse, glowPaint);
    }

    // 2. Disegno della traccia circolare fissa dell'orbita (Hairline)
    final Paint trackPaint = Paint()
      ..color = glassColor.withValues(alpha: 0.15) // Vetro leggero
      ..style = PaintingStyle.stroke
      ..strokeWidth = JgSizes.borderHairline
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    // 3. Disegno dell'arco orbitante (Serpente elastico rotante)
    final Paint arcPaint = Paint()
      ..color = accentColor // Colore attivo d'accento
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round // Terminali arrotondati
      ..isAntiAlias = true;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      rotationAngle - (math.pi / 2), // Inizia orientato in alto
      sweepAngle,
      false,
      arcPaint,
    );

    // 4. Disegno del nucleo centrale pulsante (Central Breathing Core)
    final Paint corePaint = Paint()
      ..color = textPrimaryColor.withValues(alpha: centralDotOpacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(center, centralDotRadius, corePaint);
  }

  @override
  bool shouldRepaint(covariant _JgRadarLoaderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.showGlow != showGlow ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.textPrimaryColor != textPrimaryColor ||
        oldDelegate.glassColor != glassColor;
  }
}

