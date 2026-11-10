import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import 'jg_glass_container.dart';

/// Mostra un pannello inferiore modale ad effetto vetro sfocato (Glassmorphism).
///
/// La funzione avvolge [showModalBottomSheet] impostando lo sfondo a trasparente
/// e inserendo un wrapper che gestisce il filtro sfocatura, il trascinamento elastico
/// e la maniglia di presa superiore (drag handle).
Future<T?> showJgBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  double? heightFactor, // Proporzione dell'altezza (es. 0.5 per il 50% dello schermo)
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (context) {
      return _JgBottomSheetWrapper(
        enableDrag: enableDrag,
        heightFactor: heightFactor,
        child: child,
      );
    },
  );
}

class _JgBottomSheetWrapper extends StatelessWidget {
  final Widget child;
  final bool enableDrag;
  final double? heightFactor;

  const _JgBottomSheetWrapper({
    required this.child,
    required this.enableDrag,
    this.heightFactor,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Maniglia di trascinamento superiore (drag handle style Apple)
        if (enableDrag)
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(
                top: JgSizes.space12,
                bottom: JgSizes.space8,
              ),
              width: 36.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(JgSizes.radiusCircular),
              ),
            ),
          )
        else
          const SizedBox(height: JgSizes.space20),
        
        // Contenuto principale flessibile
        Flexible(
          child: child,
        ),
        
        // Spazio inferiore per la tastiera e la safe area
        SizedBox(
          height: MediaQuery.of(context).viewInsets.bottom + 
              MediaQuery.of(context).padding.bottom + 
              JgSizes.space12,
        ),
      ],
    );

    if (heightFactor != null) {
      content = FractionallySizedBox(
        heightFactor: heightFactor,
        child: content,
      );
    }

    return JgGlassContainer(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(JgSizes.radiusXLarge),
      ),
      padding: EdgeInsets.zero,
      child: content,
    );
  }
}
