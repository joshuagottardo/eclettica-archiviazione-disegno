# JG Design System (`jg_design_system`)

Un Design System minimalista, svizzero, ultramoderno, fluido e glassmorfico per applicazioni Flutter cross-platform (Mobile, Tablet, Desktop e Web).

Il kit è progettato con un'estetica ispirata alla precisione geometrica svizzera (caratteri compatti, maiuscoli, spaziature rigide) combinata con l'effetto vetro sfocato (*Glassmorphism*) tipico dei sistemi operativi Apple.

---

## 🚀 Caratteristiche Principali

1.  **Estetica Svizzera & Glassmorphic:** Sfumature neon delicate, sfocature dello sfondo calibrate, micro-bordi incisi (*hairline border*) e tipografia basata su [Inter].
2.  **Navigazione Adattiva Automatizzata:** Grazie a [JgResponsiveScaffold], l'app si adatta in base alla larghezza dello schermo (Mobile $\rightarrow$ Bottom HUD, Tablet $\rightarrow$ Rail laterale, Desktop $\rightarrow$ Sidebar completa).
3.  **Ottimizzazione delle Prestazioni:** Monitoraggio dinamico dei frame rate ([JgPerformance]) per disattivare automaticamente gli effetti grafici pesanti (`BackdropFilter`) sui dispositivi meno potenti, mantenendo 60/120 FPS.
4.  **Estensioni del Tema Native:** Tutti i token e gli effetti speciali (ombre, gradienti, raggi dei bordi) sono implementati come `ThemeExtension` di Flutter per supportare transizioni fluide (`lerp`) al cambio del tema (Light/Dark).
5.  **Accessibilità (A11y) Integrata:** Tutti i widget interattivi custom includono il wrapper `Semantics` per una compatibilità ottimale con lettori di schermo (TalkBack / VoiceOver).

---

## 📦 Come usarlo in nuovi progetti

Per utilizzare questo template/design system come dipendenza nelle tue future applicazioni Flutter, aggiungilo nel file `pubspec.yaml` del tuo nuovo progetto.

### Opzione A: Riferimento Locale (Path)
Se tieni il template nella stessa macchina di sviluppo:
```yaml
dependencies:
  flutter:
    sdk: flutter
  jg_design_system:
    path: ../flutter-jg-template  # Modifica con il percorso relativo corretto
```

### Opzione B: Riferimento Git Remoto
Se pubblichi il template su un repository Git privato o pubblico:
```yaml
dependencies:
  flutter:
    sdk: flutter
  jg_design_system:
    git:
      url: https://github.com/tuo-username/flutter-jg-template.git
      ref: main  # o il tag/branch specifico
```

---

## 🛠️ Configurazione Iniziale

Nel `main()` della tua applicazione, inizializza il monitoraggio delle prestazioni e configura i temi predefiniti in `MaterialApp`:

```dart
import 'package:flutter/material.dart';
import 'package:jg_design_system/jg_design_system.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza il rilevamento automatico dei cali di frame rate
  JgPerformance.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Mia App Adaptiva',
      theme: JgTheme.lightTheme, // Tema chiaro predefinito
      darkTheme: JgTheme.darkTheme, // Tema scuro OLED predefinito
      themeMode: ThemeMode.system,  // Rispetta il tema di sistema
      home: const HomeScreen(),
    );
  }
}
```

---

## 🎨 Esempi d'Uso dei Componenti Principali

### 1. Navigazione Responsive ([JgResponsiveScaffold])

Sostituisci il classico `Scaffold` con il nostro scaffold adattivo per supportare automaticamente tablet e desktop:

```dart
int _selectedIndex = 0;

final navigationItems = const [
  JgNavigationBarItem(icon: Icons.home_rounded, label: 'Home'),
  JgNavigationBarItem(icon: Icons.analytics_rounded, label: 'Statistiche'),
  JgNavigationBarItem(icon: Icons.settings_rounded, label: 'Impostazioni'),
];

@override
Widget build(BuildContext context) {
  return JgResponsiveScaffold(
    currentIndex: _selectedIndex,
    items: navigationItems,
    onTap: (index) => setState(() => _selectedIndex = index),
    sidebarHeader: const Text('LOGO'), // Mostrato solo su tablet/desktop
    sidebarFooter: const CircleAvatar(child: Icon(Icons.person)), // Mostrato solo su tablet/desktop
    body: _buildPage(_selectedIndex),
  );
}
```

### 2. Pulsante Fluido ([JgButton])

Supporta vari stili (`primary`, `glass`, `ghost`), ha uno stato di caricamento nativo e include una micro-animazione fisica alla pressione:

```dart
JgButton(
  style: JgButtonStyle.glass, // Stile vetro sfocato
  icon: const Icon(Icons.share),
  loading: false, // Impostare a true per disabilitare e mostrare un loader
  onPressed: () => print('Pulsante premuto!'),
  child: const Text('Condividi'),
)
```

### 3. Contenitore Vetro Sfocato ([JgGlassContainer])

La pietra miliare dell'estetica *Glassmorphic* dell'app:

```dart
JgGlassContainer(
  borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
  child: Column(
    children: [
      Text('Pannello in Vetro', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      const Text('Questo box ha una sfocatura dello sfondo in tempo reale.'),
    ],
  ),
)
```

---

## 📐 I Design Token (Sotto il cofano)

*   **Colori:** Accedi alla palette in modo tipizzato usando `context.jgColors`. Es. `context.jgColors.accent`, `context.jgColors.background`, `context.jgColors.textPrimary`.
*   **Dimensioni:** Definite in [JgSizes](lib/src/foundations/jg_sizes.dart) per griglie geometriche costanti (spaziature da 4, 8, 12, 16, 20, 24, 32, 40 px e raggi dei bordi fino a circolare).
*   **Tipografia:** Basata su Inter. Applica le regole svizzere usando lo stile `labelSmall` per testi compatti in maiuscolo molto spaziati.

---

## 🛠️ Contribuire e Sviluppare

Tutti i widget del Design System sono esportati da [jg_design_system.dart](lib/jg_design_system.dart). 

Quando crei nuovi widget:
1.  **Mantieni l'accessibilità:** Avvolgi sempre l'interazione in un widget `Semantics`.
2.  **Usa le estensioni del tema:** Evita di impostare colori o misure hardcoded; usa sempre `context.jgColors` o `context.jgSizes`.
3.  **Controlla le prestazioni:** Se un widget usa effetti pesanti come `ImageFilter`, assicurati che legga `JgPerformance.lowPerformanceNotifier` per fornire un fallback solido e leggero.
