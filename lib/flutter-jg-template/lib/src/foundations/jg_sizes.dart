import 'package:flutter/material.dart';

/// Token di dimensioni, spaziature e raggi per il Design System [jg_design_system].
///
/// Si basa su una griglia geometrica rigida con incrementi a base 8/4
/// e definisce le proporzioni per layout ordinati e allineati.
class JgSizes {
  JgSizes._();

  // Spaziature e Padding (Griglia a Base 8)
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;
  static const double space96 = 96.0;

  // Raggi dei Bordi (Border Radius)
  // Lo stile svizzero ama la nettezza geometrica, mentre lo stile Apple usa angoli arrotondati precisi.
  static const double radiusNone = 0.0;      // Angolo retto
  static const double radiusSmall = 4.0;     // Angoli accennati (es. checkbox, tooltip)
  static const double radiusMedium = 8.0;    // Angoli standard (es. pulsanti, input)
  static const double radiusLarge = 12.0;    // Angoli ampi (es. piccole card)
  static const double radiusXLarge = 20.0;   // Arrotondamento glassmorfico (es. pannelli, card principali)
  static const double radiusCircular = 99.0; // Pulsanti pillola o avatar

  // Spessori dei Bordi
  static const double borderHairline = 0.5; // Bordo micro-sottile stile Apple
  static const double borderThin = 1.0;     // Bordo standard
  static const double borderThick = 2.0;    // Bordo marcato per stati attivi/focus

  // Parametri di Sfocatura (Blur)
  static const double blurGlass = 16.0;      // Sfocatura ottimale per il glassmorphism
  static const double blurBackground = 32.0; // Sfocatura pesante per sfondi sfumati

  // Helper per Padding predefiniti (EdgeInsets)
  static const EdgeInsets paddingSmall = EdgeInsets.all(space8);
  static const EdgeInsets paddingMedium = EdgeInsets.all(space16);
  static const EdgeInsets paddingLarge = EdgeInsets.all(space24);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: space16);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: space16);
}
