import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:csv/csv.dart';
import 'package:eclettica_archiviazione_disegni/models/drawing_item.dart';
import 'package:eclettica_archiviazione_disegni/services/image_processing_service.dart';

/// Risultato riepilogativo dell'operazione di archiviazione su disco.
class ArchiveResult {
  final int totalProcessed;
  final int successCount;
  final int unknownCount;
  final int failureCount;
  final List<String> errors;
  final String? csvReportPath;

  ArchiveResult({
    required this.totalProcessed,
    required this.successCount,
    required this.unknownCount,
    required this.failureCount,
    required this.errors,
    this.csvReportPath,
  });
}

/// Servizio responsabile del salvataggio fisico, raddrizzamento delle immagini
/// e generazione del report CSV nella cartella di destinazione.
class ArchiveService {
  /// Archivia l'elenco dei disegni nella cartella di destinazione.
  static Future<ArchiveResult> archiveBatch({
    required List<DrawingItem> items,
    required String destinationRoot,
    bool copyOnly = true,
    bool applyRotation = true,
  }) async {
    final rootDir = Directory(destinationRoot);
    if (!await rootDir.exists()) {
      await rootDir.create(recursive: true);
    }

    int success = 0;
    int unknown = 0;
    int failure = 0;
    final List<String> errors = [];
    final List<List<dynamic>> csvRows = [
      [
        'Nome File Originale',
        'Codice Rilevato',
        'Codice Normalizzato',
        'Autore',
        'Stagione',
        'Numero',
        'Versione',
        'Rotazione (Gradi)',
        'Cartella Destinazione',
        'Nome File Finale',
        'Data Archiviazione',
      ]
    ];

    final nowStr = DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' ');

    for (final item in items) {
      try {
        final originalFile = File(item.originalPath);
        if (!await originalFile.exists()) {
          errors.add('${item.fileName}: file sorgente non trovato');
          failure++;
          continue;
        }

        final subFolder = item.effectiveSubFolder;
        final targetDir = Directory(p.join(destinationRoot, subFolder));
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }

        final targetFileName = item.targetFileName;
        var destinationPath = p.join(targetDir.path, targetFileName);
        destinationPath = _getUniqueFilePath(destinationPath);

        Uint8List fileBytes = await originalFile.readAsBytes();

        if (applyRotation && item.rotationDegrees != 0) {
          final rotated = await ImageProcessingService.rotateImage(fileBytes, item.rotationDegrees);
          if (rotated != null) {
            fileBytes = rotated;
          }
        }

        final targetFile = File(destinationPath);
        await targetFile.writeAsBytes(fileBytes, flush: true);

        if (!copyOnly) {
          await originalFile.delete();
        }

        if (subFolder == 'sconosciuti') {
          unknown++;
        } else {
          success++;
        }

        csvRows.add([
          item.fileName,
          item.rawDetectedCode,
          item.parsedCode?.finalCleanCode ?? '',
          item.parsedCode?.authorName ?? '',
          item.parsedCode?.season ?? '',
          item.parsedCode?.drawingNumber ?? '',
          item.parsedCode?.version ?? '',
          item.rotationDegrees,
          subFolder,
          p.basename(destinationPath),
          nowStr,
        ]);
      } catch (e) {
        errors.add('${item.fileName}: $e');
        failure++;
      }
    }

    String? csvPath;
    try {
      final csvData = csv.encode(csvRows);
      final reportFileName = 'report_archiviazione_${DateTime.now().millisecondsSinceEpoch}.csv';
      final reportFile = File(p.join(destinationRoot, reportFileName));
      await reportFile.writeAsString(csvData, flush: true);
      csvPath = reportFile.path;
    } catch (_) {
      try {
        final buffer = StringBuffer();
        for (final row in csvRows) {
          buffer.writeln(row.map((field) => '"${field.toString().replaceAll('"', '""')}"').join(','));
        }
        final reportFileName = 'report_archiviazione_${DateTime.now().millisecondsSinceEpoch}.csv';
        final reportFile = File(p.join(destinationRoot, reportFileName));
        await reportFile.writeAsString(buffer.toString(), flush: true);
        csvPath = reportFile.path;
      } catch (_) {}
    }

    return ArchiveResult(
      totalProcessed: success + unknown + failure,
      successCount: success,
      unknownCount: unknown,
      failureCount: failure,
      errors: errors,
      csvReportPath: csvPath,
    );
  }

  static String _getUniqueFilePath(String targetPath) {
    if (!File(targetPath).existsSync()) return targetPath;

    final dir = p.dirname(targetPath);
    final ext = p.extension(targetPath);
    final baseName = p.basenameWithoutExtension(targetPath);

    int counter = 1;
    while (true) {
      final candidate = p.join(dir, '${baseName}_$counter$ext');
      if (!File(candidate).existsSync()) {
        return candidate;
      }
      counter++;
    }
  }
}
