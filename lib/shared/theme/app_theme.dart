import 'package:flutter/material.dart';
import 'app_dark_theme.dart';
import 'app_light_theme.dart';

/// Provides dark and light [ThemeData] configurations for the app.
///
/// Delegates to [AppDarkTheme] and [AppLightTheme] for the actual
/// theme definitions, keeping each file under 300 lines.
class AppTheme {
  /// Border radius used for text fields.
  static const textFieldBorderRadius = 12.0;

  /// Dark theme configuration.
  static ThemeData get dark => AppDarkTheme.dark;

  /// Light theme configuration.
  static ThemeData get light => AppLightTheme.light;
}
