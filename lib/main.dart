import 'package:flutter/material.dart';
import 'package:jg_design_system/jg_design_system.dart';
import 'package:eclettica_archiviazione_disegni/ui/screens/home_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  JgPerformance.init();
  runApp(const EcletticaArchivioApp());
}

class EcletticaArchivioApp extends StatelessWidget {
  const EcletticaArchivioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          title: 'Eclettica • Archiviazione Disegni',
          debugShowCheckedModeBanner: false,
          theme: JgTheme.lightTheme,
          darkTheme: JgTheme.darkTheme,
          themeMode: currentMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
