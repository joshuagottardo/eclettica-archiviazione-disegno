import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:eclettica_archiviazione_disegni/models/drawing_item.dart';
import 'package:eclettica_archiviazione_disegni/services/code_parser_service.dart';
import 'package:eclettica_archiviazione_disegni/services/gemini_vision_service.dart';
import 'package:eclettica_archiviazione_disegni/services/image_processing_service.dart';
import 'package:eclettica_archiviazione_disegni/services/settings_service.dart';
import 'package:eclettica_archiviazione_disegni/services/archive_service.dart';

/// Controller principale per la gestione del batch di disegni.
class DrawingBatchController extends ChangeNotifier {
  List<DrawingItem> _items = [];
  bool _isProcessing = false;
  bool _isArchiving = false;
  int _currentIndex = 0;
  String _currentOperationText = '';
  Map<String, String> _authorMap = SettingsService.defaultAuthorMap;
  String _apiKey = '';
  String _model = SettingsService.defaultModel;
  String _destinationFolder = '';
  bool _debugMode = false;

  List<DrawingItem> get items => _items;
  bool get isProcessing => _isProcessing;
  bool get isArchiving => _isArchiving;
  int get currentIndex => _currentIndex;
  int get totalCount => _items.length;
  String get currentOperationText => _currentOperationText;
  Map<String, String> get authorMap => _authorMap;
  String get apiKey => _apiKey;
  String get model => _model;
  String get destinationFolder => _destinationFolder;
  bool get debugMode => _debugMode;

  int get validCount => _items.where((i) => i.status == RecognitionStatus.valid).length;
  int get unknownCount => _items.where((i) => i.status == RecognitionStatus.unknown).length;
  int get warningCount => _items.where((i) => i.status == RecognitionStatus.warning).length;
  int get errorCount => _items.where((i) => i.status == RecognitionStatus.error).length;
  int get processedCount => _items.where((i) => i.status != RecognitionStatus.idle && i.status != RecognitionStatus.processing).length;

