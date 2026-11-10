import 'package:flutter/material.dart';
import '../../theme/extensions/jg_color_theme.dart';

/// Una barra di selezione (Slider) ultramoderna e minimale.
///
/// Presenta una traccia sottile ed un cursore bianco compatto che si espande
/// in un anello vitreo luminoso durante il trascinamento (effetto wow).
class JgSlider extends StatefulWidget {
  /// Valore corrente dello slider.
  final double value;

  /// Callback invocato durante lo scorrimento o il tocco. Se nullo, è disabilitato.
  final ValueChanged<double>? onChanged;

  /// Valore minimo. Di default è 0.0.
  final double min;

  /// Valore massimo. Di default è 1.0.
  final double max;

  const JgSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
  }) : assert(min <= max),
       assert(value >= min && value <= max);

  @override
  State<JgSlider> createState() => _JgSliderState();
}

class _JgSliderState extends State<JgSlider> {
  bool _isDragging = false;

  bool get _isEnabled => widget.onChanged != null;

  void _handleInteraction(Offset localPosition, double width) {
    if (!_isEnabled) return;
    
    final double percentage = (localPosition.dx / width).clamp(0.0, 1.0);
    final double newValue = widget.min + (percentage * (widget.max - widget.min));
    widget.onChanged!(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;

    // Dimensioni dinamiche basate sullo stato di drag (Effetto Wow)
    final double trackHeight = _isDragging ? 6.0 : 3.0;
    final double thumbSize = _isDragging ? 22.0 : 12.0;
    const double interactionHeight = 32.0; // Area di tocco aumentata

    final double percentage = (widget.max - widget.min) > 0 
        ? ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0) 
        : 0.0;

    return Opacity(
      opacity: _isEnabled ? 1.0 : 0.4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          // Calcola l'offset X del cursore
          final double thumbOffset = (width * percentage) - (thumbSize / 2);

          return GestureDetector(
            onTapDown: (details) {
              if (_isEnabled) {
                setState(() => _isDragging = true);
                _handleInteraction(details.localPosition, width);
              }
            },
            onTapUp: (_) => setState(() => _isDragging = false),
            onTapCancel: () => setState(() => _isDragging = false),
            onHorizontalDragStart: (_) {
              if (_isEnabled) {
                setState(() => _isDragging = true);
              }
            },
            onHorizontalDragUpdate: (details) => _handleInteraction(details.localPosition, width),
            onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
            onHorizontalDragCancel: () => setState(() => _isDragging = false),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: interactionHeight,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // 1. Traccia Inattiva (Vetro)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutQuart,
                    height: trackHeight,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.glassBackground,
                      borderRadius: BorderRadius.circular(trackHeight / 2),
                    ),
                  ),

                  // 2. Traccia Attiva (Colore Accento)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutQuart,
                    height: trackHeight,
                    width: width * percentage,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(trackHeight / 2),
                    ),
                  ),

                  // 3. Cursore Rotondo Animato (Thumb)
                  Positioned(
                    left: thumbOffset.clamp(0.0, width - thumbSize),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack, // Rimbalzo elastico all'espansione
                      width: thumbSize,
                      height: thumbSize,
                      decoration: BoxDecoration(
                        color: _isDragging ? colors.accent.withValues(alpha: 0.2) : colors.textPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isDragging ? colors.textPrimary : Colors.transparent,
                          width: _isDragging ? 1.5 : 0.0,
                        ),
                        boxShadow: [
                          if (_isDragging)
                            BoxShadow(
                              color: colors.textPrimary.withValues(alpha: 0.35),
                              blurRadius: 12.0,
                              spreadRadius: 2.0,
                            )
                          else
                            const BoxShadow(
                              color: Color(0x7F000000),
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutQuart,
                          width: _isDragging ? 6.0 : 0.0,
                          height: _isDragging ? 6.0 : 0.0,
                          decoration: BoxDecoration(
                            color: colors.background, // Contrasto rispetto all'anello
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

