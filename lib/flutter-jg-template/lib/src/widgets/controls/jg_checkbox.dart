import 'package:flutter/material.dart';
import '../../foundations/jg_control_size.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../../theme/extensions/jg_sizes_theme.dart';

/// Una casella di spunta (Checkbox) monocromatica e geometrica.
///
/// Si presenta come un box quadrato con angoli arrotondati. Quando attiva,
/// la spunta (checkmark) viene disegnata dinamicamente all'interno del box
/// con un'animazione fluida del tratto.
class JgCheckbox extends StatefulWidget {
  /// Stato della selezione (selezionato o meno).
  final bool value;

  /// Callback invocato al cambio di stato. Se nullo, il controllo è disabilitato.
  final ValueChanged<bool>? onChanged;

  /// Etichetta testuale opzionale posizionata a destra.
  final Widget? label;

  /// Dimensione del controllo (small, medium, large). Default a [JgControlSize.medium].
  final JgControlSize controlSize;

  const JgCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
    this.controlSize = JgControlSize.medium,
  });

  @override
  State<JgCheckbox> createState() => _JgCheckboxState();
}

class _JgCheckboxState extends State<JgCheckbox> with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;

  bool get _isEnabled => widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.value) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant JgCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _checkController.forward();
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_isEnabled) {
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;
    final sizesTheme = context.jgSizes;

    double size;
    double radius;
    switch (widget.controlSize) {
      case JgControlSize.small:
        size = sizesTheme.checkboxSizeSmall;
        radius = JgSizes.radiusSmall - 1.0;
        break;
      case JgControlSize.medium:
        size = sizesTheme.checkboxSizeMedium;
        radius = JgSizes.radiusSmall;
        break;
      case JgControlSize.large:
        size = sizesTheme.checkboxSizeLarge;
        radius = JgSizes.radiusSmall + 1.0;
        break;
    }

    // Colori dinamici in base allo stato
    final Color boxColor = widget.value
        ? colors.accent.withValues(alpha: 0.08) // Leggero riempimento vetrato quando attivo
        : Colors.transparent;
    final Color borderColor = widget.value ? colors.accent : colors.border;

    Widget checkboxBox = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutQuart,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor,
          width: JgSizes.borderThin,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _checkAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _JgCheckmarkPainter(
                  progress: _checkAnimation.value,
                  color: colors.textPrimary, // Spunta contrastata (nera in light mode, bianca in dark)
                ),
              );
            },
          ),
        ),
      ),
    );

    // Se c'è una label, la posizioniamo a destra con area di tocco estesa
    if (widget.label != null) {
      final double labelFontSize = widget.controlSize == JgControlSize.small
          ? 12.0
          : (widget.controlSize == JgControlSize.large ? 16.0 : 14.0);

      return Semantics(
        checked: widget.value,
        enabled: _isEnabled,
        onTap: _isEnabled ? _handleTap : null,
        child: GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          child: Opacity(
            opacity: _isEnabled ? 1.0 : 0.4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: JgSizes.space8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  checkboxBox,
                  const SizedBox(width: JgSizes.space12),
                  DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textPrimary,
                          fontSize: labelFontSize,
                        ),
                    child: widget.label!,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Casella di spunta',
      checked: widget.value,
      enabled: _isEnabled,
      onTap: _isEnabled ? _handleTap : null,
      child: GestureDetector(
        onTap: _handleTap,
        child: Opacity(
          opacity: _isEnabled ? 1.0 : 0.4,
          child: checkboxBox,
        ),
      ),
    );
  }
}

class _JgCheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  const _JgCheckmarkPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    // Coordinate calcolate proporzionalmente alla dimensione del box
    final Offset p0 = Offset(size.width * 0.28, size.height * 0.50);
    final Offset p1 = Offset(size.width * 0.44, size.height * 0.68);
    final Offset p2 = Offset(size.width * 0.74, size.height * 0.32);

    final double l1 = (p1 - p0).distance;
    final double l2 = (p2 - p1).distance;
    final double totalLength = l1 + l2;
    final double t1 = l1 / totalLength;

    final Path path = Path();
    path.moveTo(p0.dx, p0.dy);

    if (progress <= t1) {
      final double ratio = progress / t1;
      final Offset current = p0 + (p1 - p0) * ratio;
      path.lineTo(current.dx, current.dy);
    } else {
      path.lineTo(p1.dx, p1.dy);
      final double ratio = (progress - t1) / (1.0 - t1);
      final Offset current = p1 + (p2 - p1) * ratio;
      path.lineTo(current.dx, current.dy);
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _JgCheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

