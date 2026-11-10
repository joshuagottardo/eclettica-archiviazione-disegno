import 'package:flutter/material.dart';
import '../../foundations/jg_control_size.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../../theme/extensions/jg_sizes_theme.dart';

/// Enum per definire lo stile visivo di [JgButton].
enum JgButtonStyle {
  /// Sfondo accentato solido, testo contrastante.
  primary,

  /// Effetto vetro sfocato con bordo hairline (Glassmorphism).
  glass,

  /// Completamente trasparente, solo testo ed eventuale icona.
  ghost,
}

/// Un pulsante ultramoderno, fluido e minimale.
///
/// Implementa una micro-interazione fisica di riduzione scala alla pressione
/// e supporta tre stili visivi coerenti con l'estetica svizzera e Apple.
class JgButton extends StatefulWidget {
  /// L'azione da eseguire alla pressione. Se nullo, il pulsante è disabilitato.
  final VoidCallback? onPressed;

  /// Il contenuto del pulsante (solitamente un [Text] o un [Row] complesso).
  final Widget child;

  /// Lo stile del pulsante. Di default è [JgButtonStyle.primary].
  final JgButtonStyle style;

  /// Larghezza fissa del pulsante. Se nullo, si adatta al contenuto o espande.
  final double? width;

  /// Altezza fissa del pulsante. Se nullo, viene risolta dinamicamente in base a [controlSize].
  final double? height;

  /// Dimensione del controllo (small, medium, large). Default a [JgControlSize.medium].
  final JgControlSize controlSize;

  /// Icona opzionale da posizionare prima del testo.
  final Widget? icon;

  /// Se impostato a true, mostra un indicatore di caricamento e disabilita il click.
  final bool loading;

  const JgButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style = JgButtonStyle.primary,
    this.width,
    this.height,
    this.controlSize = JgControlSize.medium,
    this.icon,
    this.loading = false,
  });

  @override
  State<JgButton> createState() => _JgButtonState();
}

class _JgButtonState extends State<JgButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _isEnabled => widget.onPressed != null && !widget.loading;

  double _resolveHeight(JgControlSize size, JgSizesTheme theme) {
    switch (size) {
      case JgControlSize.small:
        return 36.0;
      case JgControlSize.medium:
        return 42.0;
      case JgControlSize.large:
        return 50.0;
    }
  }

  EdgeInsets _resolvePadding(JgControlSize size, JgSizesTheme theme) {
    switch (size) {
      case JgControlSize.small:
        return const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0);
      case JgControlSize.medium:
        return const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0);
      case JgControlSize.large:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0);
    }
  }

  double _resolveBorderRadius(JgControlSize size, JgSizesTheme theme) {
    switch (size) {
      case JgControlSize.small:
        return 10.0;
      case JgControlSize.medium:
        return 12.0;
      case JgControlSize.large:
        return 14.0;
    }
  }

  double _resolveFontSize(JgControlSize size) {
    switch (size) {
      case JgControlSize.small:
        return 13.0;
      case JgControlSize.medium:
        return 14.0;
      case JgControlSize.large:
        return 15.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double opacity = _isEnabled ? 1.0 : 0.42;
    final sizesTheme = context.jgSizes;
    final double effectiveHeight = widget.height ?? _resolveHeight(widget.controlSize, sizesTheme);

    Widget buttonBody = SizedBox(
      width: widget.width,
      height: effectiveHeight,
      child: _buildButtonContent(context, sizesTheme),
    );

    if (widget.width == null) {
      buttonBody = IntrinsicWidth(child: buttonBody);
    }

    return Semantics(
      button: true,
      enabled: _isEnabled,
      onTap: _isEnabled ? widget.onPressed : null,
      child: MouseRegion(
        cursor: _isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) {
          if (_isEnabled) setState(() => _isHovered = true);
        },
        onExit: (_) {
          if (_isHovered) setState(() => _isHovered = false);
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
          onTap: _isEnabled ? widget.onPressed : null,
          child: AnimatedScale(
            scale: _isPressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutCubic,
            child: Opacity(
              opacity: opacity,
              child: buttonBody,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context, JgSizesTheme sizesTheme) {
    final colors = context.jgColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color textColor = widget.style == JgButtonStyle.primary
        ? Theme.of(context).colorScheme.onPrimary
        : colors.textPrimary;

    final double fontSize = _resolveFontSize(widget.controlSize);
    final EdgeInsets padding = _resolvePadding(widget.controlSize, sizesTheme);
    final double radius = _resolveBorderRadius(widget.controlSize, sizesTheme);

    final Widget labelAndIcon = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.loading) ...[
          _buildLoader(textColor),
          const SizedBox(width: JgSizes.space8),
        ] else if (widget.icon != null) ...[
          IconTheme.merge(
            data: IconThemeData(
              color: textColor,
              size: fontSize + 3.0,
            ),
            child: widget.icon!,
          ),
          const SizedBox(width: JgSizes.space8),
        ],
        Flexible(
          child: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                  letterSpacing: -0.1,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            child: widget.child,
          ),
        ),
      ],
    );

    switch (widget.style) {
      case JgButtonStyle.primary:
        final baseColor = colors.accent;
        final hoverColor = isDark
            ? baseColor.withValues(alpha: 0.90)
            : baseColor.withValues(alpha: 0.85);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : baseColor,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: _isEnabled
                ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: isDark ? 0.16 : 0.22),
                      blurRadius: _isHovered ? 14 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          padding: padding,
          child: labelAndIcon,
        );

      case JgButtonStyle.glass:
        final bg = isDark
            ? (_isHovered ? const Color(0x28FFFFFF) : const Color(0x16FFFFFF))
            : (_isHovered ? const Color(0xEBFFFFFF) : const Color(0xD9FFFFFF));
        final borderCol = isDark
            ? (_isHovered ? const Color(0x45FFFFFF) : const Color(0x26FFFFFF))
            : (_isHovered ? const Color(0x29000000) : const Color(0x17000000));
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderCol, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: padding,
          child: labelAndIcon,
        );

      case JgButtonStyle.ghost:
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered ? colors.hoverOverlay : Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          padding: padding,
          child: labelAndIcon,
        );
    }
  }

  Widget _buildLoader(Color color) {
    return SizedBox(
      width: 16.0,
      height: 16.0,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

