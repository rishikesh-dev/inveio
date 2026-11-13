import 'package:inveio/settings/domain/entities/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for app settings, backed by SharedPreferences.
class AppSettingsLocalDataSource {
  final SharedPreferences _prefs;

  /// Creates an [AppSettingsLocalDataSource] with the given [prefs] instance.
  AppSettingsLocalDataSource({required SharedPreferences prefs})
    : _prefs = prefs;

  static const _themeModeKey = 'app_theme_mode';

  /// Returns the persisted theme mode, defaulting to [AppThemeMode.system].
  AppThemeMode getThemeMode() {
    final name = _prefs.getString(_themeModeKey);
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => AppThemeMode.system,
    );
  }

  /// Persists the theme mode [name].
  Future<void> saveThemeMode(String name) async {
    await _prefs.setString(_themeModeKey, name);
  }
}
