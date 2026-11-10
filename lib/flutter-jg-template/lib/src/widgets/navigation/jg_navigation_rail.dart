import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../feedback/jg_glass_container.dart';
import 'jg_floating_navigation_bar.dart';

/// Una barra di navigazione verticale compatta (Navigation Rail) per tablet o schermi medi.
///
/// Fluttua sul lato sinistro dello schermo ed offre un feedback visivo premium
/// con scale transition sull'icona attiva e selettore in vetro o accentato.
class JgNavigationRail extends StatelessWidget {
  /// L'indice del tab attualmente selezionato.
  final int currentIndex;

  /// Lista degli elementi della barra di navigazione.
  final List<JgNavigationBarItem> items;

  /// Callback invocato al tocco di un tab.
  final ValueChanged<int> onTap;

  /// Widget opzionale da posizionare in cima (es. logo).
  final Widget? header;

  /// Widget opzionale da posizionare in fondo (es. profilo utente o impostazioni).
  final Widget? footer;

  /// Larghezza della barra. Default a 76.0.
  final double width;

  /// Se true, applica l'effetto vetro sfocato (Glassmorphism). Default a true.
  final bool isGlass;

  const JgNavigationRail({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.header,
    this.footer,
    this.width = 76.0,
    this.isGlass = true,
  }) : assert(items.length >= 2);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;

    final Widget railContent = Column(
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: JgSizes.space20),
            child: header!,
          ),
        ] else ...[
          const SizedBox(height: JgSizes.space20),
        ],
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (index) {
              final JgNavigationBarItem item = items[index];
              final bool isSelected = index == currentIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: JgSizes.space12),
                child: SizedBox(
                  width: width - JgSizes.space16,
                  height: 56.0,
                  child: Semantics(
                    selected: isSelected,
                    button: true,
                    onTap: () => onTap(index),
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Sfondo attivo (pillola) animato in dissolvenza e scala
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.0,
                            child: AnimatedScale(
                              scale: isSelected ? 1.0 : 0.8,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutQuart,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colors.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
                                  border: Border.all(
                                    color: colors.accent.withValues(alpha: 0.2),
                                    width: JgSizes.borderHairline,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. Icona e Testo
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                scale: isSelected ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeOutBack,
                                child: Icon(
                                  item.icon,
                                  color: isSelected ? colors.accent : colors.textMuted,
                                  size: 22.0,
                                ),
                              ),
                              const SizedBox(height: JgSizes.space4),
                              Text(
                                item.label.toUpperCase(),
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 8.0,
                                  color: isSelected ? colors.accent : colors.textMuted,
                                  letterSpacing: 0.5,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),

                          // 3. Linea indicatore sul bordo sinistro
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutQuart,
                            left: 0,
                            height: isSelected ? 16.0 : 0.0,
                            width: 3.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors.accent,
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        if (footer != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: JgSizes.space20),
            child: footer!,
          ),
        ] else ...[
          const SizedBox(height: JgSizes.space20),
        ],
      ],
    );

    final double effectiveHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(JgSizes.space16),
      child: isGlass
          ? JgGlassContainer(
              borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
              padding: EdgeInsets.zero,
              width: width,
              height: effectiveHeight - (JgSizes.space16 * 2),
              child: railContent,
            )
          : Container(
              width: width,
              height: effectiveHeight - (JgSizes.space16 * 2),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
                border: Border.all(
                  color: colors.border,
                  width: JgSizes.borderThin,
                ),
              ),
              child: railContent,
            ),
    );
  }
}
