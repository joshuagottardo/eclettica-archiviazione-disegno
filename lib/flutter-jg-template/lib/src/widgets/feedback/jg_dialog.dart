import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import 'jg_glass_container.dart';

/// Un modale ad effetto vetro sfocato (Glassmorphic Dialog) in stile Apple.
///
/// Viene solitamente mostrato tramite la funzione di utilità [showJgDialog].
class JgDialog extends StatelessWidget {
  /// Titolo principale del modale.
  final Widget title;

  /// Il contenuto interno del modale.
  final Widget content;

  /// Lista dei pulsanti d'azione (solitamente [JgButton]).
  final List<Widget> actions;

  /// Larghezza massima del modale. Default a 320.0 per una compattezza elegante.
  final double maxWidth;

  const JgDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.maxWidth = 320.0,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.all(JgSizes.space24),
        child: Material(
          color: Colors.transparent,
          child: JgGlassContainer(
            borderRadius: BorderRadius.circular(JgSizes.radiusXLarge),
            padding: const EdgeInsets.all(JgSizes.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titolo Bold (Stile Svizzero)
                DefaultTextStyle.merge(
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                  child: title,
                ),
                const SizedBox(height: JgSizes.space12),

                // Contenuto
                DefaultTextStyle.merge(
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                  child: content,
                ),
                const SizedBox(height: JgSizes.space24),

                // Azioni ordinate in modo geometrico
                if (actions.length == 2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(child: actions[0]),
                      const SizedBox(width: JgSizes.space12),
                      Flexible(child: actions[1]),
                    ],
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < actions.length; i++) ...[
                        actions[i],
                        if (i < actions.length - 1)
                          const SizedBox(height: JgSizes.space8),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Visualizza un modale [JgDialog] con un'animazione di scala elastica e dissolvenza.
///
/// [barrierDismissible] consente la chiusura toccando all'esterno della finestra.
Future<T?> showJgDialog<T>({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required List<Widget> actions,
  bool barrierDismissible = true,
  double maxWidth = 320.0,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss Dialog',
    barrierColor: const Color(0x4D000000), // Sfondo nero oscurato al 30% per far risaltare il vetro sfocato
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return JgDialog(
        title: title,
        content: content,
        actions: actions,
        maxWidth: maxWidth,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Curva elastica per un rimbalzo morbido all'apertura, ma fluida in chiusura
      final double scaleValue = animation.status == AnimationStatus.reverse
          ? Curves.easeInOutCubic.transform(animation.value)
          : Curves.easeOutBack.transform(animation.value);

      final double scale = 0.9 + (scaleValue * 0.1);
      final double opacity = Curves.easeOut.transform(animation.value);

      return Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      );
    },
  );
}

