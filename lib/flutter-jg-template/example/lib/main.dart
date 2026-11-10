import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jg_design_system/jg_design_system.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  JgPerformance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, _) {
        return MaterialApp(
          title: 'JG Design System Showcase',
          theme: JgTheme.lightTheme,
          darkTheme: JgTheme.darkTheme,
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: const ShowcaseScreen(),
        );
      },
    );
  }
}

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  final TextEditingController _solidController = TextEditingController();
  final TextEditingController _glassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _buttonLoading = false;
  bool _switchVal = true;
  double _sliderVal = 0.5;
  int _radioVal = 1;
  int _navIndex = 0;
  int _segmentVal = 1;
  bool _checkVal = false;

  void _triggerButtonLoader() {
    setState(() => _buttonLoading = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _buttonLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _solidController.dispose();
    _glassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;

    final Widget mainContent = Stack(
      children: [
        // 1. Luci ambientali sfumate in background (per far risaltare il vetro sfocato)
        Positioned.fill(
          child: Container(
            color: colors.background,
          ),
        ),
        // 1.1 Luci ambientali sfumate in background (gestite in base alle prestazioni)
        ValueListenableBuilder<bool>(
          valueListenable: JgPerformance.lowPerformanceNotifier,
          builder: (context, lowPerf, _) {
            if (lowPerf) return const SizedBox.shrink();
            return Stack(
              children: [
                // Cerchio luminoso top-left (Viola/Indaco)
                Positioned(
                  left: -100,
                  top: -100,
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x2E8B5CF6),
                    ),
                  ),
                ),
                // Cerchio luminoso center-right (Ciano/Blu)
                Positioned(
                  right: -150,
                  top: 300,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x2606B6D4),
                    ),
                  ),
                ),
                // Cerchio luminoso bottom-left (Magenta)
                Positioned(
                  left: -50,
                  bottom: 50,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x1FEC4899),
                    ),
                  ),
                ),
                // Filtro sfocatura di background per amalgamare i cerchi di luce
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 70.0, sigmaY: 70.0),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            );
          },
        ),

        // 2. Contenuto scorrevole della Vetrina
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: JgSizes.space24,
              vertical: JgSizes.space32,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER (Stile Svizzero e Rigido) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'JG DESIGN SYSTEM',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.accent,
                          letterSpacing: 2.5,
                        ),
                      ),
                      Row(
                        children: [
                          // Pulsante Risparmio Energetico
                          ValueListenableBuilder<bool>(
                            valueListenable: JgPerformance.lowPerformanceNotifier,
                            builder: (context, lowPerf, _) {
                              return JgIconButton(
                                icon: Icon(lowPerf 
                                    ? CupertinoIcons.battery_25 
                                    : CupertinoIcons.battery_100),
                                onPressed: () {
                                  JgPerformance.setLowPerformanceMode(!lowPerf);
                                },
                              );
                            },
                          ),
                          const SizedBox(width: JgSizes.space8),
                          // Pulsante Switch Tema
                          ValueListenableBuilder<ThemeMode>(
                            valueListenable: themeNotifier,
                            builder: (context, mode, _) {
                              final isDark = mode == ThemeMode.dark;
                              return JgIconButton(
                                icon: Icon(isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill),
                                onPressed: () {
                                  themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: JgSizes.space8),
                  Text(
                    'Estetica Svizzera\ne Glassmorphism.',
                    style: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: JgSizes.space12),
                  Text(
                    'Codebase template ultramoderna con dark mode profonda e micro-interazioni fluide.',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: JgSizes.space40),

                  // --- SEZIONE 1: CONTAINERS & CARDS ---
                  _buildSectionHeader(context, '01 / CONTENITORI VETRO'),
                  JgGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JgGlassContainer (Apple Style)',
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: JgSizes.space8),
                        Text(
                          'Questo contenitore implementa una sfocatura dello sfondo calibrata, ombreggiature volumetriche multi-livello e un micro-bordo a gradiente (hairline border) che simula la rifrazione fisica della luce sul bordo del vetro.',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: JgSizes.space32),

                  // --- SEZIONE 2: PULSANTI ANIMATI ---
                  _buildSectionHeader(context, '02 / PULSANTI FLUIDI'),
                  Text(
                    'Alla pressione, tutti i bottoni si comprimono leggermente in modo immediato per fornire una sensazione fisica tattile.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: JgSizes.space20),
                  Column(
                    children: [
                      // Bottone Primario
                      JgButton(
                        onPressed: _triggerButtonLoader,
                        loading: _buttonLoading,
                        child: const Text('BOTTONE PRIMARIO'),
                      ),
                      const SizedBox(height: JgSizes.space16),

                      // Bottone Vetro con Icona
                      JgButton(
                        onPressed: () {},
                        style: JgButtonStyle.glass,
                        icon: const Icon(CupertinoIcons.square_arrow_up),
                        child: const Text('CONDIVIDI FILE'),
                      ),
                      const SizedBox(height: JgSizes.space16),

                      // Pulsante Ghost / Trasparente
                      Row(
                        children: [
                          Expanded(
                            child: JgButton(
                              onPressed: () {},
                              style: JgButtonStyle.ghost,
                              child: const Text('ANNULLA'),
                            ),
                          ),
                          const SizedBox(width: JgSizes.space16),
                          Expanded(
                            child: JgButton(
                              onPressed: null, // Disabilitato
                              child: const Text('DISABILITATO'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: JgSizes.space32),

                  // --- SEZIONE 3: CAMPI DI TESTO ---
                  _buildSectionHeader(context, '03 / CAMPI DI TESTO RIGIDI'),
                  JgTextField(
                    controller: _solidController,
                    labelText: 'Username (Stile Solido)',
                    hintText: 'Inserisci il tuo username',
                    prefixIcon: const Icon(CupertinoIcons.person),
                  ),
                  const SizedBox(height: JgSizes.space24),
                  JgTextField(
                    controller: _glassController,
                    labelText: 'Password (Stile Vetro)',
                    hintText: 'Inserisci la tua password',
                    obscureText: true,
                    isGlass: true,
                    prefixIcon: const Icon(CupertinoIcons.lock),
                    suffixIcon: const Icon(CupertinoIcons.eye),
                  ),
                  const SizedBox(height: JgSizes.space32),

                  // --- SEZIONE 4: ELEMENTI DI LISTA ---
                  _buildSectionHeader(context, '04 / COMPONENTI LISTA'),
                  JgGlassContainer(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        JgListTile(
                          leading: const Icon(CupertinoIcons.gear),
                          title: const Text('Impostazioni Generali'),
                          subtitle: const Text('Lingua, tema, preferenze'),
                          trailing: const Icon(CupertinoIcons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1.0, indent: JgSizes.space48),
                        JgListTile(
                          leading: const Icon(CupertinoIcons.shield),
                          title: const Text('Sicurezza e Privacy'),
                          subtitle: const Text('Autenticazione a due fattori, password'),
                          trailing: const Icon(CupertinoIcons.chevron_right),
                          onTap: () {},
                        ),
                        const Divider(height: 1.0, indent: JgSizes.space48),
                        JgListTile(
                          leading: const Icon(CupertinoIcons.bell),
                          title: const Text('Notifiche'),
                          subtitle: const Text('Push, email, preferenze alert'),
                          trailing: const Icon(CupertinoIcons.chevron_right),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: JgSizes.space32),

                  // --- SEZIONE 5: MODALI E CONTROLLI ---
                  _buildSectionHeader(context, '05 / MODALI E CONTROLLI'),
                  JgGlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Segmented Control
                        JgSegmentedControl<int>(
                          selectedValue: _segmentVal,
                          onValueChanged: (val) => setState(() => _segmentVal = val),
                          children: const {
                            1: 'Deep Dark',
                            2: 'Minimalist',
                            3: 'Apple Glass',
                          },
                        ),
                        const SizedBox(height: JgSizes.space20),
                        const Divider(),
                        const SizedBox(height: JgSizes.space20),
                        // Switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Notifiche Push',
                              style: textTheme.titleMedium,
                            ),
                            JgSwitch(
                              value: _switchVal,
                              onChanged: (val) => setState(() => _switchVal = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: JgSizes.space20),
                        const Divider(),
                        const SizedBox(height: JgSizes.space20),

                        // Slider
                        Text(
                          'Luminosità Display: ${(_sliderVal * 100).toInt()}%',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: JgSizes.space8),
                        JgSlider(
                          value: _sliderVal,
                          onChanged: (val) => setState(() => _sliderVal = val),
                        ),
                        const SizedBox(height: JgSizes.space20),
                        const Divider(),
                        const SizedBox(height: JgSizes.space20),

                        // Radio Buttons
                        Text(
                          'Tema Predefinito',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: JgSizes.space8),
                        JgRadioButton<int>(
                          value: 1,
                          groupValue: _radioVal,
                          onChanged: (val) => setState(() => _radioVal = val),
                          label: const Text('Deep Dark (OLED)'),
                        ),
                        JgRadioButton<int>(
                          value: 2,
                          groupValue: _radioVal,
                          onChanged: (val) => setState(() => _radioVal = val),
                          label: const Text('Monochrome Glass'),
                        ),
                        JgRadioButton<int>(
                          value: 3,
                          groupValue: _radioVal,
                          onChanged: (val) => setState(() => _radioVal = val),
                          label: const Text('Light Mode (Prossimamente)'),
                        ),
                        const SizedBox(height: JgSizes.space20),
                        const Divider(),
                        const SizedBox(height: JgSizes.space20),

                        // Checkbox & Icon Buttons (Fase 9)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: JgCheckbox(
                                value: _checkVal,
                                onChanged: (val) => setState(() => _checkVal = val),
                                label: const Text('Accetto i termini e condizioni'),
                              ),
                            ),
                            Row(
                              children: [
                                JgIconButton(
                                  icon: const Icon(CupertinoIcons.heart),
                                  onPressed: () {
                                    JgToast.show(
                                      context,
                                      message: 'Aggiunto ai preferiti',
                                      type: JgToastType.success,
                                    );
                                  },
                                ),
                                const SizedBox(width: JgSizes.space8),
                                JgIconButton(
                                  icon: const Icon(CupertinoIcons.share),
                                  isGlass: true,
                                  onPressed: () {
                                    JgToast.show(
                                      context,
                                      message: 'Link di condivisione generato',
                                      type: JgToastType.info,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: JgSizes.space24),
                  // Trigger Modale
                  JgButton(
                    style: JgButtonStyle.glass,
                    onPressed: () {
                      showJgDialog(
                        context: context,
                        title: const Text('Riavvio Richiesto'),
                        content: const Text(
                          'Per applicare le nuove impostazioni di sicurezza è necessario riavviare l\'applicazione.',
                        ),
                        actions: [
                          JgButton(
                            style: JgButtonStyle.ghost,
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('ANNULLA'),
                          ),
                          JgButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('RIAVVIA ORA'),
                          ),
                        ],
                      );
                    },
                    child: const Text('APRI MODALE VETRATO'),
                  ),
                  const SizedBox(height: JgSizes.space16),
                  // Trigger Toast
                  Row(
                    children: [
                      Expanded(
                        child: JgButton(
                          style: JgButtonStyle.ghost,
                          onPressed: () {
                            JgToast.show(
                              context,
                              message: 'Notifica informativa attiva',
                              type: JgToastType.info,
                            );
                          },
                          child: const Text('INFO TOAST'),
                        ),
                      ),
                      const SizedBox(width: JgSizes.space12),
                      Expanded(
                        child: JgButton(
                          style: JgButtonStyle.glass,
                          onPressed: () {
                            JgToast.show(
                              context,
                              message: 'Salvataggio completato',
                              type: JgToastType.success,
                            );
                          },
                          child: const Text('SUCCESS TOAST'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: JgSizes.space12),
                  JgButton(
                    style: JgButtonStyle.glass,
                    onPressed: () {
                      JgToast.show(
                        context,
                        message: 'Errore di connessione al database',
                        type: JgToastType.error,
                      );
                    },
                    child: const Text('MOSTRA ERROR TOAST'),
                  ),
                  const SizedBox(height: JgSizes.space32),

                  // --- SEZIONE 6: CARICAMENTI E SCHELETRATI ---
                  _buildSectionHeader(context, '06 / CARICAMENTI E SCHELETRATI'),
                  Text(
                    'Shimmer shader-masked per scheletri di caricamento ed indicatore Radar Orbitale Custom disegnato su Canvas.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: JgSizes.space20),
                  // Esempio JgShimmer
                  JgGlassContainer(
                    child: JgShimmer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: JgSizes.space16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 14.0,
                                      width: 120.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(JgSizes.radiusSmall),
                                      ),
                                    ),
                                    const SizedBox(height: JgSizes.space8),
                                    Container(
                                      height: 10.0,
                                      width: 70.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(JgSizes.radiusSmall),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: JgSizes.space20),
                          Container(
                            height: 12.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(JgSizes.radiusSmall),
                            ),
                          ),
                          const SizedBox(height: JgSizes.space8),
                          Container(
                            height: 12.0,
                            width: double.infinity * 0.8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(JgSizes.radiusSmall),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: JgSizes.space24),
                  // Indicatori JgLoader in varie scale
                  JgGlassContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const JgLoader(size: 24.0, strokeWidth: 1.0, showGlow: false),
                            const SizedBox(height: JgSizes.space8),
                            Text('Small (24px)', style: textTheme.bodySmall),
                          ],
                        ),
                        Column(
                          children: [
                            const JgLoader(size: 48.0, strokeWidth: 2.0),
                            const SizedBox(height: JgSizes.space8),
                            Text('Medium (48px)', style: textTheme.bodySmall),
                          ],
                        ),
                        Column(
                          children: [
                            const JgLoader(size: 72.0, strokeWidth: 3.0),
                            const SizedBox(height: JgSizes.space8),
                            Text('Large (72px)', style: textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: JgSizes.space32),

                  // --- SEZIONE 07: STRUTTURA & STATI PREMIUM ---
                  _buildSectionHeader(context, '07 / STRUTTURA & STATI PREMIUM'),
                  Text(
                    'Integrazione di moduli avanzati per fogli modali vetrati, badge tipografici svizzeri, barre di progresso neon e accordion collassabili.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: JgSizes.space20),

                  // Esempi Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      JgBadge(
                        label: 'Online',
                        style: JgBadgeStyle.solid,
                        customColor: colors.success,
                      ),
                      const SizedBox(width: JgSizes.space8),
                      const JgBadge(
                        label: 'Beta',
                        style: JgBadgeStyle.glass,
                        icon: CupertinoIcons.sparkles,
                      ),
                      const SizedBox(width: JgSizes.space8),
                      JgBadge(
                        label: 'Deprecated',
                        style: JgBadgeStyle.outline,
                        customColor: colors.error.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: JgSizes.space24),

                  // ... etc. (Rest of sections)
                  Text(
                    'Progresso Determinato (collegato allo slider sopra: ${(_sliderVal * 100).toInt()}%):',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: JgSizes.space8),
                  JgLinearProgress(value: _sliderVal),
                  const SizedBox(height: JgSizes.space16),
                  Text(
                    'Progresso Indeterminato (con alone neon):',
                    style: textTheme.titleSmall,
                  ),
                  const SizedBox(height: JgSizes.space8),
                  const JgLinearProgress(),
                  const SizedBox(height: JgSizes.space24),

                  // Trigger Bottom Sheet
                  JgButton(
                    style: JgButtonStyle.glass,
                    onPressed: () {
                      showJgBottomSheet(
                        context: context,
                        child: Padding(
                          padding: const EdgeInsets.all(JgSizes.space24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MODALE BOTTOM SHEET',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: JgSizes.space12),
                              Text(
                                'Questo pannello inferiore ad effetto vetro (Apple Glassmorphism) fluttua sopra lo sfondo dell\'app. Supporta lo scorrimento, il trascinamento per chiuderlo ed integra automaticamente la spaziatura per la safe area inferiore del sistema.',
                                style: textTheme.bodyMedium,
                              ),
                              const SizedBox(height: JgSizes.space24),
                                JgButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('CHIUDI PANNELLO'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: const Text('APRI FOGLIO MODALE (BOTTOM SHEET)'),
                    ),
                    const SizedBox(height: JgSizes.space24),

                    // Accordions
                    JgAccordion(
                      leading: const Icon(CupertinoIcons.circle_grid_hex),
                      title: const Text('Accordion Espandibile (Vetro)'),
                      subtitle: const Text('Premere per visualizzare le opzioni avanzate'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'L\'altezza del contenuto di questo blocco è animata in modo fluido usando una SizeTransition. Il chevron a destra esegue una rotazione elastica sincronizzata.',
                            style: textTheme.bodyMedium,
                          ),
                          const SizedBox(height: JgSizes.space16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Abilita Analisi Avanzata'),
                              JgSwitch(
                                value: _checkVal,
                                onChanged: (val) => setState(() => _checkVal = val),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: JgSizes.space16),
                    JgAccordion(
                      leading: const Icon(CupertinoIcons.info),
                      title: const Text('Dettagli Tecnici del Kit'),
                      child: Text(
                        'Il design system implementa i token di colore OLED, raggi dei bordi glassmorphic Apple, ombreggiature volumetriche tridimensionali e tipografia svizzera Inter.',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: JgSizes.space24),

                    // --- SEZIONE 8: DIMENSIONI E SCALABILITÀ ---
                    _buildSectionHeader(context, '08 / SCALABILITÀ E DIMENSIONI'),
                    Text(
                      'I controlli del design system supportano tre livelli di dimensionamento (Small, Medium, Large) sia localmente sia ereditati dal tema.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: JgSizes.space20),
                    JgGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PULSANTI (Small / Medium / Large)', style: textTheme.titleSmall),
                          const SizedBox(height: JgSizes.space12),
                          Row(
                            children: [
                              JgButton(
                                controlSize: JgControlSize.small,
                                onPressed: () {},
                                child: const Text('SMALL'),
                              ),
                              const SizedBox(width: JgSizes.space8),
                              JgButton(
                                controlSize: JgControlSize.medium,
                                onPressed: () {},
                                child: const Text('MEDIUM'),
                              ),
                              const SizedBox(width: JgSizes.space8),
                              JgButton(
                                controlSize: JgControlSize.large,
                                onPressed: () {},
                                child: const Text('LARGE'),
                              ),
                            ],
                          ),
                          const SizedBox(height: JgSizes.space24),
                          
                          Text('CAMPI DI TESTO', style: textTheme.titleSmall),
                          const SizedBox(height: JgSizes.space12),
                          JgTextField(
                            controlSize: JgControlSize.small,
                            hintText: 'Small input...',
                          ),
                          const SizedBox(height: JgSizes.space12),
                          JgTextField(
                            controlSize: JgControlSize.medium,
                            hintText: 'Medium input...',
                          ),
                          const SizedBox(height: JgSizes.space12),
                          JgTextField(
                            controlSize: JgControlSize.large,
                            hintText: 'Large input...',
                          ),
                          const SizedBox(height: JgSizes.space24),

                          Text('CHECKBOX (Small / Medium / Large)', style: textTheme.titleSmall),
                          const SizedBox(height: JgSizes.space12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              JgCheckbox(
                                controlSize: JgControlSize.small,
                                value: _checkVal,
                                onChanged: (val) => setState(() => _checkVal = val),
                                label: const Text('Small'),
                              ),
                              const SizedBox(height: JgSizes.space4),
                              JgCheckbox(
                                controlSize: JgControlSize.medium,
                                value: _checkVal,
                                onChanged: (val) => setState(() => _checkVal = val),
                                label: const Text('Medium'),
                              ),
                              const SizedBox(height: JgSizes.space4),
                              JgCheckbox(
                                controlSize: JgControlSize.large,
                                value: _checkVal,
                                onChanged: (val) => setState(() => _checkVal = val),
                                label: const Text('Large'),
                              ),
                            ],
                          ),
                          const SizedBox(height: JgSizes.space24),

                          Text('SWITCH (Small / Medium / Large)', style: textTheme.titleSmall),
                          const SizedBox(height: JgSizes.space12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  JgSwitch(
                                    controlSize: JgControlSize.small,
                                    value: _checkVal,
                                    onChanged: (val) => setState(() => _checkVal = val),
                                  ),
                                  const SizedBox(width: JgSizes.space8),
                                  Text('Small', style: textTheme.bodySmall),
                                ],
                              ),
                              const SizedBox(height: JgSizes.space8),
                              Row(
                                children: [
                                  JgSwitch(
                                    controlSize: JgControlSize.medium,
                                    value: _checkVal,
                                    onChanged: (val) => setState(() => _checkVal = val),
                                  ),
                                  const SizedBox(width: JgSizes.space8),
                                  Text('Medium', style: textTheme.bodySmall),
                                ],
                              ),
                              const SizedBox(height: JgSizes.space8),
                              Row(
                                children: [
                                  JgSwitch(
                                    controlSize: JgControlSize.large,
                                    value: _checkVal,
                                    onChanged: (val) => setState(() => _checkVal = val),
                                  ),
                                  const SizedBox(width: JgSizes.space8),
                                  Text('Large', style: textTheme.bodySmall),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100.0), // Spazio per evitare la sovrapposizione con la barra HUD
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    final navigationItems = const [
      JgNavigationBarItem(icon: CupertinoIcons.square_grid_2x2, label: 'Showcase'),
      JgNavigationBarItem(icon: CupertinoIcons.chart_pie, label: 'Stats'),
      JgNavigationBarItem(icon: CupertinoIcons.settings, label: 'Settings'),
    ];

    return JgResponsiveScaffold(
      currentIndex: _navIndex,
      items: navigationItems,
      onTap: (index) {
        setState(() => _navIndex = index);
        JgToast.show(
          context,
          message: 'Tab selezionato: ${['Showcase', 'Stats', 'Settings'][index]}',
          type: JgToastType.info,
        );
      },
      sidebarHeader: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.sparkles, size: 24.0),
            const SizedBox(width: 8.0),
            Text(
              'JG KIT',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
      sidebarFooter: CircleAvatar(
        radius: 18.0,
        backgroundColor: colors.accent,
        child: Icon(
          CupertinoIcons.person_fill,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 18.0,
        ),
      ),
      body: mainContent,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: JgSizes.space16, top: JgSizes.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelSmall?.copyWith(
              color: context.jgColors.textSecondary,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: JgSizes.space8),
          const Divider(),
        ],
      ),
    );
  }
}
