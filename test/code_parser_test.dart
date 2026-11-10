import 'package:flutter_test/flutter_test.dart';
import 'package:eclettica_archiviazione_disegni/services/code_parser_service.dart';

void main() {
  final testMap = {'MAR': 'MARIANNA'};

  group('CodeParserService Tests', () {
    test('Parses "marq 63" with space when author is mapped', () {
      final res = CodeParserService.parse('marq 63', testMap);
      expect(res.isValid, true);
      expect(res.authorCode, 'MAR');
      expect(res.authorName, 'MARIANNA');
      expect(res.season, 'Q');
      expect(res.drawingNumber, '63');
      expect(res.targetSubFolder, 'MARIANNA/Q');
      expect(res.finalCleanCode, 'MARQ63');
    });

    test('Parses handwritten "MARV 366/1" with slash variation', () {
      final res = CodeParserService.parse('MARV 366/1', testMap);
      expect(res.isValid, true);
      expect(res.authorCode, 'MAR');
      expect(res.authorName, 'MARIANNA');
      expect(res.season, 'V');
      expect(res.drawingNumber, '366');
      expect(res.version, '1');
      expect(res.targetSubFolder, 'MARIANNA/V');
      expect(res.finalCleanCode, 'MARV366_1');
    });

    test('Parses "marv 326"', () {
      final res = CodeParserService.parse('marv 326', testMap);
      expect(res.isValid, true);
      expect(res.authorCode, 'MAR');
      expect(res.season, 'V');
      expect(res.drawingNumber, '326');
      expect(res.targetSubFolder, 'MARIANNA/V');
    });

    test('Parses unmapped author "mat 129" to sconosciuti', () {
      final res = CodeParserService.parse('mat 129', testMap);
      expect(res.isValid, false);
      expect(res.targetSubFolder, 'sconosciuti');
    });

    test('Parses missing code to sconosciuti', () {
      final res = CodeParserService.parse('NOT_FOUND', testMap);
      expect(res.isValid, false);
      expect(res.targetSubFolder, 'sconosciuti');
    });
  });
}
