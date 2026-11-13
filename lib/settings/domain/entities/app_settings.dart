/// Available app theme modes, mirrored from Flutter's [ThemeMode] to keep the
/// domain layer framework-agnostic.
enum AppThemeMode { system, light, dark }

/// User-configurable application settings.
class AppSettings {
  /// The selected theme mode. Defaults to following the system setting.
  final AppThemeMode themeMode;

  /// Creates an [AppSettings] with the given [themeMode].
  const AppSettings({this.themeMode = AppThemeMode.system});

  /// Creates a copy of this [AppSettings] with the given fields replaced.
  AppSettings copyWith({AppThemeMode? themeMode}) {
    return AppSettings(themeMode: themeMode ?? this.themeMode);
  }
}
