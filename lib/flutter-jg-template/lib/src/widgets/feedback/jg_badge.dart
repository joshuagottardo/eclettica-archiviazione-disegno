import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import 'jg_glass_container.dart';

/// Stili grafici supportati da [JgBadge].
enum JgBadgeStyle {
  /// Sfondo bianco/nero solido con testo contrastante
  solid,

  /// Sfondo in vetro semi-trasparente (12% opacità) con testo colorato
  glass,

  /// Sfondo trasparente con bordo hairline e testo colorato
  outline,
}

/// Un tag/badge geometrico e minimale in stile svizzero.
///
/// Adotta testi in maiuscolo spaziati ed è adatto per mostrare stati,
/// categorie, contatori o etichette rapide all'interno dell'interfaccia.
class JgBadge extends StatelessWidget {
  /// Testo da visualizzare all'interno del badge.
  final String label;

  /// Lo stile visivo del badge (solid, glass, outline).
  final JgBadgeStyle style;

  /// Icona opzionale da visualizzare a sinistra del testo.
  final IconData? icon;

  /// Colore principale personalizzato che sostituisce l'accento standard.
  final Color? customColor;

  const JgBadge({
    super.key,
    required this.label,
    this.style = JgBadgeStyle.glass,
    this.icon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color activeColor = customColor ?? theme.colorScheme.primary;
    
    // Calcoliamo il colore del testo/icona basandoci sul contrasto dello stile
    final Color onActiveColor = style == JgBadgeStyle.solid
        ? (customColor != null
            ? (ThemeData.estimateBrightnessForColor(customColor!) == Brightness.dark
                ? Colors.white
                : Colors.black)
            : theme.colorScheme.onPrimary)
        : activeColor;

    final textStyle = theme.textTheme.labelSmall?.copyWith(
          fontSize: 9.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 10.0,
            color: onActiveColor,
          ),
          const SizedBox(width: JgSizes.space4),
        ],
        Text(
          label.toUpperCase(),
          style: textStyle?.copyWith(
            color: onActiveColor,
          ),
        ),
      ],
    );

    // Padding calibrato (molto sottile, griglia svizzera)
    final EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: JgSizes.space8,
      vertical: JgSizes.space4,
    );

    final BorderRadius radius = BorderRadius.circular(JgSizes.radiusCircular);

    switch (style) {
      case JgBadgeStyle.solid:
        return Container(
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: radius,
          ),
          padding: padding,
          child: content,
        );

      case JgBadgeStyle.glass:
        // Riutilizziamo la logica di JgGlassContainer per un effetto vetro coerente
        return JgGlassContainer(
          borderRadius: radius,
          padding: padding,
          backgroundColor: activeColor.withValues(alpha: 0.12),
          child: content,
        );

      case JgBadgeStyle.outline:
        return Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: radius,
            border: Border.all(
              color: activeColor.withValues(alpha: 0.4),
              width: JgSizes.borderHairline,
            ),
          ),
          padding: padding,
          child: content,
        );
    }
  }
}
