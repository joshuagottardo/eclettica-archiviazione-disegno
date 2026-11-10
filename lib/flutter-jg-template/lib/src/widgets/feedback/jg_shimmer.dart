import 'package:flutter/material.dart';
import '../../theme/extensions/jg_color_theme.dart';

/// Uno scheletro di caricamento (Skeleton Loader) ad alte prestazioni.
///
/// Utilizza [ShaderMask] accelerato via hardware GPU per applicare una transizione
/// a gradiente animata continua su qualsiasi widget passato come [child].
class JgShimmer extends StatefulWidget {
  /// Il widget su cui applicare l'effetto di luccichio (solitamente forme geometriche vuote).
  final Widget child;

  /// Se impostato a false, restituisce il [child] senza alcuna animazione o filtro.
  final bool enabled;

  /// Durata del ciclo completo di animazione dello shimmer. Default a 1500ms.
  final Duration duration;

  const JgShimmer({
    super.key,
    required this.child,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<JgShimmer> createState() => _JgShimmerState();
}

class _JgShimmerState extends State<JgShimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant JgShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final colors = context.jgColors;
    final Color baseColor = colors.textPrimary.withValues(alpha: 0.06);
    final Color highlightColor = colors.textPrimary.withValues(alpha: 0.16);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn, // Dipinge il gradiente solo dentro le forme del child
          shaderCallback: (bounds) {
            // Frequenza d'onda: scorre diagonalmente da sinistra a destra
            return LinearGradient(
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [
                0.2,
                0.5,
                0.8,
              ],
              begin: Alignment(-2.0 + (4.0 * _controller.value), -0.2),
              end: Alignment(0.0 + (4.0 * _controller.value), 0.2),
              tileMode: TileMode.clamp,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

