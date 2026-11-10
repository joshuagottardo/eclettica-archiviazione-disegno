import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eclettica_archiviazione_disegni/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const EcletticaArchivioApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('ECLETTICA'), findsWidgets);
  });
}


