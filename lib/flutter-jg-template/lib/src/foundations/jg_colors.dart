import 'package:flutter/material.dart';

/// Token di colore statici grezzi per il Design System [jg_design_system].
///
/// Definisce le tavolozze cromatiche di base sia per la modalità scura
/// profonda (OLED) sia per la modalità chiara (Swiss Minimal).
class JgColors {
  JgColors._();

  // --- PALETTE SCURA (DEEP DARK OLED) ---
  static const Color darkBackground = Color(0xFF08080A);
  static const Color darkSurface = Color(0xFF121216);
  static const Color darkSurfaceCard = Color(0xFF1A1A1E);
  static const Color darkAccent = Color(0xFFFFFFFF);
  static const Color darkAccentMuted = Color(0xFFF5F5F7);
  static const Color darkBorder = Color(0xFF24242A);
  static const Color darkBorderLight = Color(0xFF2E2E36);
  static const Color darkDivider = Color(0xFF1C1C1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xB3FFFFFF);
  static const Color darkTextMuted = Color(0xFF636366);
  static const Color darkTextDisabled = Color(0x3DFFFFFF);
  static const Color darkSuccess = Color(0xFF30D158);
  static const Color darkWarning = Color(0xFFFF9F0A);
  static const Color darkError = Color(0xFFFF453A);
  static const Color darkInfo = Color(0xFF0A84FF);
  static const Color darkGlassBackground = Color(0x0CFFFFFF);
  static const Color darkGlassBorderStart = Color(0x2BFFFFFF);
  static const Color darkGlassBorderEnd = Color(0x05FFFFFF);
  static const Color darkHoverOverlay = Color(0x0FFFFFFF);

  // --- PALETTE CHIARA (SWISS MINIMAL LIGHT) ---
  static const Color lightBackground = Color(0xFFF2F2F7); // Grigio chiaro iOS/Apple
  static const Color lightSurface = Color(0xFFFFFFFF);    // Bianco per le card rialzate
  static const Color lightSurfaceCard = Color(0xFFE5E5EA); // Grigio chiaro per card secondarie
  static const Color lightAccent = Color(0xFF000000);      // Nero puro per bottoni principali ed evidenziazioni
  static const Color lightAccentMuted = Color(0xFF1C1C1E);
  static const Color lightBorder = Color(0xFFE5E5EA);      // Linee di bordo morbide e visibili
  static const Color lightBorderLight = Color(0xFFD1D1D6); 
  static const Color lightDivider = Color(0xFFE5E5EA);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0x99000000); // ~60% nero
  static const Color lightTextMuted = Color(0xFF8E8E93);
  static const Color lightTextDisabled = Color(0x3D000000);  // ~24% nero
  static const Color lightSuccess = Color(0xFF24B147); // Verde saturo per fondi chiari
  static const Color lightWarning = Color(0xFFFF9500);
  static const Color lightError = Color(0xFFD32F2F);
  static const Color lightInfo = Color(0xFF007AFF);
  static const Color lightGlassBackground = Color(0xB2FFFFFF); // 70% bianco per contrasto e sfocatura visibile
  static const Color lightGlassBorderStart = Color(0x1F000000); // 12% nero per micro-bordo superiore inciso
  static const Color lightGlassBorderEnd = Color(0x05000000);   // 2% nero per micro-bordo inferiore
  static const Color lightHoverOverlay = Color(0x0A000000);
}
