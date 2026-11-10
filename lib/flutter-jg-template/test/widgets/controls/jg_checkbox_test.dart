import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jg_design_system/jg_design_system.dart';

Widget buildTestableWidget(Widget widget) {
  return MaterialApp(
    theme: JgTheme.lightTheme,
    home: Scaffold(
      body: Center(
        child: widget,
      ),
    ),
  );
}

void main() {
  group('JgCheckbox - Render & Layout', () {
    testWidgets('should render correctly with label and check its properties', (WidgetTester tester) async {
      // 1. Definiamo lo stato
      const bool value = false;

      // 2. Rendiamo il widget nel test
      await tester.pumpWidget(
        buildTestableWidget(
          const JgCheckbox(
            value: value,
            label: Text('Accetto i termini'),
          ),
        ),
      );

      // 3. Verifichiamo che l'etichetta testuale sia presente
      expect(find.text('Accetto i termini'), findsOneWidget);

      // 4. Troviamo il widget JgCheckbox specifico nel widget tree e verifichiamo la sua proprietà 'value'
      final checkboxWidget = tester.widget<JgCheckbox>(find.byType(JgCheckbox));
      expect(checkboxWidget.value, isFalse);
    });

    testWidgets('should change value when tapped', (WidgetTester tester) async {
      bool isChecked = false;

      await tester.pumpWidget(
        buildTestableWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return JgCheckbox(
                value: isChecked,
                label: const Text('Accetto i termini'),
                onChanged: (newValue) {
                  setState(() {
                    isChecked = newValue;
                  });
                },
              );
            },
          ),
        ),
      );

      // 1. Clicchiamo sul testo della label (l'intera riga ha un'area di tocco estesa)
      await tester.tap(find.text('Accetto i termini'));
      
      // 2. Attendiamo che finisca l'animazione di spunta
      await tester.pumpAndSettle();

      // 3. Verifichiamo se il valore è diventato true
      final checkboxWidget = tester.widget<JgCheckbox>(find.byType(JgCheckbox));
      expect(checkboxWidget.value, isTrue);
    });
  });
}
