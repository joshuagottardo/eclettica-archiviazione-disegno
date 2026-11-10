import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import 'jg_glass_container.dart';

/// Tipologia di notifica per definire l'estetica visiva di [JgToast].
enum JgToastType {
  /// Informativo
  info,

  /// Successo
  success,

  /// Errore/Problema
  error,
}

/// Gestore statico globale per visualizzare notifiche `JgToast` ad effetto "Dynamic Island".
///
/// Disegna una pillola vetrata che fluttua in alto al centro dello schermo.
class JgToast {
  JgToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  /// Mostra un toast Dynamic Island. Se ce n'è già uno attivo, viene rimosso immediatamente.
  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    JgToastType type = JgToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Rimuove immediatamente il toast corrente se attivo
    dismiss();

    final entry = OverlayEntry(
      builder: (context) => _JgToastWidget(
        message: message,
        icon: icon,
        type: type,
        duration: duration,
        onDismiss: () => dismiss(),
      ),
    );

    _currentEntry = entry;
    Overlay.of(context).insert(entry);
  }

  /// Nasconde e rimuove immediatamente la notifica corrente.
  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    if (_currentEntry != null) {
      _currentEntry!.remove();
      _currentEntry = null;
    }
  }
}

class _JgToastWidget extends StatefulWidget {
  final String message;
  final IconData? icon;
  final JgToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _JgToastWidget({
    required this.message,
    this.icon,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_JgToastWidget> createState() => _JgToastWidgetState();
}

class _JgToastWidgetState extends State<_JgToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _dismissTimer;

  // TweenSequence per l'ingresso asimmetrico Squash & Stretch
  // 1. Spostamento verticale (yOffset): cade dall'alto, fa un piccolo rimbalzo e si ferma a 24.0
  final _yOffsetSequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: -80.0, end: 28.0).chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 70.0,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 28.0, end: 24.0).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: 30.0,
    ),
  ]);

  // 2. Dissolvenza (opacity)
  final _opacitySequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30.0,
    ),
    TweenSequenceItem(
      tween: ConstantTween<double>(1.0),
      weight: 70.0,
    ),
  ]);

  // 3. Deformazione orizzontale (scaleX): inizia sottile come goccia, si schiaccia all'impatto, si stabilizza
  final _scaleXSequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.5, end: 0.85).chain(CurveTween(curve: Curves.easeOut)),
      weight: 50.0,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.85, end: 1.08).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25.0,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25.0,
    ),
  ]);

  // 4. Deformazione verticale (scaleY): cade allungandosi, si schiaccia sul fondo, si stabilizza
  final _scaleYSequence = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.3, end: 1.20).chain(CurveTween(curve: Curves.easeOut)),
      weight: 50.0,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 1.20, end: 0.85).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25.0,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: 0.85, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 25.0,
    ),
  ]);

  @override
  void initState() {
    super.initState();
    // 450ms per l'ingresso garantiscono che l'effetto elastico sia percepibile ma rapido
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _controller.forward().then((_) {
      // Avvia il timer di auto-dismiss al termine dell'animazione d'ingresso
      _dismissTimer = Timer(widget.duration, _startExitAnimation);
    });
  }

  void _startExitAnimation() {
    if (mounted) {
      _controller.reverse().then((_) {
        widget.onDismiss();
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        
        double scaleX = 1.0;
        double scaleY = 1.0;
        double yOffset = 24.0;
        double opacity = 1.0;

        if (_controller.status == AnimationStatus.reverse) {
          // --- Animazione di Uscita (Maniacale) ---
          // Il toast si appiattisce a fisarmonica e viene risucchiato verso l'alto
          opacity = t;
          yOffset = -80.0 + (104.0 * t); // scorre verso l'alto fino a -80
          scaleY = 0.2 + (0.8 * t);      // si schiaccia forte in verticale
          scaleX = 0.85 + (0.15 * t);    // si stringe leggermente in orizzontale
        } else {
          // --- Animazione di Ingresso (Maniacale) ---
          // Applica i TweenSequence elasticizzati
          scaleX = _scaleXSequence.evaluate(_controller);
          scaleY = _scaleYSequence.evaluate(_controller);
          yOffset = _yOffsetSequence.evaluate(_controller);
          opacity = _opacitySequence.evaluate(_controller);
        }

        return Positioned(
          top: MediaQuery.of(context).padding.top + yOffset,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
                child: _buildToastContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToastContent() {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;

    // Colori e icone in base al tipo di notifica
    late Color accentColor;
    late IconData defaultIcon;

    switch (widget.type) {
      case JgToastType.info:
        accentColor = colors.textPrimary;
        defaultIcon = CupertinoIcons.info_circle;
        break;
      case JgToastType.success:
        accentColor = colors.success;
        defaultIcon = CupertinoIcons.checkmark_circle;
        break;
      case JgToastType.error:
        accentColor = colors.error;
        defaultIcon = CupertinoIcons.exclamationmark_circle;
        break;
    }

    final IconData iconToUse = widget.icon ?? defaultIcon;

    return JgGlassContainer(
      borderRadius: BorderRadius.circular(JgSizes.radiusCircular), // Pillola
      padding: const EdgeInsets.symmetric(
        horizontal: JgSizes.space16,
        vertical: JgSizes.space8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icona colorata
          Icon(
            iconToUse,
            color: accentColor,
            size: 18.0,
          ),
          const SizedBox(width: JgSizes.space12),
          
          // Messaggio (Stile Svizzero, pulito ed essenziale)
          Flexible(
            child: Text(
              widget.message,
              style: textTheme.labelLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

