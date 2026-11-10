import 'package:flutter/material.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../feedback/jg_glass_container.dart';

/// Un pulsante icona circolare minimale ed ultramoderno.
///
/// Implementa una risposta fisica di riduzione scala al tocco e
/// supporta una variante a base circolare in vetro sfocato (isGlass).
class JgIconButton extends StatefulWidget {
  /// L'icona o widget interno da mostrare.
  final Widget icon;

  /// L'azione da eseguire al tocco. Se nullo, il pulsante è disabilitato.
  final VoidCallback? onPressed;

  /// Diametro dell'area interattiva circolare. Default a 40.0.
  final double size;

  /// Dimensione imposta per le icone. Default a 20.0.
  final double iconSize;

  /// Se true, il pulsante assume un'estetica a lente in vetro sfocato.
  final bool isGlass;

  const JgIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40.0,
    this.iconSize = 20.0,
    this.isGlass = false,
  });

  @override
  State<JgIconButton> createState() => _JgIconButtonState();
}

class _JgIconButtonState extends State<JgIconButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;
    final double opacity = _isEnabled ? 1.0 : 0.4;
    final double finalScale = _isPressed ? 0.94 : 1.0;

    // Colore di sfondo dell'overlay al tocco
    final Color overlayColor = _isPressed 
        ? colors.hoverOverlay 
        : Colors.transparent;

    Widget buttonContent = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.isGlass ? Colors.transparent : overlayColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: IconTheme(
          data: IconThemeData(
            color: colors.textPrimary,
            size: widget.iconSize,
          ),
          child: widget.icon,
        ),
      ),
    );

    // Se è vetrato, avvolgiamo il contenuto in un contenitore glassmorphic circolare
    if (widget.isGlass) {
      buttonContent = JgGlassContainer(
        borderRadius: BorderRadius.circular(widget.size / 2),
        padding: EdgeInsets.zero,
        width: widget.size,
        height: widget.size,
        // Overlay scuro al tocco sopra il vetro
        backgroundColor: _isPressed ? colors.hoverOverlay : null,
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: colors.textPrimary,
              size: widget.iconSize,
            ),
            child: widget.icon,
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      enabled: _isEnabled,
      onTap: _isEnabled ? widget.onPressed : null,
      child: GestureDetector(
        onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: _isEnabled ? widget.onPressed : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: finalScale,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: Opacity(
            opacity: opacity,
            child: buttonContent,
          ),
        ),
      ),
    );
  }
}

