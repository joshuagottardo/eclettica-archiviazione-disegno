import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Gestisce lo stato delle prestazioni del Design System [jg_design_system].
///
/// Permette di abilitare o disabilitare dinamicamente gli effetti grafici pesanti
/// (es. BackdropFilter) in base a misurazioni dei frame timing o preferenze utente.
class JgPerformance {
  JgPerformance._();

  /// Notifica se il sistema si trova in uno stato di basse prestazioni o risparmio energetico.
  ///
  /// Quando impostato a true, i widget vitrei evitano il BackdropFilter.
  static final ValueNotifier<bool> lowPerformanceNotifier = ValueNotifier<bool>(false);

  /// Indica se la modalità è stata impostata manualmente dall'utente.
  static bool _isManualOverride = false;

  /// Riferimento al callback registrato per i timing dei frame.
  static TimingsCallback? _timingsCallback;

  /// Inizializza il monitoraggio automatico delle prestazioni.
  ///
  /// Se [autoDetect] è true, monitora i timing di frame forniti dal motore di Flutter.
  /// [droppedFrameThreshold] indica la percentuale massima tollerabile di frame lenti (default 15%).
  static void init({
    bool autoDetect = true,
    double droppedFrameThreshold = 0.15,
  }) {
    if (autoDetect && !kIsWeb) {
      int slowFrames = 0;
      int totalFrames = 0;

      // Evita doppie registrazioni rimuovendo il callback precedente se esistente
      if (_timingsCallback != null) {
        SchedulerBinding.instance.removeTimingsCallback(_timingsCallback!);
      }

      _timingsCallback = (List<FrameTiming> timings) {
        // Se c'è un override manuale, ignoriamo i timing automatici
        if (_isManualOverride) return;

        for (final timing in timings) {
          totalFrames++;
          // Se il frame richiede più di 33ms per build + raster (limite ~30fps)
          final durationMs = timing.totalSpan.inMilliseconds;
          if (durationMs > 33) {
            slowFrames++;
          }
        }

        // Analizziamo su una finestra di 100 fotogrammi
        if (totalFrames >= 100) {
          final slowRate = slowFrames / totalFrames;
          final shouldBeLowPerf = slowRate > droppedFrameThreshold;

          if (lowPerformanceNotifier.value != shouldBeLowPerf) {
            // Rinviamo l'aggiornamento dello stato alla fine del frame corrente
            // per evitare di innescare un rebuild durante la fase di build
            SchedulerBinding.instance.addPostFrameCallback((_) {
              lowPerformanceNotifier.value = shouldBeLowPerf;
            });
          }
          slowFrames = 0;
          totalFrames = 0;
        }
      };

      // Usa l'API ufficiale di SchedulerBinding invece di sovrascrivere PlatformDispatcher.onReportTimings
      SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
    }
  }

  /// Forza manualmente la modalità a basse prestazioni.
  static void setLowPerformanceMode(bool enabled) {
    _isManualOverride = true;
    lowPerformanceNotifier.value = enabled;
  }

  /// Rilascia i callback registrati e reimposta lo stato.
  static void reset() {
    _isManualOverride = false;
    lowPerformanceNotifier.value = false;
    if (_timingsCallback != null) {
      SchedulerBinding.instance.removeTimingsCallback(_timingsCallback!);
      _timingsCallback = null;
    }
  }
}
