import 'dart:typed_data';
import 'package:eclettica_archiviazione_disegni/services/code_parser_service.dart';

/// Stato di avanzamento e riconoscimento del singolo disegno.
enum RecognitionStatus {
  idle,
  processing,
  valid,
  warning,
  unknown,
  error,
}

/// Modello rappresentativo di un disegno calzaturiero caricato per l'elaborazione.
class DrawingItem {
  final String id;
  final String originalPath;
  final String fileName;
  final int fileSizeBytes;

  Uint8List? thumbnailBytes;
  Uint8List? codeCropBytes;

  int rotationDegrees;
  String rawDetectedCode;
  ParsedDrawingCode? parsedCode;
  double confidence;
  String? notes;

  String userOverrideCode;
  bool isManuallyEdited;
  RecognitionStatus status;
  String? errorMessage;
  bool isSelected;

  DrawingItem({
    required this.id,
    required this.originalPath,
    required this.fileName,
    required this.fileSizeBytes,
    this.thumbnailBytes,
    this.codeCropBytes,
    this.rotationDegrees = 0,
    this.rawDetectedCode = '',
    this.parsedCode,
    this.confidence = 0.0,
    this.notes,
    this.userOverrideCode = '',
    this.isManuallyEdited = false,
    this.status = RecognitionStatus.idle,
    this.errorMessage,
    this.isSelected = true,
  });

  /// Codice effettivo (eventuale override manuale o rilevato dall'AI).
  String get effectiveCode {
    if (isManuallyEdited && userOverrideCode.trim().isNotEmpty) {
      return userOverrideCode.trim();
    }
    return rawDetectedCode.trim();
  }

  /// Sottocartella di destinazione (es. "MARIANNA/Q" o "sconosciuti").
  String get effectiveSubFolder {
    if (parsedCode != null && parsedCode!.targetSubFolder.isNotEmpty) {
      return parsedCode!.targetSubFolder;
    }
    return 'sconosciuti';
  }

  /// Nome finale del file da salvare in archivio.
  String get targetFileName {
    final ext = fileName.contains('.') ? '.${fileName.split('.').last}' : '.jpg';
    if (parsedCode != null && parsedCode!.isValid) {
      return '${parsedCode!.finalCleanCode}$ext';
    }
    return fileName;
  }
}
