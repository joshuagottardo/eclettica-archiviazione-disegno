import 'package:flutter/material.dart';
import 'jg_floating_navigation_bar.dart';
import 'jg_navigation_rail.dart';
import 'jg_navigation_sidebar.dart';

/// Uno Scaffold adattivo e responsive in stile Swiss/Glassmorphic.
///
/// Monitora la larghezza dello schermo e seleziona il layout di navigazione ottimale:
/// - **Mobile (< 600px):** Bottom Navigation fluttuante ([JgFloatingNavigationBar]).
/// - **Tablet (>= 600px e < 1024px):** Barra verticale compatta ([JgNavigationRail]).
/// - **Desktop (>= 1024px):** Barra laterale estesa ([JgNavigationSidebar]).
class JgResponsiveScaffold extends StatelessWidget {
  /// L'indice della schermata attiva.
  final int currentIndex;

  /// Gli elementi della barra di navigazione.
  final List<JgNavigationBarItem> items;

  /// Callback scatenato quando l'utente preme un tab.
  final ValueChanged<int> onTap;

  /// La schermata attiva da visualizzare.
  final Widget body;

  /// Barra superiore opzionale (AppBar). Viene posizionata nella parte destra/superiore della schermata.
  final PreferredSizeWidget? appBar;

  /// Widget da posizionare in cima alle barre di navigazione verticali (Rail/Sidebar).
  final Widget? sidebarHeader;

  /// Widget da posizionare in fondo alle barre di navigazione verticali (Rail/Sidebar).
  final Widget? sidebarFooter;

  /// Breakpoint per definire lo schermo Mobile. Default a 600.0.
  final double mobileBreakpoint;

  /// Breakpoint per definire lo schermo Desktop. Default a 1024.0.
  final double desktopBreakpoint;

  /// Forza l'abilitazione o disabilitazione dell'effetto vetro (Glassmorphism). Default a true.
  final bool isGlass;

  const JgResponsiveScaffold({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    required this.body,
    this.appBar,
    this.sidebarHeader,
    this.sidebarFooter,
    this.mobileBreakpoint = 600.0,
    this.desktopBreakpoint = 1024.0,
    this.isGlass = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // 1. LAYOUT DESKTOP (Sidebar larga + Body)
        if (width >= desktopBreakpoint) {
          return Scaffold(
            body: Row(
              children: [
                JgNavigationSidebar(
                  currentIndex: currentIndex,
                  items: items,
                  onTap: onTap,
                  header: sidebarHeader,
                  footer: sidebarFooter,
                  isGlass: isGlass,
                ),
                Expanded(
                  child: Scaffold(
                    appBar: appBar,
                    body: body,
                  ),
                ),
              ],
            ),
          );
        }

        // 2. LAYOUT TABLET (Navigation Rail compatta + Body)
        if (width >= mobileBreakpoint) {
          return Scaffold(
            body: Row(
              children: [
                JgNavigationRail(
                  currentIndex: currentIndex,
                  items: items,
                  onTap: onTap,
                  header: sidebarHeader,
                  footer: sidebarFooter,
                  isGlass: isGlass,
                ),
                Expanded(
                  child: Scaffold(
                    appBar: appBar,
                    body: body,
                  ),
                ),
              ],
            ),
          );
        }

        // 3. LAYOUT MOBILE (Scaffold standard + Floating Bottom Bar)
        return Scaffold(
          appBar: appBar,
          body: Stack(
            children: [
              // Body con padding inferiore per evitare che il contenuto finisca dietro la bottom bar
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0), // Spazio per la nav bar fluttuante
                  child: body,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: JgFloatingNavigationBar(
                  currentIndex: currentIndex,
                  items: items,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
