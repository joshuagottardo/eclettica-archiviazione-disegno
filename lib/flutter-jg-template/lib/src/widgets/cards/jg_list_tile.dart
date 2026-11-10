import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../feedback/jg_glass_container.dart';

/// Una versione ultramoderna, ordinata e minimale del [ListTile] classico.
///
/// Segue un allineamento rigoroso a sinistra (stile svizzero) ed offre feedback
/// di tocco fluido, supporto glassmorfico opzionale e divisori discreti.
class JgListTile extends StatefulWidget {
  /// Titolo principale del tile.
  final Widget title;

  /// Sottotitolo descrittivo opzionale.
  final Widget? subtitle;

  /// Icona o widget posizionato all'estrema sinistra.
  final Widget? leading;

  /// Icona o widget posizionato all'estrema destra (es. freccia avanti).
  final Widget? trailing;

  /// Callback invocato al tocco.
  final VoidCallback? onTap;

  /// Spaziatura interna personalizzata. Default a [JgSizes.space16] verticale e orizzontale.
  final EdgeInsetsGeometry? padding;

  /// Se true, il tile viene racchiuso in una superficie di vetro sfocato.
  final bool isGlass;

  /// Se true, mostra una linea di divisione sottile alla base del tile.
  final bool showDivider;

  const JgListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.padding,
    this.isGlass = false,
    this.showDivider = false,
  });

  @override
  State<JgListTile> createState() => _JgListTileState();
}

class _JgListTileState extends State<JgListTile> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;

    // Layout interno del tile
    final Widget content = Padding(
      padding: widget.padding ??
          const EdgeInsets.symmetric(
            horizontal: JgSizes.space16,
            vertical: JgSizes.space16,
          ),
      child: Row(
        children: [
          // Sezione leading (es. icone)
          if (widget.leading != null) ...[
            IconTheme(
              data: IconThemeData(color: colors.textPrimary, size: 22.0),
              child: widget.leading!,
            ),
            const SizedBox(width: JgSizes.space16),
          ],
          
          // Sezione testi centrale (allineamento rigido a sinistra)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stile titolo
                DefaultTextStyle.merge(
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  child: widget.title,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: JgSizes.space4),
                  // Stile sottotitolo leggermente rimpicciolito e muto
                  DefaultTextStyle.merge(
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                    child: widget.subtitle!,
                  ),
                ],
              ],
            ),
          ),
          
          // Sezione trailing (es. chevron o azioni a destra)
          if (widget.trailing != null) ...[
            const SizedBox(width: JgSizes.space16),
            IconTheme(
              data: IconThemeData(color: colors.textMuted, size: 20.0),
              child: widget.trailing!,
            ),
          ],
        ],
      ),
    );

    // Contenitore con background dinamico per simulare il tocco fisico
    final Widget tileContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _isPressed ? colors.hoverOverlay : Colors.transparent,
        borderRadius: widget.isGlass
            ? BorderRadius.circular(JgSizes.radiusLarge)
            : BorderRadius.zero,
      ),
      child: content,
    );

    // Applicazione del Glassmorphism se richiesto
    final Widget finalTile = widget.isGlass
        ? JgGlassContainer(
            borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
            padding: EdgeInsets.zero,
            child: tileContainer,
          )
        : tileContainer;

    // Rilevatore di tocco
    final Widget tapDetector = GestureDetector(
      onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: finalTile,
    );

    // Aggiunta opzionale del divisore inferiore (senza interferire con il layout del vetro)
    if (widget.showDivider && !widget.isGlass) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tapDetector,
          const Divider(
            height: 1.0,
            indent: JgSizes.space16, // Lascia spazio prima del divisore per stile Apple/iOS
          ),
        ],
      );
    }

    return tapDetector;
  }
}

