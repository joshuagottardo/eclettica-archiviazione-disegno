import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../feedback/jg_glass_container.dart';
import 'jg_floating_navigation_bar.dart';

/// Una barra di navigazione laterale estesa (Sidebar) per desktop o schermi larghi.
///
/// Si posiziona sul lato sinistro, esponendo icone e testi allineati in orizzontale.
/// Offre una transizione fluida dello sfondo attivo e stile tipografico svizzero.
class JgNavigationSidebar extends StatelessWidget {
  /// L'indice del tab attualmente selezionato.
  final int currentIndex;

  /// Lista degli elementi della barra di navigazione.
  final List<JgNavigationBarItem> items;

  /// Callback invocato al tocco di un tab.
  final ValueChanged<int> onTap;

  /// Widget opzionale da posizionare in cima (es. logo e titolo).
  final Widget? header;

  /// Widget opzionale da posizionare in fondo (es. profilo utente).
  final Widget? footer;

  /// Larghezza fissa della barra. Default a 240.0.
  final double width;

  /// Se true, applica l'effetto vetro sfocato (Glassmorphism). Default a true.
  final bool isGlass;

  const JgNavigationSidebar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.header,
    this.footer,
    this.width = 240.0,
    this.isGlass = true,
  }) : assert(items.length >= 2);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;

    final Widget sidebarContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) ...[
          Padding(
            padding: const EdgeInsets.all(JgSizes.space20),
            child: header!,
          ),
        ] else ...[
          const SizedBox(height: JgSizes.space20),
        ],
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.symmetric(horizontal: JgSizes.space12),
            itemBuilder: (context, index) {
              final JgNavigationBarItem item = items[index];
              final bool isSelected = index == currentIndex;

              // Stile del testo a seconda dello stato di selezione (stile svizzero rigido)
              final TextStyle? textStyle = textTheme.labelLarge?.copyWith(
                color: isSelected ? colors.accent : colors.textMuted,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: 0.8,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: JgSizes.space4),
                child: Semantics(
                  selected: isSelected,
                  button: true,
                  onTap: () => onTap(index),
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: 48.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. Sfondo attivo della riga (pillola orizzontale)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.0,
                            child: AnimatedScale(
                              scale: isSelected ? 1.0 : 0.95,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutQuart,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colors.accent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
                                  border: Border.all(
                                    color: colors.accent.withValues(alpha: 0.15),
                                    width: JgSizes.borderHairline,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2. Contenuto della riga (Icona + Testo)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: JgSizes.space16),
                            child: Row(
                              children: [
                                AnimatedScale(
                                  scale: isSelected ? 1.1 : 1.0,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutBack,
                                  child: Icon(
                                    item.icon,
                                    color: isSelected ? colors.accent : colors.textMuted,
                                    size: 20.0,
                                  ),
                                ),
                                const SizedBox(width: JgSizes.space16),
                                Expanded(
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: textStyle ?? const TextStyle(),
                                    child: Text(
                                      item.label.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 3. Micro-linea indicatore sul bordo sinistro
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutQuart,
                            left: 0,
                            height: isSelected ? 20.0 : 0.0,
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
            },
          ),
        ),
        if (footer != null) ...[
          Padding(
            padding: const EdgeInsets.all(JgSizes.space20),
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
              child: sidebarContent,
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
              child: sidebarContent,
            ),
    );
  }
}
