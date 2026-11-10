import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../feedback/jg_glass_container.dart';

/// Modello dati per memorizzare gli elementi di [JgFloatingNavigationBar].
class JgNavigationBarItem {
  /// Icona del tab.
  final IconData icon;

  /// Etichetta descrittiva del tab.
  final String label;

  const JgNavigationBarItem({
    required this.icon,
    required this.label,
  });
}

/// Una barra di navigazione fluttuante in stile HUD (Heads-Up Display).
///
/// Si posiziona sul fondo dello schermo fluttuando sul contenuto.
/// Include micro-animazioni elastiche all'attivazione delle icone e scivolamento
/// verticale delle etichette testuali.
class JgFloatingNavigationBar extends StatelessWidget {
  /// L'indice del tab attualmente selezionato.
  final int currentIndex;

  /// Lista degli elementi della barra di navigazione.
  final List<JgNavigationBarItem> items;

  /// Callback invocato al tocco di un tab.
  final ValueChanged<int> onTap;

  /// Larghezza massima della barra HUD. Default a 360.0.
  final double maxWidth;

  /// Altezza della barra HUD. Default a 66.0 per dare spazio alle transizioni.
  final double height;

  const JgFloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.maxWidth = 360.0,
    this.height = 66.0,
  }) : assert(items.length >= 2);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.all(JgSizes.space20),
        child: JgGlassContainer(
          borderRadius: BorderRadius.circular(JgSizes.radiusCircular), // Pillola
          padding: EdgeInsets.zero,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final JgNavigationBarItem item = items[index];
              final bool isSelected = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Icona con rimbalzo di scala e variazione di colore
                      AnimatedScale(
                        scale: isSelected ? 1.22 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutBack, // Rimbalzo elastico stile Apple
                        child: Icon(
                          item.icon,
                          color: isSelected ? colors.accent : colors.textMuted,
                          size: 22.0,
                        ),
                      ),
                      
                      // Spaziatore animato in altezza
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: isSelected ? JgSizes.space4 : JgSizes.space2,
                      ),

                      // 2. Etichetta scorrevole in dissolvenza (comparsa da sotto l'icona)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutQuart,
                        height: isSelected ? 12.0 : 0.0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: isSelected ? 1.0 : 0.0,
                          child: Text(
                            item.label.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              fontSize: 9.0,
                              color: colors.accent,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      // 3. Micro-puntino luminoso alla base
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutQuart,
                        height: isSelected ? 3.0 : 0.0,
                        width: isSelected ? 3.0 : 0.0,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

