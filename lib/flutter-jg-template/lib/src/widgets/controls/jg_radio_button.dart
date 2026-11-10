import 'package:flutter/material.dart';
import '../../foundations/jg_control_size.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../../theme/extensions/jg_sizes_theme.dart';

/// Un selettore circolare (Radio Button) monocromatico e geometrico.
///
/// Disegna un cerchio a linea sottile con un pallino centrale che
/// appare e scompare con un'animazione fluida di scala.
class JgRadioButton<T> extends StatelessWidget {
  /// Il valore associato a questo specifico radio button.
  final T value;

  /// Il valore attualmente selezionato nel gruppo.
  final T? groupValue;

  /// Callback invocato alla selezione. Se nullo, il controllo è disabilitato.
  final ValueChanged<T>? onChanged;

  /// Etichetta di testo opzionale da posizionare a fianco del cerchio.
  final Widget? label;

  /// Dimensione del controllo (small, medium, large). Default a [JgControlSize.medium].
  final JgControlSize controlSize;

  const JgRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
    this.controlSize = JgControlSize.medium,
  });

  bool get _isSelected => value == groupValue;
  bool get _isEnabled => onChanged != null;

  void _handleTap() {
    if (_isEnabled) {
      onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;
    final sizesTheme = context.jgSizes;

    double size;
    switch (controlSize) {
      case JgControlSize.small:
        size = sizesTheme.radioButtonSizeSmall;
        break;
      case JgControlSize.medium:
        size = sizesTheme.radioButtonSizeMedium;
        break;
      case JgControlSize.large:
        size = sizesTheme.radioButtonSizeLarge;
        break;
    }
    final double innerSize = size * 0.5;

    // Colori in base allo stato di selezione
    final Color outerBorderColor = _isSelected ? colors.accent : colors.border;

    Widget radioCircle = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutQuart,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: outerBorderColor,
          width: _isSelected ? JgSizes.borderThick : JgSizes.borderThin,
        ),
      ),
      child: Center(
        child: AnimatedScale(
          scale: _isSelected ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack, // Rimbalzo elastico per il pallino interno
          child: Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              color: colors.accent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );

    // Se c'è una label, la posizioniamo a destra allineandola
    if (label != null) {
      final double labelFontSize = controlSize == JgControlSize.small
          ? 12.0
          : (controlSize == JgControlSize.large ? 16.0 : 14.0);

      return Semantics(
        selected: _isSelected,
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
                  radioCircle,
                  const SizedBox(width: JgSizes.space12),
                  DefaultTextStyle.merge(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.textPrimary,
                          fontSize: labelFontSize,
                        ),
                    child: label!,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Pulsante di opzione',
      selected: _isSelected,
      enabled: _isEnabled,
      onTap: _isEnabled ? _handleTap : null,
      child: GestureDetector(
        onTap: _handleTap,
        child: Opacity(
          opacity: _isEnabled ? 1.0 : 0.4,
          child: radioCircle,
        ),
      ),
    );
  }
}

