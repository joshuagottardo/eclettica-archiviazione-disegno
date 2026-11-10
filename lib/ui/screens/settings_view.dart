import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jg_design_system/jg_design_system.dart';
import 'package:eclettica_archiviazione_disegni/state/drawing_batch_controller.dart';

class SettingsView extends StatefulWidget {
  final DrawingBatchController controller;

  const SettingsView({super.key, required this.controller});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController _apiKeyController;
  late TextEditingController _destFolderController;
  late TextEditingController _newAuthorCodeController;
  late TextEditingController _newAuthorNameController;
  late Map<String, String> _authors;
  late bool _debugMode;
  bool _obscureApiKey = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: widget.controller.apiKey);
    _destFolderController = TextEditingController(text: widget.controller.destinationFolder);
    _newAuthorCodeController = TextEditingController();
    _newAuthorNameController = TextEditingController();
    _authors = Map<String, String>.from(widget.controller.authorMap);
    _debugMode = widget.controller.debugMode;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _destFolderController.dispose();
    _newAuthorCodeController.dispose();
    _newAuthorNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDestinationFolder() async {
    final selected = await FilePicker.getDirectoryPath(
      dialogTitle: 'Seleziona Cartella di Destinazione',
    );
    if (selected != null) {
      setState(() {
        _destFolderController.text = selected;
      });
      widget.controller.updateSettings(destinationFolder: selected);
    }
  }

  void _addAuthor() {
    final code = _newAuthorCodeController.text.trim().toUpperCase();
    final name = _newAuthorNameController.text.trim().toUpperCase();
    if (code.isNotEmpty && name.isNotEmpty) {
      setState(() {
        _authors[code] = name;
        _newAuthorCodeController.clear();
        _newAuthorNameController.clear();
      });
      widget.controller.updateSettings(authorMap: _authors);
      JgToast.show(
        context,
        message: '$code → $name aggiunto',
        type: JgToastType.success,
        icon: Icons.person_add_rounded,
      );
    }
  }

  void _removeAuthor(String code) {
    setState(() {
      _authors.remove(code);
    });
    widget.controller.updateSettings(authorMap: _authors);
  }

  Future<void> _onToggleDebugMode(bool targetValue) async {
    if (!targetValue) {
      setState(() => _debugMode = false);
      await widget.controller.updateSettings(debugMode: false);
      if (mounted) {
        JgToast.show(
          context,
          message: 'Modalità sviluppatore disattivata',
          type: JgToastType.info,
          icon: Icons.visibility_off_rounded,
        );
      }
      return;
    }

    final pinController = TextEditingController();
    String? errorText;

    final unlocked = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = ctx.jgColors;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            void checkPin() {
              if (pinController.text.trim() == '3369') {
                Navigator.of(ctx).pop(true);
              } else {
                setDialogState(() {
                  errorText = 'PIN errato. Riprova.';
                });
              }
            }

            return JgDialog(
              maxWidth: 380,
              title: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: colors.accent, size: 20),
                  const SizedBox(width: JgSizes.space8),
                  const Expanded(child: Text('Accesso Sviluppatore')),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inserisci il PIN a 4 cifre per sbloccare la modalità sviluppatore.',
                    style: TextStyle(fontSize: 13, color: colors.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: JgSizes.space16),
                  JgTextField(
                    controller: pinController,
                    labelText: 'CODICE DI SICUREZZA',
                    hintText: 'PIN di 4 cifre',
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    isGlass: true,
                    prefixIcon: Icon(Icons.pin_rounded, size: 18, color: colors.accent),
                    onChanged: (_) {
                      if (errorText != null) {
                        setDialogState(() => errorText = null);
                      }
                    },
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: JgSizes.space8),
                    Text(
                      errorText!,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.error),
                    ),
                  ],
                ],
              ),
              actions: [
                JgButton(
                  style: JgButtonStyle.ghost,
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Annulla'),
                ),
                JgButton(
                  style: JgButtonStyle.primary,
                  icon: const Icon(Icons.lock_open_rounded, size: 16),
                  onPressed: checkPin,
                  child: const Text('Sblocca'),
                ),
              ],
            );
          },
        );
      },
    );

    pinController.dispose();

    if (unlocked == true) {
      setState(() => _debugMode = true);
      await widget.controller.updateSettings(debugMode: true);
      if (mounted) {
        JgToast.show(
          context,
          message: 'Modalità sviluppatore attivata!',
          type: JgToastType.success,
          icon: Icons.code_rounded,
        );
      }
    }
  }

  void _save() {
    widget.controller.updateSettings(
      apiKey: _apiKeyController.text.trim(),
      destinationFolder: _destFolderController.text.trim(),
      authorMap: _authors,
      debugMode: _debugMode,
    );
    JgToast.show(
      context,
      message: 'Impostazioni salvate con successo!',
      type: JgToastType.success,
      icon: Icons.check_circle_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: JgSizes.space32, vertical: JgSizes.space24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Intestazione pulita e classica
              Text(
                'Impostazioni',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: JgSizes.space24),

              // 1. Chiave API
              Text(
                'Chiave API Gemini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: JgSizes.space4),
              Text(
                'Inserisci la chiave per il servizio di riconoscimento e orientamento disegni.',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
              const SizedBox(height: JgSizes.space12),
              JgTextField(
                controller: _apiKeyController,
                hintText: 'Incolla la tua chiave API...',
                obscureText: _obscureApiKey,
                isGlass: true,
                prefixIcon: Icon(Icons.key_rounded, size: 18, color: colors.accent),
                suffixIcon: JgIconButton(
                  icon: Icon(
                    _obscureApiKey ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    size: 18,
                  ),
                  isGlass: true,
                  size: 32,
                  onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
                ),
              ),
              const SizedBox(height: JgSizes.space24),
              Divider(height: 1, thickness: 0.5, color: colors.borderLight),
              const SizedBox(height: JgSizes.space24),

              // 2. Destinazione Archivio
              Text(
                'Cartella di Destinazione',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: JgSizes.space4),
              Text(
                'La cartella principale in cui verranno salvati e catalogati i file raddrizzati.',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
              const SizedBox(height: JgSizes.space12),
              Row(
                children: [
                  Expanded(
                    child: JgTextField(
                      controller: _destFolderController,
                      hintText: 'Nessuna cartella selezionata',
                      isGlass: true,
                      prefixIcon: Icon(Icons.folder_open_rounded, size: 18, color: colors.accent),
                    ),
                  ),
                  const SizedBox(width: JgSizes.space12),
                  JgButton(
                    style: JgButtonStyle.glass,
                    icon: const Icon(Icons.folder_open_rounded, size: 18),
                    onPressed: _pickDestinationFolder,
                    child: const Text('Sfoglia'),
                  ),
                ],
              ),
              const SizedBox(height: JgSizes.space24),
              Divider(height: 1, thickness: 0.5, color: colors.borderLight),
              const SizedBox(height: JgSizes.space24),

              // 3. Autori
              Text(
                'Autori',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: JgSizes.space4),
              Text(
                'Assegna una sigla al nome della cartella autore. I disegni non riconosciuti andranno in "sconosciuti/".',
                style: TextStyle(fontSize: 12, color: colors.textMuted),
              ),
              const SizedBox(height: JgSizes.space16),
              Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: JgTextField(
                      controller: _newAuthorCodeController,
                      hintText: 'Sigla (es. MAR)',
                      isGlass: true,
                      controlSize: JgControlSize.small,
                    ),
                  ),
                  const SizedBox(width: JgSizes.space8),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: colors.textMuted),
                  const SizedBox(width: JgSizes.space8),
                  Expanded(
                    child: JgTextField(
                      controller: _newAuthorNameController,
                      hintText: 'Nome Cartella (es. MARIANNA)',
                      isGlass: true,
                      controlSize: JgControlSize.small,
                    ),
                  ),
                  const SizedBox(width: JgSizes.space12),
                  JgButton(
                    style: JgButtonStyle.primary,
                    controlSize: JgControlSize.small,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    onPressed: _addAuthor,
                    child: const Text('Aggiungi'),
                  ),
                ],
              ),
              if (_authors.isNotEmpty) ...[
                const SizedBox(height: JgSizes.space16),
                Wrap(
                  spacing: JgSizes.space8,
                  runSpacing: JgSizes.space8,
                  children: _authors.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.only(left: 12, right: 6, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: colors.surfaceCard.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
                        border: Border.all(color: colors.border, width: 1.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '→ ${entry.value}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          JgIconButton(
                            icon: Icon(Icons.close_rounded, size: 14, color: colors.error),
                            size: 24,
                            iconSize: 14,
                            onPressed: () => _removeAuthor(entry.key),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: JgSizes.space24),
              Divider(height: 1, thickness: 0.5, color: colors.borderLight),
              const SizedBox(height: JgSizes.space24),

              // 4. Modalità Sviluppatore
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modalità sviluppatore',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Abilita anteprime tecniche, rotazione manuale e modifica codici (PIN 4 cifre).',
                          style: TextStyle(fontSize: 12, color: colors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: JgSizes.space16),
                  JgSwitch(
                    value: _debugMode,
                    onChanged: _onToggleDebugMode,
                  ),
                ],
              ),
              const SizedBox(height: JgSizes.space32),

              // Tasto Salva
              Align(
                alignment: Alignment.centerRight,
                child: JgButton(
                  style: JgButtonStyle.primary,
                  controlSize: JgControlSize.large,
                  icon: const Icon(Icons.check_rounded),
                  onPressed: _save,
                  child: const Text('Salva Impostazioni'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
