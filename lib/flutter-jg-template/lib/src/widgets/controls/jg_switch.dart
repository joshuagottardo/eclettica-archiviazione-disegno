import 'package:flutter/material.dart';
import '../../foundations/jg_control_size.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../../theme/extensions/jg_sizes_theme.dart';

/// Un interruttore (Switch) monocromatico, fluido e minimale.
///
/// Combina una traccia vetrata ad alta trasparenza (quando disattivo) o accentata solida
/// (quando attivo) con un cursore (thumb) animato in modo elastico.
class JgSwitch extends StatelessWidget {
  /// Stato attivo o inattivo.
  final bool value;

  /// Callback invocato al cambio di stato. Se nullo, l'interruttore è disabilitato.
  final ValueChanged<bool>? onChanged;

  /// Dimensione del controllo (small, medium, large). Default a [JgControlSize.medium].
  final JgControlSize controlSize;

  const JgSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.controlSize = JgControlSize.medium,
  });

  bool get _isEnabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;
    final sizesTheme = context.jgSizes;

    // Dimensioni calibrate in base alla scala
    double width;
    double height;
    switch (controlSize) {
      case JgControlSize.small:
        width = sizesTheme.switchWidthSmall;
        height = 20.0;
        break;
      case JgControlSize.medium:
        width = sizesTheme.switchWidthMedium;
        height = 28.0;
        break;
      case JgControlSize.large:
        width = sizesTheme.switchWidthLarge;
        height = 36.0;
        break;
    }
    const double padding = 2.0;
    final double thumbSize = height - (padding * 2);

    // Colori della traccia (track)
    final Color trackColor = value
        ? colors.accent
        : colors.glassBackground;

    final Color borderColor = value
        ? Colors.transparent
        : colors.border;

    // Colori del cursore (thumb)
    final Color thumbColor = value
        ? Theme.of(context).colorScheme.onPrimary // Contrasto su traccia accentata
        : colors.textPrimary;

    return Semantics(
      label: 'Interruttore',
      toggled: value,
      enabled: _isEnabled,
      onTap: _isEnabled ? () => onChanged!(!value) : null,
      child: GestureDetector(
        onTap: _isEnabled ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: Opacity(
          opacity: _isEnabled ? 1.0 : 0.4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuart,
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(
                color: borderColor,
                width: JgSizes.borderHairline,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack, // Leggero rimbalzo elastico alla fine dello scorrimento
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutQuart,
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    color: thumbColor,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

