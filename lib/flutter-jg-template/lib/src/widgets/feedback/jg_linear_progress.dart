import 'package:flutter/material.dart';
import '../../theme/extensions/jg_color_theme.dart';

/// Una barra di progresso orizzontale ultramoderna, geometrica e luminosa.
///
/// Si integra con lo stile glassmorphic dell'applicazione proponendo una traccia
/// vitrea micro-sottile e un segmento attivo con effetto alone neon (glow).
/// Supporta lo stato Determinato (tramite il valore [value] da 0.0 a 1.0) ed Indeterminato.
class JgLinearProgress extends StatefulWidget {
  /// Il valore di progresso corrente (da 0.0 a 1.0).
  /// Se nullo, la barra si comporterà come indicatore indeterminato a ciclo continuo.
  final double? value;

  /// Lo spessore della traccia della barra. Di default è 3.0 pixel.
  final double strokeWidth;

  /// Colore principale del segmento attivo. Di default è [JgColorTheme.accent].
  final Color? color;

  const JgLinearProgress({
    super.key,
    this.value,
    this.strokeWidth = 3.0,
    this.color,
  });

  @override
  State<JgLinearProgress> createState() => _JgLinearProgressState();
}

class _JgLinearProgressState extends State<JgLinearProgress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    if (widget.value == null) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant JgLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.value != null && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;
    final Color activeColor = widget.color ?? colors.accent;
    
    // Assegniamo un'altezza totale maggiore del solo spessore del tratto
    // per contenere la sfocatura dell'alone neon senza che venga tagliata.
    final double widgetHeight = widget.strokeWidth + 16.0;

    return SizedBox(
      width: double.infinity,
      height: widgetHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _JgLinearProgressPainter(
              value: widget.value,
              animationValue: _controller.value,
              strokeWidth: widget.strokeWidth,
              activeColor: activeColor,
              trackColor: colors.glassBackground,
            ),
          );
        },
      ),
    );
  }
}

class _JgLinearProgressPainter extends CustomPainter {
  final double? value;
  final double animationValue;
  final double strokeWidth;
  final Color activeColor;
  final Color trackColor;

  const _JgLinearProgressPainter({
    required this.value,
    required this.animationValue,
    required this.strokeWidth,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2;
    final double radius = strokeWidth / 2;

    // 1. Disegno della traccia inattiva di sfondo (Vetro scuro o chiaro in base al tema)
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawLine(
      Offset(radius, centerY),
      Offset(size.width - radius, centerY),
      trackPaint,
    );

    // Determiniamo i punti di inizio e fine del segmento attivo
    double startX = radius;
    double endX = radius;

    if (value != null) {
      // --- STATO DETERMINATO ---
      final double progress = value!.clamp(0.0, 1.0);
      endX = radius + (size.width - 2 * radius) * progress;
    } else {
      // --- STATO INDETERMINATO ---
      // Calcolo con effetto di scivolamento ed espansione/contrazione dinamica
      final double availableWidth = size.width - 2 * radius;
      final double segmentLength = availableWidth * 0.30; // Il segmento occupa il 30% della barra
      final double travelDistance = availableWidth + segmentLength;
      
      // Calcolo della coordinata iniziale del segmento (può andare fuori limiti temporaneamente)
      final double rawStartX = radius - segmentLength + (travelDistance * animationValue);
      final double rawEndX = rawStartX + segmentLength;

      // Clamping rigoroso sui bordi per simulare l'entrata e l'uscita fluida (crescita/decrescita)
      startX = rawStartX.clamp(radius, size.width - radius);
      endX = rawEndX.clamp(radius, size.width - radius);
    }

    // Se c'è un segmento da disegnare
    if (endX > startX) {
      // 2. Disegno dell'alone luminoso (Neon Glow)
      // Usiamo una linea più spessa e applicchiamo un filtro sfocatura
      final Paint glowPaint = Paint()
        ..color = activeColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6.0 // Alone più largo del tratto
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0) // Sfocatura neon
        ..isAntiAlias = true;

      canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), glowPaint);

      // 3. Disegno del segmento attivo principale
      final Paint activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), activePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _JgLinearProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}

