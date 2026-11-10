/// Modello dati del codice disegno analizzato e normalizzato.
class ParsedDrawingCode {
  /// Stringa del codice originale rilevato dall'immagine.
  final String rawCode;

  /// Sigla dell'autore (es. MAR, MAT).
  final String? authorCode;

  /// Nome completo dell'autore configurato nella mappa (es. MARIANNA).
  final String? authorName;

  /// Lettera della stagione (es. V, Q, E, I).
  final String? season;

  /// Numero progressivo del disegno.
  final String? drawingNumber;

  /// Eventuale variante o versione (es. 1, 2, A).
  final String? version;

  /// Indica se il codice rispetta la sintassi ed è presente nella mappa autori.
  final bool isValid;

  /// Percorso della cartella di destinazione (es. 'MARIANNA/Q' o 'sconosciuti').
  final String targetSubFolder;

  const ParsedDrawingCode({
    required this.rawCode,
    this.authorCode,
    this.authorName,
    this.season,
    this.drawingNumber,
    this.version,
    required this.isValid,
    required this.targetSubFolder,
  });

  /// Crea un'istanza per codici non riconosciuti o assenti.
  factory ParsedDrawingCode.unknown([String raw = '']) {
    return ParsedDrawingCode(
      rawCode: raw,
      isValid: false,
      targetSubFolder: 'sconosciuti',
    );
  }

  /// Nome normalizzato del file per l'archiviazione (es. MARV366_1).
  String get finalCleanCode {
    if (!isValid || authorCode == null || season == null || drawingNumber == null) {
      return rawCode.replaceAll(RegExp(r'\s+'), '');
    }
    final v = (version != null && version!.isNotEmpty) ? '_$version' : '';
    return '$authorCode$season$drawingNumber$v';
  }
}

/// Servizio di parsing e normalizzazione delle sigle dei disegni tecnici.
class CodeParserService {
  /// Analizza una stringa e restituisce il codice strutturato.
  /// Se l'autore non è presente nella mappa, la destinazione assegnata è 'sconosciuti'.
  static ParsedDrawingCode parse(String? raw, Map<String, String> authorMap) {
    if (raw == null || raw.trim().isEmpty || raw.toUpperCase().contains('NOT_FOUND')) {
      return ParsedDrawingCode.unknown(raw ?? '');
    }

    final trimmed = raw.trim();
    var cleaned = trimmed.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*[/\\-]\s*'), '/');

    final regex = RegExp(
      r'^([A-Za-z]{2,4})\s*([0-9]+)(?:[/_\s]*([A-Za-z0-9]+))?$',
    );

    final match = regex.firstMatch(cleaned);
    if (match != null) {
      final prefix = match.group(1)!;
      final number = match.group(2)!;
      final version = match.group(3);

      final upperPrefix = prefix.toUpperCase();

      // Risoluzione autore con priorità al match più lungo
      final sortedAuthors = authorMap.keys.toList()
        ..sort((a, b) => b.length.compareTo(a.length));

      String? matchedAuthorCode;
      String? matchedAuthorName;
      String? season;

      for (final code in sortedAuthors) {
        final upperCode = code.toUpperCase();
        if (upperPrefix.startsWith(upperCode)) {
          final remainder = upperPrefix.substring(upperCode.length);
          if (remainder.length == 1) {
            matchedAuthorCode = upperCode;
            matchedAuthorName = authorMap[code]?.toUpperCase() ?? upperCode;
            season = remainder;
            break;
          }
        }
      }

      if (matchedAuthorCode != null && season != null) {
        return ParsedDrawingCode(
          rawCode: cleaned,
          authorCode: matchedAuthorCode,
          authorName: matchedAuthorName,
          season: season,
          drawingNumber: number,
          version: version,
          isValid: true,
          targetSubFolder: '$matchedAuthorName/$season',
        );
      }

      if (prefix.length >= 3) {
        final potAuthor = upperPrefix.substring(0, upperPrefix.length - 1);
        final potSeason = upperPrefix.substring(upperPrefix.length - 1);
        return ParsedDrawingCode(
          rawCode: cleaned,
          authorCode: potAuthor,
          authorName: potAuthor,
          season: potSeason,
          drawingNumber: number,
          version: version,
          isValid: false,
          targetSubFolder: 'sconosciuti',
        );
      }
    }

    return ParsedDrawingCode.unknown(cleaned);
  }
}
