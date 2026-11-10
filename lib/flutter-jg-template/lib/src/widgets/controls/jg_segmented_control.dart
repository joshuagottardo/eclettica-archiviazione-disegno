import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../feedback/jg_glass_container.dart';

/// Un selettore a schede (Segmented Control) generico, fluido e minimale.
///
/// Presenta una traccia vetrata ed un selettore (pillola) accentato
/// che scivola in modo magnetico ed elastico sotto l'opzione attiva.
class JgSegmentedControl<T> extends StatelessWidget {
  /// Il valore attualmente selezionato.
  final T selectedValue;

  /// Mappa ordinata delle opzioni disponibili: chiavi di tipo [T] e valori di testo.
  final Map<T, String> children;

  /// Callback invocato al cambio di selezione.
  final ValueChanged<T> onValueChanged;

  /// Altezza del controllo. Default a 40.0.
  final double height;

  const JgSegmentedControl({
    super.key,
    required this.selectedValue,
    required this.children,
    required this.onValueChanged,
    this.height = 40.0,
  }) : assert(children.length >= 2);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;
    final List<T> keys = children.keys.toList();
    final int count = keys.length;
    final int selectedIndex = keys.indexOf(selectedValue);

    const double internalPadding = 3.0;
    final double selectorHeight = height - (internalPadding * 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcola la larghezza proporzionale per ogni segmento
        final double totalWidth = constraints.maxWidth;
        final double segmentWidth = (totalWidth - (internalPadding * 2)) / count;

        return JgGlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
          height: height,
          width: double.infinity,
          child: Stack(
            children: [
              // 1. Pillola di Selezione Scorrevole
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutQuart, // Curva rapida e fluida stile Apple
                left: internalPadding + (selectedIndex * segmentWidth),
                top: internalPadding,
                width: segmentWidth,
                height: selectorHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(JgSizes.radiusMedium - 2.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4.0,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Livello di Interazione e Testi
              Row(
                children: List.generate(count, (index) {
                  final T key = keys[index];
                  final String label = children[key]!;
                  final bool isSelected = index == selectedIndex;

                  // Stile del testo attivo o inattivo
                  final TextStyle textStyle = isSelected
                      ? textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary, // Contrasto perfetto su pillola accentata
                          fontWeight: FontWeight.w700,
                        )
                      : textTheme.labelLarge!.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        );

                  return SizedBox(
                    width: segmentWidth,
                    height: height,
                    child: Semantics(
                      selected: isSelected,
                      button: true,
                      onTap: () => onValueChanged(key),
                      child: GestureDetector(
                        onTap: () => onValueChanged(key),
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            style: textStyle,
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

