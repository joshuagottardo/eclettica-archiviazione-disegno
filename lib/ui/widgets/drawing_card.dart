import 'package:flutter/material.dart';
import 'package:jg_design_system/jg_design_system.dart';
import 'package:eclettica_archiviazione_disegni/models/drawing_item.dart';
import 'package:eclettica_archiviazione_disegni/state/drawing_batch_controller.dart';

/// Scheda di anteprima del singolo disegno (utilizzata in modalità sviluppatore).
class DrawingCard extends StatefulWidget {
  final DrawingItem item;
  final DrawingBatchController controller;

  const DrawingCard({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  State<DrawingCard> createState() => _DrawingCardState();
}

class _DrawingCardState extends State<DrawingCard> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.item.effectiveCode);
  }

  @override
  void didUpdateWidget(covariant DrawingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.effectiveCode != widget.item.effectiveCode) {
      _textController.text = widget.item.effectiveCode;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Color _getStatusColor(BuildContext context, RecognitionStatus status) {
    final colors = context.jgColors;
    switch (status) {
      case RecognitionStatus.valid:
        return colors.success;
      case RecognitionStatus.warning:
        return colors.warning;
      case RecognitionStatus.unknown:
        return colors.textMuted;
      case RecognitionStatus.error:
        return colors.error;
      case RecognitionStatus.processing:
        return colors.accent;
      case RecognitionStatus.idle:
        return colors.textDisabled;
    }
  }

  String _getStatusLabel(RecognitionStatus status) {
    switch (status) {
      case RecognitionStatus.valid:
        return 'VALIDO';
      case RecognitionStatus.warning:
        return 'DUBBIO';
      case RecognitionStatus.unknown:
        return 'SCONOSCIUTO';
      case RecognitionStatus.error:
        return 'ERRORE';
      case RecognitionStatus.processing:
        return 'ANALISI...';
      case RecognitionStatus.idle:
        return 'IN ATTESA';
    }
  }

  void _openZoomViewer(BuildContext context) {
    final colors = context.jgColors;
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(JgSizes.space24),
          child: JgGlassContainer(
            borderRadius: BorderRadius.circular(JgSizes.radiusXLarge),
            padding: const EdgeInsets.all(JgSizes.space20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.zoom_in_rounded, color: colors.accent, size: 20),
                      const SizedBox(width: JgSizes.space8),
                      Expanded(
                        child: Text(
                          widget.item.fileName,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      JgIconButton(
                        icon: const Icon(Icons.rotate_left_rounded),
                        isGlass: true,
                        size: 36,
                        onPressed: () {
                          widget.controller.rotateItem(widget.item.id, -90);
                          Navigator.of(ctx).pop();
                          _openZoomViewer(context);
                        },
                      ),
                      const SizedBox(width: JgSizes.space4),
                      JgIconButton(
                        icon: const Icon(Icons.rotate_right_rounded),
                        isGlass: true,
                        size: 36,
                        onPressed: () {
                          widget.controller.rotateItem(widget.item.id, 90);
                          Navigator.of(ctx).pop();
                          _openZoomViewer(context);
                        },
                      ),
                      const SizedBox(width: JgSizes.space8),
                      JgIconButton(
                        icon: const Icon(Icons.close_rounded),
                        isGlass: true,
                        size: 36,
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: JgSizes.space16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 5.0,
                        child: Center(
                          child: widget.item.thumbnailBytes != null
                              ? RotatedBox(
                                  quarterTurns: (widget.item.rotationDegrees % 360) ~/ 90,
                                  child: Image.memory(
                                    widget.item.thumbnailBytes!,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Icon(Icons.image_outlined, size: 64, color: colors.textDisabled),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final colors = context.jgColors;
    final statusColor = _getStatusColor(context, item.status);
    final statusLabel = _getStatusLabel(item.status);
    final quarterTurns = (item.rotationDegrees % 360) ~/ 90;

    return JgGlassContainer(
      borderRadius: BorderRadius.circular(JgSizes.radiusLarge),
      padding: const EdgeInsets.all(JgSizes.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Tooltip(
                message: item.errorMessage ?? statusLabel,
                child: JgBadge(
                  label: statusLabel,
                  style: JgBadgeStyle.glass,
                  customColor: statusColor,
                ),
              ),
              const Spacer(),
              JgIconButton(
                icon: const Icon(Icons.rotate_left_rounded),
                size: 32,
                iconSize: 18,
                isGlass: true,
                onPressed: () => widget.controller.rotateItem(item.id, -90),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '${item.rotationDegrees}°',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              JgIconButton(
                icon: const Icon(Icons.rotate_right_rounded),
                size: 32,
                iconSize: 18,
                isGlass: true,
                onPressed: () => widget.controller.rotateItem(item.id, 90),
              ),
            ],
          ),
          const SizedBox(height: JgSizes.space8),

          Expanded(
            child: GestureDetector(
              onTap: () => _openZoomViewer(context),
              child: MouseRegion(
                cursor: SystemMouseCursors.zoomIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(JgSizes.radiusMedium),
                    border: Border.all(color: colors.borderLight, width: 0.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: item.thumbnailBytes != null
                        ? RotatedBox(
                            quarterTurns: quarterTurns,
                            child: Image.memory(
                              item.thumbnailBytes!,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Icon(Icons.image_outlined, size: 40, color: colors.textDisabled),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: JgSizes.space8),

          Text(
            item.fileName,
            style: TextStyle(
              fontSize: 11,
              color: colors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: JgSizes.space8),

          JgTextField(
            controller: _textController,
            hintText: 'Sigla modello...',
            isGlass: true,
            controlSize: JgControlSize.small,
            prefixIcon: Icon(Icons.tag_rounded, size: 16, color: colors.accent),
            suffixIcon: item.isManuallyEdited
                ? Icon(Icons.edit_note_rounded, size: 18, color: colors.accent)
                : null,
            onChanged: (val) => widget.controller.updateItemCode(item.id, val),
          ),
          const SizedBox(height: JgSizes.space8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: JgSizes.space8, vertical: JgSizes.space8),
            decoration: BoxDecoration(
              color: (item.effectiveSubFolder == 'sconosciuti'
                      ? colors.surfaceCard
                      : colors.accent.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(JgSizes.radiusSmall),
              border: Border.all(
                color: (item.effectiveSubFolder == 'sconosciuti'
                    ? colors.border
                    : colors.accent.withValues(alpha: 0.3)),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.effectiveSubFolder == 'sconosciuti'
                      ? Icons.folder_special_rounded
                      : Icons.folder_rounded,
                  size: 14,
                  color: item.effectiveSubFolder == 'sconosciuti'
                      ? colors.textMuted
                      : colors.accent,
                ),
                const SizedBox(width: JgSizes.space8),
                Expanded(
                  child: Text(
                    '${item.effectiveSubFolder}/${item.targetFileName}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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
          ),
          if (item.status == RecognitionStatus.error && item.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                item.errorMessage!,
                style: TextStyle(fontSize: 10, color: colors.error),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
