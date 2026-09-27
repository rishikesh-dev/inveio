import 'package:flutter/material.dart';

/// Predefined text styles used throughout the app.
class AppTextStyles {
  AppTextStyles._();

  /// Default font family used by all text styles.
  static const _font = 'Inter';

  /// Large display text (40pt, bold).
  static const displayLarge = TextStyle(
    fontFamily: _font,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.1,
  );

  /// Medium display text (32pt, bold).
  static const displayMedium = TextStyle(
    fontFamily: _font,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.15,
  );

  /// Large headline text (24pt, semi-bold).
  static const headlineLarge = TextStyle(
    fontFamily: _font,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Medium headline text (20pt, semi-bold).
  static const headlineMedium = TextStyle(
    fontFamily: _font,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// Small headline text (16pt, semi-bold).
  static const headlineSmall = TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  /// Large body text (15pt, regular).
  static const bodyLarge = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  /// Medium body text (13pt, regular).
  static const bodyMedium = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Small body text (12pt, regular).
  static const bodySmall = TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Large label text (13pt, medium weight).
  static const labelLarge = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Medium label text (11pt, medium weight).
  static const labelMedium = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.08,
  );

  /// Small label text (10pt, medium weight).
  static const labelSmall = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  /// Large monospace text (28pt, semi-bold) for amounts and codes.
  static const monoLarge = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );

  /// Medium monospace text (16pt, medium weight) for amounts.
  static const monoMedium = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Small monospace text (12pt, regular) for codes.
  static const monoSmall = TextStyle(
    fontFamily: 'IBMPlexMono',
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
