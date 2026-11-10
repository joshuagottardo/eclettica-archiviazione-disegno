# Workspace Rules - JG Design System (`jg_design_system`)

You are an expert AI software engineer assisting in the development of or integration with `jg_design_system`. Read these rules carefully before writing or modifying any Flutter code in this repository.

---

## 🎨 Design Philosophy & Principles

The design system follows a **Swiss Minimalist** and **Glassmorphic Apple-style** aesthetic.
*   **Colors:** Deep Dark OLED blacks (`0xFF08080A`), bright minimalist whites, sharp neon accents, and high-transparency glass surfaces.
*   **Typography:** The standard font is [Inter], a clean geometric sans-serif. Swiss styling elements (such as didascalie and tags) must be small, semibold/bold, uppercase, and have wide letter spacing (typically `1.5` or higher).
*   **Geometry:** Rounded corners (mostly `radiusLarge` which is 20px, `radiusMedium` which is 12px, or `radiusCircular` which is 999px) and razor-thin hairlines (`0.5`px) for glass borders.

---

## 🚫 Key Coding Rules & Restrictions

### 1. No Hardcoded Colors or Sizes
*   **Colors:** Never use `Colors.black`, `Colors.white`, or arbitrary hex codes in widgets. Always retrieve colors dynamically from the theme extension using `context.jgColors` (which resolves to `JgColorTheme`).
    *   *Correct:* `context.jgColors.accent`
    *   *Correct:* `context.jgColors.background`
    *   *Incorrect:* `Theme.of(context).colorScheme.primary` (unless mapped)
    *   *Incorrect:* `Color(0xFF000000)`
*   **Dimensions/Paddings:** Always use tokens from [JgSizes](lib/src/foundations/jg_sizes.dart) or access them via the size theme extension `context.jgSizes`.
    *   *Correct:* `JgSizes.space16` or `context.jgSizes.borderRadiusLarge`

### 2. Mandatory Use of Custom Components
Do NOT use Flutter's default Material/Cupertino input controls or buttons. Use their `jg_design_system` equivalents:
*   Instead of `ElevatedButton` / `FilledButton` $\rightarrow$ Use [JgButton](lib/src/widgets/buttons/jg_button.dart).
*   Instead of `IconButton` $\rightarrow$ Use [JgIconButton](lib/src/widgets/buttons/jg_icon_button.dart).
*   Instead of `Switch` $\rightarrow$ Use [JgSwitch](lib/src/widgets/controls/jg_switch.dart).
*   Instead of `Checkbox` $\rightarrow$ Use [JgCheckbox](lib/src/widgets/controls/jg_checkbox.dart).
*   Instead of `Radio` $\rightarrow$ Use [JgRadioButton](lib/src/widgets/controls/jg_radio_button.dart).
*   Instead of `TextField` $\rightarrow$ Use [JgTextField](lib/src/widgets/inputs/jg_text_field.dart).
*   Instead of `Dialog` $\rightarrow$ Use `showJgDialog`.
*   Instead of `BottomSheet` $\rightarrow$ Use `showJgBottomSheet`.
*   Instead of `SnackBar` $\rightarrow$ Use `JgToast`.

### 3. Maintain Accessibility (`Semantics`)
Any custom interactive gesture area (such as a custom checkbox, radio button, or button) must be wrapped in a `Semantics` widget.
*   Configure: `button`, `checked`, `toggled`, `selected`, `enabled`, and the semantic `onTap` listener.
*   Do not let interactive elements be invisible to assistive screen readers (TalkBack / VoiceOver).

### 4. Optimize Backdrop Filters (Performance)
The Apple-style Glassmorphism utilizes expensive `BackdropFilter` widgets.
*   Always bind glass container backgrounds to `JgPerformance.lowPerformanceNotifier` using a `ValueListenableBuilder`.
*   When `lowPerformanceNotifier.value` is `true`, immediately set the blur coefficients to `0.0` and fall back to rendering a solid background (`context.jgColors.surface`) to save frame rendering budgets.

### 5. Responsive Scaffolding
*   Widescreen and multi-device support must be built around [JgResponsiveScaffold](lib/src/widgets/navigation/jg_responsive_scaffold.dart).
*   Do not write ad-hoc screen width builders for basic screen layouts. Pass your items and body structure to [JgResponsiveScaffold].

---

## 📦 Directory Structure & Imports

*   **Public API Export:** All design tokens, extensions, and widgets are exported in [jg_design_system.dart](lib/jg_design_system.dart). When working on application-level files (such as the `example`), always use `import 'package:jg_design_system/jg_design_system.dart';`.
*   **Folder Setup:**
    *   `lib/src/foundations/` $\rightarrow$ Atomic values (colors, sizing constants, typography creators).
    *   `lib/src/theme/` $\rightarrow$ ThemeExtension classes, standard Light/Dark ThemeData, and JgPerformance.
    *   `lib/src/widgets/` $\rightarrow$ Visual components grouped by category (buttons, cards, controls, feedback, inputs, navigation).
*   **Examples:** Refer to [main.dart](example/lib/main.dart) for full-suite implementation guidelines.