  DrawingBatchController() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _apiKey = await SettingsService.getApiKey();
    _model = SettingsService.defaultModel;
    _destinationFolder = await SettingsService.getDestinationFolder();
    _authorMap = await SettingsService.getAuthorMap();
    _debugMode = await SettingsService.getDebugMode();
    notifyListeners();
  }

  Future<void> updateSettings({
    String? apiKey,
    String? model,
    String? destinationFolder,
    Map<String, String>? authorMap,
    bool? debugMode,
  }) async {
    if (apiKey != null) {
      _apiKey = apiKey;
      await SettingsService.setApiKey(apiKey);
    }
    _model = SettingsService.defaultModel;
    if (destinationFolder != null) {
      _destinationFolder = destinationFolder;
      await SettingsService.setDestinationFolder(destinationFolder);
    }
    if (authorMap != null) {
      _authorMap = authorMap;
      await SettingsService.setAuthorMap(authorMap);
      _reEvaluateAllCodes();
    }
    if (debugMode != null) {
      _debugMode = debugMode;
      await SettingsService.setDebugMode(debugMode);
    }
    notifyListeners();
  }

  Future<void> addAuthor(String code, String name) async {
    _authorMap[code.toUpperCase()] = name.toUpperCase();
    await SettingsService.setAuthorMap(_authorMap);
    _reEvaluateAllCodes();
    notifyListeners();
  }

  void _reEvaluateAllCodes() {
    for (final item in _items) {
      final codeToParse = item.effectiveCode;
      item.parsedCode = CodeParserService.parse(codeToParse, _authorMap);
      if (item.parsedCode != null) {
        if (item.parsedCode!.isValid) {
          item.status = RecognitionStatus.valid;
        } else if (item.parsedCode!.targetSubFolder == 'sconosciuti') {
          item.status = RecognitionStatus.unknown;
        } else {
          item.status = RecognitionStatus.warning;
        }
      }
    }
  }

  /// Carica i file immagine presenti nella cartella selezionata.
  Future<void> loadDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) return;

      final List<DrawingItem> loaded = [];
      final supportedExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.tif', '.tiff'];

      final entities = await dir.list(followLinks: false).toList();
      entities.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

      for (final entity in entities) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(ext)) {
            final stat = await entity.stat();
            loaded.add(DrawingItem(
              id: entity.path,
              originalPath: entity.path,
              fileName: p.basename(entity.path),
              fileSizeBytes: stat.size,
            ));
          }
        }
      }

      _items = loaded;
      notifyListeners();

      _generateThumbnails();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _generateThumbnails() async {
    for (final item in _items) {
      if (item.thumbnailBytes == null) {
        try {
          final file = File(item.originalPath);
          final bytes = await file.readAsBytes();
          item.thumbnailBytes = await ImageProcessingService.generateThumbnail(bytes);
          notifyListeners();
        } catch (_) {}
      }
    }
  }

  /// Elabora i disegni in batch concorrente (3 chiamate parallele).
  Future<void> processBatch({int concurrency = 3}) async {
    if (_items.isEmpty) return;
    _isProcessing = true;
    _currentIndex = 0;
    _currentOperationText = 'Avvio elaborazione...';
    notifyListeners();

    int completedCount = 0;
    final total = _items.length;

    Future<void> processSingleItem(DrawingItem item) async {
      item.status = RecognitionStatus.processing;
      notifyListeners();

      try {
        final file = File(item.originalPath);
        final bytes = await file.readAsBytes();

        final result = await GeminiVisionService.analyzeDrawing(
          imageBytes: bytes,
          apiKey: _apiKey,
          model: _model,
        );

        item.rotationDegrees = result.rotationDegrees;
        item.rawDetectedCode = result.code ?? '';
        item.confidence = result.confidence;
        item.notes = result.notes;

        item.parsedCode = CodeParserService.parse(result.code, _authorMap);

        if (item.parsedCode == null || !item.parsedCode!.isValid) {
          if (item.parsedCode?.targetSubFolder == 'sconosciuti') {
            item.status = RecognitionStatus.unknown;
          } else {
            item.status = RecognitionStatus.warning;
          }
        } else {
          item.status = RecognitionStatus.valid;
        }
      } catch (e) {
        item.status = RecognitionStatus.error;
        item.errorMessage = e.toString();
      } finally {
        completedCount++;
        _currentIndex = completedCount;
        _currentOperationText = 'Elaborati $completedCount di $total disegni...';
        notifyListeners();
      }
    }

    for (int i = 0; i < _items.length; i += concurrency) {
      final end = (i + concurrency < _items.length) ? i + concurrency : _items.length;
      final currentChunk = _items.sublist(i, end);
      await Future.wait(currentChunk.map(processSingleItem));
    }

    _isProcessing = false;
    _currentOperationText = 'Elaborazione completata!';
    notifyListeners();
  }

  /// Ruota manualmente un disegno (+90 o -90 gradi).
  void rotateItem(String id, int deltaDegrees) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final current = _items[index].rotationDegrees;
      _items[index].rotationDegrees = ((current + deltaDegrees) % 360 + 360) % 360;
      notifyListeners();
    }
  }

  /// Aggiorna manualmente il codice di un disegno.
  void updateItemCode(String id, String newCode) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = _items[index];
      item.userOverrideCode = newCode;
      item.isManuallyEdited = true;
      item.parsedCode = CodeParserService.parse(newCode, _authorMap);

      if (item.parsedCode!.isValid) {
        item.status = RecognitionStatus.valid;
      } else if (item.parsedCode!.targetSubFolder == 'sconosciuti') {
        item.status = RecognitionStatus.unknown;
      } else {
        item.status = RecognitionStatus.warning;
      }
      notifyListeners();
    }
  }

  /// Salva e organizza fisicamente i disegni nella cartella di destinazione.
  Future<ArchiveResult> archiveAll({bool copyOnly = true}) async {
    if (_destinationFolder.isEmpty) {
      throw Exception('Cartella di destinazione non selezionata.');
    }

    _isArchiving = true;
    _currentOperationText = 'Salvataggio in corso...';
    notifyListeners();

    try {
      final result = await ArchiveService.archiveBatch(
        items: _items,
        destinationRoot: _destinationFolder,
        copyOnly: copyOnly,
        applyRotation: true,
      );
      return result;
    } finally {
      _isArchiving = false;
      _currentOperationText = 'Salvataggio completato!';
      notifyListeners();
    }
  }
}
