import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../feedback/jg_glass_container.dart';

/// Una card espandibile (Accordion) ad effetto vetro sfocato.
///
/// Permette di nascondere o rivelare contenuti secondari premendo sull'intestazione.
/// Gestisce l'espansione dell'altezza con una curva fluida [Curves.easeInOutCubic]
/// e la rotazione di 180 gradi del chevron icona.
class JgAccordion extends StatefulWidget {
  /// Titolo visualizzato nell'intestazione (header).
  final Widget title;

  /// Sottotitolo opzionale posizionato sotto il titolo.
  final Widget? subtitle;

  /// Elemento grafico opzionale (es. icona) posizionato a sinistra.
  final Widget? leading;

  /// Contenuto nascosto che si rivela all'espansione.
  final Widget child;

  /// Se true, l'accordion è inizialmente espanso. Di default è false.
  final bool initiallyExpanded;

  /// Callback opzionale invocato al cambio dello stato di espansione.
  final ValueChanged<bool>? onExpansionChanged;

  const JgAccordion({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<JgAccordion> createState() => _JgAccordionState();
}

class _JgAccordionState extends State<JgAccordion> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _isExpanded ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    if (widget.onExpansionChanged != null) {
      widget.onExpansionChanged!(_isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;

    return JgGlassContainer(
      padding: EdgeInsets.zero, // Padding gestito internamente per allineamento
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header cliccabile
          GestureDetector(
            onTap: _toggleExpansion,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(JgSizes.space16),
              child: Row(
                children: [
                  if (widget.leading != null) ...[
                    widget.leading!,
                    const SizedBox(width: JgSizes.space16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DefaultTextStyle.merge(
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                          child: widget.title,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: JgSizes.space4),
                          DefaultTextStyle.merge(
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                            child: widget.subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: JgSizes.space12),
                  // Chevron rotante a 180°
                  RotationTransition(
                    turns: Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      size: 16.0,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sezione corpo espandibile
          ClipRect(
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: JgSizes.space16,
                  right: JgSizes.space16,
                  bottom: JgSizes.space16,
                ),
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

