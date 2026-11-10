import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:eclettica_archiviazione_disegni/services/image_processing_service.dart';

/// Eccezione specifica per gli errori riscontrati nelle chiamate all'API Gemini.
class GeminiApiException implements Exception {
  final String userMessage;
  final int? statusCode;

  GeminiApiException(this.userMessage, {this.statusCode});

  @override
  String toString() => userMessage;
}

/// Risultato dell'analisi visiva effettuata sul disegno.
class GeminiVisionResult {
  /// Gradi di rotazione oraria necessari per raddrizzare l'immagine (0, 90, 180, 270).
  final int rotationDegrees;

  /// Codice identificativo rilevato sull'immagine (se presente).
  final String? code;

  /// Indice di confidenza della stima.
  final double confidence;

  /// Note opzionali fornite dal modello.
  final String? notes;

  GeminiVisionResult({
    required this.rotationDegrees,
    this.code,
    this.confidence = 0.0,
    this.notes,
  });
}

/// Servizio per l'interazione con l'API Google Gemini Vision.
class GeminiVisionService {
  static String _mapHttpErrorToItalian(int statusCode, String body) {
    final lower = body.toLowerCase();
    if (statusCode == 400) {
      if (lower.contains('api_key_invalid') || lower.contains('api key not valid')) {
        return 'Chiave API non valida. Verifica di averla copiata correttamente nelle Impostazioni.';
      }
      return 'Richiesta non valida o formato immagine non supportato (Errore 400).';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'Accesso negato: verifica che la tua Chiave API sia attiva e abilitata (Errore $statusCode).';
    }
    if (statusCode == 404) {
      return 'Servizio o modello AI non disponibile per questa chiave API (Errore 404).';
    }
    if (statusCode == 429) {
      return 'Limite di richieste raggiunto: attendi qualche secondo e riprova (Errore 429).';
    }
    if (statusCode >= 500) {
      return 'I server di Google AI sono temporaneamente sovraccarichi. Riprova tra poco (Errore $statusCode).';
    }
    return 'Errore di comunicazione con il servizio AI (Codice $statusCode).';
  }

  /// Invia l'immagine compressa a Gemini Vision per determinare l'orientamento
  /// e trascrivere l'eventuale codice del disegno.
  static Future<GeminiVisionResult> analyzeDrawing({
    required Uint8List imageBytes,
    required String apiKey,
    String model = 'gemini-flash-lite-latest',
  }) async {
    if (apiKey.trim().isEmpty) {
      throw GeminiApiException('Chiave API mancante. Inseriscila nelle Impostazioni.');
    }

    final apiReadyBytes = await ImageProcessingService.prepareForApi(imageBytes) ?? imageBytes;
    final base64Image = base64Encode(apiReadyBytes);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    const prompt = '''
You are an expert AI system for footwear design archiving and technical sketch digitization.
Analyze this footwear image (drawing, technical sketch, or photograph).

TASKS:
1. SHOE ORIENTATION & ROTATION:
   Determine how many degrees CLOCKWISE the image must be rotated so that the footwear stands normally (the sole/heel rests at the bottom, or boot shaft points vertically up).
   - If already upright: 0
   - If shoe tip or sole is facing left/tilted 90 deg: 90
   - If completely upside-down: 180
   - If shoe is tilted 270 deg: 270
   Value MUST be strictly one of: 0, 90, 180, 270.

2. ARCHIVAL IDENTIFICATION CODE:
   Search carefully in the corners (top-left, top-right, bottom) or near the sketch for the model/drawing code.
   - It can be typed or handwritten (e.g. "marq 63", "MARV 366/1", "mat 129").
   - It usually starts with letters, followed by a number, and sometimes a version or sub-number (/1, a, etc.).
   - Extract ONLY the identification code string.
   - Ignore general notes like "crosta", "cavallino", "collo", "NO".
   - If NO identification code is present, set code to null.

Respond strictly in valid JSON format matching this schema:
{
  "rotation_degrees": 0,
  "code": "MARV 366/1",
  "confidence": 0.95,
  "notes": "Brief explanation of orientation and detected code"
}
''';

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'response_mime_type': 'application/json',
        'temperature': 0.1,
      }
    });

    http.Response response;
    try {
      response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
    } on SocketException {
      throw GeminiApiException('Connessione internet assente o instabile. Verifica la rete e riprova.');
    } catch (_) {
      throw GeminiApiException('Impossibile contattare il server AI. Verifica la connessione.');
    }

    if (response.statusCode != 200) {
      throw GeminiApiException(
        _mapHttpErrorToItalian(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    }

    try {
      final jsonResponse = jsonDecode(response.body);
      final text = jsonResponse['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text == null) {
        throw GeminiApiException('Risposta non leggibile restituita dal servizio AI.');
      }

      final parsedData = jsonDecode(text);
      final rot = (parsedData['rotation_degrees'] as num?)?.toInt() ?? 0;
      final normalizedRot = ((rot % 360) + 360) % 360;
      final validRot = [0, 90, 180, 270].contains(normalizedRot) ? normalizedRot : 0;

      final codeRaw = parsedData['code']?.toString().trim();
      final cleanCode = (codeRaw == null || codeRaw.isEmpty || codeRaw.toLowerCase() == 'null') ? null : codeRaw;
      final conf = (parsedData['confidence'] as num?)?.toDouble() ?? 0.9;
      final notes = parsedData['notes']?.toString();

      return GeminiVisionResult(
        rotationDegrees: validRot,
        code: cleanCode,
        confidence: conf,
        notes: notes,
      );
    } catch (e) {
      if (e is GeminiApiException) rethrow;
      throw GeminiApiException('Errore nella decodifica della risposta AI.');
    }
  }
}
