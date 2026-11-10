import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fondamenta tipografiche per il Design System [jg_design_system].
///
/// Si basa sul font [Inter], un sans-serif geometrico e pulito
/// ideale per la leggibilità e la precisione tipografica svizzera.
class JgTypography {
  JgTypography._();

  // Famiglia di Font Principale
  static String get fontFamily => GoogleFonts.inter().fontFamily ?? 'Inter';

  /// Genera il [TextTheme] globale per l'applicazione.
  static TextTheme createTextTheme({
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
  }) {
    return TextTheme(
      // Display: Per grandi numeri o titoli monumentali da landing
      displayLarge: GoogleFonts.inter(
        fontSize: 40.0,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: -1.5,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32.0,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -1.0,
        color: textPrimary,
      ),

      // Headlines: Titoli di sezioni primarie
      headlineLarge: GoogleFonts.inter(
        fontSize: 24.0,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20.0,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18.0,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: textPrimary,
      ),

      // Titles: Intestazioni di card o elementi medi
      titleLarge: GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: textPrimary,
      ),

      // Body: Testi di lettura principali e secondari
      bodyLarge: GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textSecondary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: textMuted,
      ),

      // Labels: Pulsanti, badge, micro-didascalie tipicamente svizzere
      labelLarge: GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.2,
        color: textPrimary,
      ),
      // Didascalia svizzera: piccola, semibold, molto spaziata e tipicamente maiuscola
      labelSmall: GoogleFonts.inter(
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 1.5,
        color: textMuted,
      ),
    );
  }
}
