import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jg_design_system/jg_design_system.dart';
import 'package:eclettica_archiviazione_disegni/state/drawing_batch_controller.dart';
import 'package:eclettica_archiviazione_disegni/models/drawing_item.dart';
import 'package:eclettica_archiviazione_disegni/ui/widgets/drawing_card.dart';
import 'package:eclettica_archiviazione_disegni/ui/screens/settings_view.dart';
import 'package:eclettica_archiviazione_disegni/main.dart';

/// Schermata principale dell'applicazione.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DrawingBatchController _controller = DrawingBatchController();
  int _currentNavIndex = 0;
  String _activeFilter = 'all';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    try {
      final selectedDirectory = await FilePicker.getDirectoryPath(
        dialogTitle: 'Seleziona cartella con i disegni da archiviare',
      );
      if (selectedDirectory != null) {
        await _controller.loadDirectory(selectedDirectory);
        if (mounted) {
          if (_controller.totalCount == 0) {
            JgToast.show(
              context,
              message: 'Nessun file immagine supportato trovato nella cartella',
              type: JgToastType.info,
              icon: Icons.info_outline_rounded,
            );
          } else {
            JgToast.show(
              context,
              message: '${_controller.totalCount} disegni caricati',
              type: JgToastType.success,
              icon: Icons.folder_open_rounded,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        JgToast.show(
          context,
          message: 'Errore durante la lettura della cartella: $e',
          type: JgToastType.error,
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  Future<void> _startProcessing() async {
    if (_controller.items.isEmpty) {
      JgToast.show(
        context,
        message: 'Carica prima una cartella con disegni',
        type: JgToastType.error,
        icon: Icons.folder_open_rounded,
      );
      return;
    }

    if (_controller.apiKey.trim().isEmpty) {
      JgToast.show(
        context,
        message: 'Inserisci prima la tua API Key nelle Impostazioni',
        type: JgToastType.info,
        icon: Icons.key_rounded,
      );
      setState(() => _currentNavIndex = 1);
      return;
    }

    await _controller.processBatch();
  }

  Future<void> _executeArchiving() async {
    if (_controller.items.isEmpty) return;

    if (_controller.destinationFolder.trim().isEmpty) {
      final selected = await FilePicker.getDirectoryPath(
        dialogTitle: 'Seleziona cartella di destinazione per salvare i file',
      );
      if (selected == null) return;
      await _controller.updateSettings(destinationFolder: selected);
    }

    if (!mounted) return;

    final colors = context.jgColors;

    showDialog(
      context: context,
      builder: (ctx) => JgDialog(
        maxWidth: 460,
        title: Row(
          children: [
            Icon(Icons.save_alt_rounded, color: colors.accent, size: 22),
            const SizedBox(width: JgSizes.space8),
            const Text('Conferma Salvataggio'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I file verranno raddrizzati e salvati in:',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: JgSizes.space8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: JgSizes.space12, vertical: JgSizes.space8),
              decoration: BoxDecoration(
                color: colors.surfaceCard,
                borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
                border: Border.all(color: colors.border, width: 1.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_rounded, size: 16, color: colors.accent),
                  const SizedBox(width: JgSizes.space8),
                  Expanded(
                    child: Text(
                      _controller.destinationFolder,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: JgSizes.space16),
            _buildCheckPoint(colors, 'Raddrizzamento fisico con l\'orientamento rilevato'),
            _buildCheckPoint(colors, 'Organizzazione automatica in cartelle per Autore e Stagione'),
            _buildCheckPoint(colors, 'File senza sigla o con autore sconosciuto in "sconosciuti/"'),
            _buildCheckPoint(colors, 'Salvataggio report dettagliato in formato CSV'),
          ],
        ),
        actions: [
          JgButton(
            style: JgButtonStyle.ghost,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annulla'),
          ),
          JgButton(
            style: JgButtonStyle.primary,
            icon: const Icon(Icons.check_rounded, size: 16),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final result = await _controller.archiveAll(copyOnly: true);
                if (mounted) {
                  if (result.failureCount > 0) {
                    final errSummary = result.errors.take(2).join('\n');
                    JgToast.show(
                      context,
                      message: 'Completato con ${result.failureCount} errori:\n$errSummary',
                      type: JgToastType.error,
                      icon: Icons.error_outline_rounded,
                    );
                  } else {
                    JgToast.show(
                      context,
                      message: '${result.totalProcessed} disegni salvati con successo!',
                      type: JgToastType.success,
                      icon: Icons.check_circle_rounded,
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  JgToast.show(
                    context,
                    message: 'Errore: $e',
                    type: JgToastType.error,
                  );
                }
              }
            },
            child: const Text('Salva Ora'),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckPoint(dynamic colors, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: JgSizes.space8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: colors.success),
          const SizedBox(width: JgSizes.space8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  List<DrawingItem> _getFilteredItems() {
    switch (_activeFilter) {
      case 'valid':
        return _controller.items.where((i) => i.status == RecognitionStatus.valid).toList();
      case 'warning':
        return _controller.items.where((i) => i.status == RecognitionStatus.warning).toList();
      case 'unknown':
        return _controller.items.where((i) => i.status == RecognitionStatus.unknown).toList();
      case 'error':
        return _controller.items.where((i) => i.status == RecognitionStatus.error).toList();
      default:
        return _controller.items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.jgColors;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return JgResponsiveScaffold(
          currentIndex: _currentNavIndex,
          onTap: (index) => setState(() => _currentNavIndex = index),
          items: const [
            JgNavigationBarItem(
              icon: Icons.auto_awesome_mosaic_rounded,
              label: 'Archiviazione',
            ),
            JgNavigationBarItem(
              icon: Icons.tune_rounded,
              label: 'Impostazioni',
            ),
          ],
          sidebarHeader: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 120;
              final iconWidget = Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    'EC',
                    style: TextStyle(
                      color: colors.background,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );

              if (isCompact) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: JgSizes.space16),
                  child: Center(child: iconWidget),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: JgSizes.space16, vertical: JgSizes.space20),
                child: Row(
                  children: [
                    iconWidget,
                    const SizedBox(width: JgSizes.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ECLETTICA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            'Archivio Disegni',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          sidebarFooter: LayoutBuilder(
            builder: (context, constraints) {
              return ValueListenableBuilder<ThemeMode>(
                valueListenable: themeNotifier,
                builder: (context, currentMode, _) {
                  final isDark = currentMode == ThemeMode.dark;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(JgSizes.space16, JgSizes.space12, JgSizes.space16, JgSizes.space16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: JgIconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          size: 18,
                          color: colors.textSecondary,
                        ),
                        size: 36,
                        isGlass: true,
                        onPressed: () {
                          themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          body: _currentNavIndex == 1
              ? SettingsView(controller: _controller)
              : _buildMainView(context),
        );
      },
    );
  }

  Widget _buildMainView(BuildContext context) {
    if (_controller.items.isEmpty) {
      return _buildEmptyState(context);
    }

    if (_controller.debugMode) {
      return _buildDebugGridView(context);
    }

    return _buildUserSimpleView(context);
  }

  Widget _buildUserSimpleView(BuildContext context) {
    final colors = context.jgColors;
    final filtered = _getFilteredItems();
    final isWorking = _controller.isProcessing || _controller.isArchiving;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: JgSizes.space24, vertical: JgSizes.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Archiviazione',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: JgSizes.space8,
                runSpacing: JgSizes.space8,
                alignment: WrapAlignment.end,
                children: [
                  JgButton(
                    style: JgButtonStyle.glass,
                    controlSize: JgControlSize.medium,
                    icon: const Icon(Icons.folder_open_rounded, size: 18),
                    onPressed: isWorking ? null : _pickFolder,
                    child: const Text('Seleziona cartella'),
                  ),
                  JgButton(
                    style: JgButtonStyle.primary,
                    controlSize: JgControlSize.medium,
                    loading: _controller.isProcessing,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    onPressed: isWorking ? null : _startProcessing,
                    child: const Text('Organizza'),
                  ),
                  JgButton(
                    style: JgButtonStyle.glass,
                    controlSize: JgControlSize.medium,
                    loading: _controller.isArchiving,
                    icon: const Icon(Icons.save_alt_rounded, size: 18),
                    onPressed: (isWorking || _controller.processedCount == 0)
                        ? null
                        : _executeArchiving,
                    child: const Text('Salva'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: JgSizes.space16),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: isWorking
                ? Padding(
                    padding: const EdgeInsets.only(bottom: JgSizes.space16),
                    child: JgGlassContainer(
                      padding: const EdgeInsets.symmetric(horizontal: JgSizes.space16, vertical: JgSizes.space12),
                      borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                                ),
                              ),
                              const SizedBox(width: JgSizes.space12),
                              Expanded(
                                child: Text(
                                  _controller.currentOperationText,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                '${_controller.currentIndex} / ${_controller.totalCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colors.accent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: JgSizes.space8),
                          JgLinearProgress(
                            value: _controller.totalCount > 0
                                ? (_controller.currentIndex / _controller.totalCount).clamp(0.0, 1.0)
                                : null,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatPill(
                  label: 'Tutti',
                  count: _controller.totalCount,
                  filterKey: 'all',
                  icon: Icons.list_alt_rounded,
                  color: colors.textPrimary,
                ),
                const SizedBox(width: JgSizes.space8),
                _buildStatPill(
                  label: 'Riconosciuti',
                  count: _controller.validCount,
                  filterKey: 'valid',
                  icon: Icons.check_circle_rounded,
                  color: colors.success,
                ),
                const SizedBox(width: JgSizes.space8),
                _buildStatPill(
                  label: 'Da Verificare',
                  count: _controller.warningCount,
                  filterKey: 'warning',
                  icon: Icons.warning_amber_rounded,
                  color: colors.warning,
                ),
                const SizedBox(width: JgSizes.space8),
                _buildStatPill(
                  label: 'Sconosciuti',
                  count: _controller.unknownCount,
                  filterKey: 'unknown',
                  icon: Icons.folder_special_rounded,
                  color: colors.textMuted,
                ),
                if (_controller.errorCount > 0) ...[
                  const SizedBox(width: JgSizes.space8),
                  _buildStatPill(
                    label: 'Errori',
                    count: _controller.errorCount,
                    filterKey: 'error',
                    icon: Icons.error_outline_rounded,
                    color: colors.error,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: JgSizes.space16),

          Expanded(
            child: JgGlassContainer(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: colors.borderLight.withValues(alpha: 0.5),
                  ),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildFileRow(context, item);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required String label,
    required int count,
    required String filterKey,
    required IconData icon,
    required Color color,
  }) {
    final colors = context.jgColors;
    final isSelected = _activeFilter == filterKey;

    return InkWell(
      onTap: () => setState(() => _activeFilter = filterKey),
      borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: JgSizes.space16, vertical: JgSizes.space8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.14) : colors.surfaceCard.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.6) : colors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: JgSizes.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? colors.textPrimary : colors.textSecondary,
              ),
            ),
            const SizedBox(width: JgSizes.space8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileRow(BuildContext context, DrawingItem item) {
    final colors = context.jgColors;

    Widget statusIcon;
    String statusText;
    Color statusColor;

    switch (item.status) {
      case RecognitionStatus.valid:
        statusIcon = Icon(Icons.check_circle_rounded, color: colors.success, size: 18);
        statusText = 'Valido';
        statusColor = colors.success;
        break;
      case RecognitionStatus.warning:
        statusIcon = Icon(Icons.warning_amber_rounded, color: colors.warning, size: 18);
        statusText = 'Dubbio';
        statusColor = colors.warning;
        break;
      case RecognitionStatus.unknown:
        statusIcon = Icon(Icons.folder_special_rounded, color: colors.textMuted, size: 18);
        statusText = 'Sconosciuti';
        statusColor = colors.textMuted;
        break;
      case RecognitionStatus.error:
        statusIcon = Icon(Icons.error_outline_rounded, color: colors.error, size: 18);
        statusText = 'Errore';
        statusColor = colors.error;
        break;
      case RecognitionStatus.processing:
        statusIcon = SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
          ),
        );
        statusText = 'Analisi...';
        statusColor = colors.accent;
        break;
      case RecognitionStatus.idle:
        statusIcon = Icon(Icons.hourglass_empty_rounded, color: colors.textDisabled, size: 18);
        statusText = 'In attesa';
        statusColor = colors.textDisabled;
        break;
    }

    final hasDestination = item.status != RecognitionStatus.idle && item.status != RecognitionStatus.processing;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: JgSizes.space16, vertical: JgSizes.space12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(JgSizes.radiusSmall),
            ),
            child: Center(child: statusIcon),
          ),
          const SizedBox(width: JgSizes.space16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      item.fileName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.rotationDegrees != 0) ...[
                      const SizedBox(width: JgSizes.space8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Ruota +${item.rotationDegrees}°',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: colors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                if (hasDestination) ...[
                  Row(
                    children: [
                      Icon(Icons.arrow_forward_rounded, size: 13, color: colors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Destinazione: ',
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                      Expanded(
                        child: Text(
                          '${item.effectiveSubFolder}/${item.targetFileName}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: item.effectiveSubFolder == 'sconosciuti'
                                ? colors.textSecondary
                                : colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    'In attesa di analisi',
                    style: TextStyle(fontSize: 11, color: colors.textDisabled),
                  ),
                ],
                if (item.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.errorMessage!,
                    style: TextStyle(fontSize: 11, color: colors.error, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: JgSizes.space16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: JgSizes.space12, vertical: JgSizes.space4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
              border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              statusText.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugGridView(BuildContext context) {
    final colors = context.jgColors;
    final filteredItems = _getFilteredItems();
    final isWorking = _controller.isProcessing || _controller.isArchiving;

    final dynamicFilterSegments = {
      'all': 'Tutti (${_controller.totalCount})',
      'valid': 'Validi (${_controller.validCount})',
      'warning': 'Dubbi (${_controller.warningCount})',
      'unknown': 'Sconosciuti (${_controller.unknownCount})',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: colors.warning.withValues(alpha: 0.15),
          padding: const EdgeInsets.symmetric(horizontal: JgSizes.space16, vertical: JgSizes.space8),
          child: Row(
            children: [
              Icon(Icons.code_rounded, color: colors.warning, size: 18),
              const SizedBox(width: JgSizes.space8),
              Text(
                'MODALITÀ SVILUPPATORE ATTIVA',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.warning),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(JgSizes.space16, JgSizes.space12, JgSizes.space16, JgSizes.space8),
          child: JgGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: JgSizes.space16, vertical: JgSizes.space12),
            borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                final actionButtons = Wrap(
                  spacing: JgSizes.space8,
                  runSpacing: JgSizes.space8,
                  children: [
                    JgButton(
                      style: JgButtonStyle.glass,
                      controlSize: JgControlSize.small,
                      icon: const Icon(Icons.folder_open_rounded, size: 16),
                      onPressed: isWorking ? null : _pickFolder,
                      child: const Text('Seleziona cartella'),
                    ),
                    JgButton(
                      style: JgButtonStyle.primary,
                      controlSize: JgControlSize.small,
                      loading: _controller.isProcessing,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      onPressed: isWorking ? null : _startProcessing,
                      child: const Text('Organizza'),
                    ),
                    JgButton(
                      style: JgButtonStyle.glass,
                      controlSize: JgControlSize.small,
                      loading: _controller.isArchiving,
                      icon: const Icon(Icons.save_alt_rounded, size: 16),
                      onPressed: isWorking ? null : _executeArchiving,
                      child: const Text('Salva'),
                    ),
                  ],
                );

                final filterAndSelection = SizedBox(
                  width: 360,
                  child: JgSegmentedControl<String>(
                    selectedValue: _activeFilter,
                    children: dynamicFilterSegments,
                    onValueChanged: (val) => setState(() => _activeFilter = val),
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      actionButtons,
                      const Spacer(),
                      filterAndSelection,
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      actionButtons,
                      const SizedBox(height: JgSizes.space12),
                      filterAndSelection,
                    ],
                  );
                }
              },
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: isWorking
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: JgSizes.space16),
                      child: JgLinearProgress(
                        value: _controller.totalCount > 0
                            ? _controller.currentIndex / _controller.totalCount
                            : null,
                        strokeWidth: 4.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: JgSizes.space20, vertical: JgSizes.space8),
                      child: Text(
                        _controller.currentOperationText,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.accent),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(JgSizes.space16, JgSizes.space8, JgSizes.space16, JgSizes.space16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = 2;
                if (constraints.maxWidth > 1300) {
                  crossAxisCount = 4;
                } else if (constraints.maxWidth > 900) {
                  crossAxisCount = 3;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.74,
                    crossAxisSpacing: JgSizes.space12,
                    mainAxisSpacing: JgSizes.space12,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return DrawingCard(
                      key: ValueKey(item.id),
                      item: item,
                      controller: _controller,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = context.jgColors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(JgSizes.space24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: JgGlassContainer(
            padding: const EdgeInsets.all(JgSizes.space32),
            borderRadius: BorderRadius.circular(JgSizes.radiusXLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.style_outlined, size: 36, color: colors.accent),
                  ),
                ),
                const SizedBox(height: JgSizes.space20),
                Text(
                  'NESSUN DISEGNO CARICATO',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: JgSizes.space8),
                Text(
                  'Seleziona una cartella di scansioni o fotografie di calzature per iniziare il riconoscimento delle sigle, il raddrizzamento dell\'orientamento e l\'archiviazione organizzata.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: JgSizes.space24),
                JgButton(
                  style: JgButtonStyle.primary,
                  controlSize: JgControlSize.large,
                  icon: const Icon(Icons.folder_open_rounded, size: 20),
                  onPressed: _pickFolder,
                  child: const Text('Seleziona cartella'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
