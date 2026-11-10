import 'package:flutter/material.dart';
import '../../foundations/jg_control_size.dart';
import '../../foundations/jg_sizes.dart';
import '../../theme/extensions/jg_color_theme.dart';
import '../../theme/extensions/jg_sizes_theme.dart';
import '../feedback/jg_glass_container.dart';

/// Un campo di testo (Input) ultramoderno e geometrico.
///
/// Si integra nel design system offrendo due modalità: solida (superficie scura)
/// o glassmorfica. Gestisce l'animazione di transizione del bordo al focus.
class JgTextField extends StatefulWidget {
  /// Controller del testo.
  final TextEditingController? controller;

  /// Testo segnaposto (hint).
  final String? hintText;

  /// Etichetta posizionata sopra il campo (label).
  final String? labelText;

  /// Se impostato a true, nasconde il testo (es. per password).
  final bool obscureText;

  /// Tipo di tastiera da mostrare.
  final TextInputType keyboardType;

  /// Icona opzionale all'inizio del campo.
  final Widget? prefixIcon;

  /// Icona opzionale alla fine del campo (es. visibilità password).
  final Widget? suffixIcon;

  /// Callback invocato al cambio di testo.
  final ValueChanged<String>? onChanged;

  /// Validatore per l'uso all'interno di Form.
  final FormFieldValidator<String>? validator;

  /// FocusNode esterno opzionale.
  final FocusNode? focusNode;

  /// Se true, applica l'effetto vetro sfocato (Glassmorphism).
  final bool isGlass;

  /// Dimensione del controllo (small, medium, large). Default a [JgControlSize.medium].
  final JgControlSize controlSize;

  const JgTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.focusNode,
    this.isGlass = false,
    this.controlSize = JgControlSize.medium,
  });

  @override
  State<JgTextField> createState() => _JgTextFieldState();
}

class _JgTextFieldState extends State<JgTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  EdgeInsets _resolvePadding(JgControlSize size, JgSizesTheme theme) {
    switch (size) {
      case JgControlSize.small:
        return theme.textFieldPaddingSmall;
      case JgControlSize.medium:
        return theme.textFieldPaddingMedium;
      case JgControlSize.large:
        return theme.textFieldPaddingLarge;
    }
  }

  double _resolveBorderRadius(JgControlSize size, JgSizesTheme theme) {
    switch (size) {
      case JgControlSize.small:
        return theme.borderRadiusSmall;
      case JgControlSize.medium:
        return theme.borderRadiusMedium;
      case JgControlSize.large:
        return theme.borderRadiusLarge;
    }
  }

  double _resolveFontSize(JgControlSize size) {
    switch (size) {
      case JgControlSize.small:
        return 13.0;
      case JgControlSize.medium:
        return 15.0;
      case JgControlSize.large:
        return 17.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.jgColors;
    final sizesTheme = context.jgSizes;

    // Colori animati del bordo al focus
    final Color borderActiveColor = colors.accent;
    final Color borderIdleColor = widget.isGlass ? Colors.transparent : colors.border;

    final EdgeInsets padding = _resolvePadding(widget.controlSize, sizesTheme);
    final double radius = _resolveBorderRadius(widget.controlSize, sizesTheme);
    final double fontSize = _resolveFontSize(widget.controlSize);

    final Widget inputField = TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
      validator: widget.validator,
      cursorColor: colors.accent,
      style: textTheme.bodyLarge?.copyWith(
        color: colors.textPrimary,
        decorationThickness: 0,
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textMuted,
          fontSize: fontSize,
        ),
        prefixIcon: widget.prefixIcon != null
            ? IconTheme(
                data: IconThemeData(color: colors.textMuted),
                child: widget.prefixIcon!,
              )
            : null,
        suffixIcon: widget.suffixIcon != null
            ? IconTheme(
                data: IconThemeData(color: colors.textMuted),
                child: widget.suffixIcon!,
              )
            : null,
        border: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: padding,
      ),
    );

    // Contenitore esterno con bordo animato
    final Widget container = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutQuart,
      decoration: BoxDecoration(
        color: widget.isGlass ? Colors.transparent : colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: _hasFocus ? borderActiveColor : borderIdleColor,
          width: _hasFocus ? JgSizes.borderThick : JgSizes.borderThin,
        ),
      ),
      child: inputField,
    );

    final Widget finalField = widget.isGlass
        ? JgGlassContainer(
            borderRadius: BorderRadius.circular(radius),
            padding: EdgeInsets.zero,
            // Modifica il bordo del vetro se attivo
            borderGradient: _hasFocus
                ? LinearGradient(
                    colors: [colors.accent, colors.accent],
                  )
                : null,
            child: container,
          )
        : container;

    // Se c'è una labelText, la posizioniamo sopra l'input in modo rigido e allineato (stile svizzero)
    if (widget.labelText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: JgSizes.space4,
              bottom: JgSizes.space8,
            ),
            // Utilizzo di labelSmall per lo stile compatto maiuscolo svizzero
            child: Text(
              widget.labelText!.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: _hasFocus ? colors.accent : colors.textMuted,
              ),
            ),
          ),
          finalField,
        ],
      );
    }

    return finalField;
  }
}
