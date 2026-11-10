import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:eclettica_archiviazione_disegni/models/drawing_item.dart';
import 'package:eclettica_archiviazione_disegni/services/code_parser_service.dart';
import 'package:eclettica_archiviazione_disegni/services/archive_service.dart';
import 'package:image/image.dart' as img;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('E2E Physical Archiving and Rotation Test', () async {
    final authorMap = {'MAR': 'MARIANNA'};
    final testDir = '${Directory.current.path}/lib/assets/test';
    final sampleFile = File('$testDir/scan_20261108_232904_0020.jpg');

    if (!sampleFile.existsSync()) return;

    final parsed = CodeParserService.parse('MARV 366/1', authorMap);
    final item = DrawingItem(
      id: sampleFile.path,
      originalPath: sampleFile.path,
      fileName: 'scan_20261108_232904_0020.jpg',
      fileSizeBytes: sampleFile.lengthSync(),
      rotationDegrees: 90,
      rawDetectedCode: 'MARV 366/1',
      parsedCode: parsed,
      status: RecognitionStatus.valid,
    );

    final unmappedParsed = CodeParserService.parse('mat 129', authorMap);
    final unmappedItem = DrawingItem(
      id: '$testDir/scan_20261108_232904_0001.jpg',
      originalPath: '$testDir/scan_20261108_232904_0001.jpg',
      fileName: 'scan_20261108_232904_0001.jpg',
      fileSizeBytes: 1000,
      rotationDegrees: 0,
      rawDetectedCode: 'mat 129',
      parsedCode: unmappedParsed,
      status: RecognitionStatus.unknown,
    );

    final tempDest = Directory.systemTemp.createTempSync('eclettica_prod_archive_');

    final result = await ArchiveService.archiveBatch(
      items: [item, unmappedItem],
      destinationRoot: tempDest.path,
      copyOnly: true,
      applyRotation: true,
    );

    expect(result.totalProcessed, 2);
    expect(result.successCount, 1);
    expect(result.unknownCount, 1);

    // Verify MARIANNA/V/MARV366_1.jpg exists and was physically rotated
    final archivedFile = File('${tempDest.path}/MARIANNA/V/MARV366_1.jpg');
    expect(archivedFile.existsSync(), true);

    final decoded = img.decodeImage(await archivedFile.readAsBytes());
    expect(decoded != null, true);
    expect(decoded!.width, 7015);
    expect(decoded.height, 4961);

    // Verify sconosciuti folder exists
    final sconosciutiFile = File('${tempDest.path}/sconosciuti/scan_20261108_232904_0001.jpg');
    expect(sconosciutiFile.existsSync(), true);

    // Verify CSV report was generated
    expect(result.csvReportPath != null, true);
    expect(File(result.csvReportPath!).existsSync(), true);

    // Clean up
    tempDest.deleteSync(recursive: true);
  });
}
