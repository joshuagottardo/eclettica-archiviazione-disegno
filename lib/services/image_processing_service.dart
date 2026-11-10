import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Parametri per il ridimensionamento in isolate di background.
class DownscaleParams {
  final Uint8List rawBytes;
  final int maxDimension;
  final int quality;

  DownscaleParams(this.rawBytes, {this.maxDimension = 768, this.quality = 70});
}

/// Parametri per la rotazione in isolate di background.
class RotateParams {
  final Uint8List rawBytes;
  final int degrees;
  final int quality;

  RotateParams(this.rawBytes, this.degrees, {this.quality = 92});
}

/// Elaborazione immagini tramite libreria `image` con esecuzione off-thread (`compute`).
class ImageProcessingService {
  /// Ottimizza e ridimensiona l'immagine prima della trasmissione all'API.
  static Future<Uint8List?> prepareForApi(Uint8List rawBytes) async {
    try {
      return await compute(_isolateDownscale, DownscaleParams(rawBytes, maxDimension: 768, quality: 70));
    } catch (_) {
      return null;
    }
  }

  /// Applica la rotazione fisica specificata (90, 180, 270 gradi).
  static Future<Uint8List?> rotateImage(Uint8List rawBytes, int degrees) async {
    if (degrees % 360 == 0) return rawBytes;
    try {
      return await compute(_isolateRotate, RotateParams(rawBytes, degrees));
    } catch (_) {
      return null;
    }
  }

  /// Genera un'anteprima leggera per la visualizzazione.
  static Future<Uint8List?> generateThumbnail(Uint8List rawBytes, {int maxDimension = 320}) async {
    try {
      return await compute(
        _isolateDownscale,
        DownscaleParams(rawBytes, maxDimension: maxDimension, quality: 75),
      );
    } catch (_) {
      return null;
    }
  }

  static Uint8List? _isolateDownscale(DownscaleParams params) {
    try {
      final decoded = img.decodeImage(params.rawBytes);
      if (decoded == null) return null;

      img.Image processed = decoded;
      final maxDim = decoded.width > decoded.height ? decoded.width : decoded.height;
      if (maxDim > params.maxDimension) {
        if (decoded.width >= decoded.height) {
          processed = img.copyResize(decoded, width: params.maxDimension);
        } else {
          processed = img.copyResize(decoded, height: params.maxDimension);
        }
      }

      return Uint8List.fromList(img.encodeJpg(processed, quality: params.quality));
    } catch (_) {
      return null;
    }
  }

  static Uint8List? _isolateRotate(RotateParams params) {
    try {
      final decoded = img.decodeImage(params.rawBytes);
      if (decoded == null) return null;

      final rotated = img.copyRotate(decoded, angle: params.degrees);
      return Uint8List.fromList(img.encodeJpg(rotated, quality: params.quality));
    } catch (_) {
      return null;
    }
  }
}
