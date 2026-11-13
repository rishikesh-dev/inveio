import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/settings/domain/entities/app_settings.dart';
import 'package:inveio/settings/domain/repositories/app_settings_repository.dart';

/// Maps the domain [AppThemeMode] to Flutter's [ThemeMode].
extension AppThemeModeX on AppThemeMode {
  /// The Flutter [ThemeMode] equivalent of this value.
  ThemeMode get material => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  /// A human-readable label for this theme mode.
  String get label => switch (this) {
    AppThemeMode.system => 'System',
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
  };
}

/// Cubit that owns the app's [AppSettings] and persists theme changes.
class ThemeCubit extends Cubit<AppSettings> {
  final AppSettingsRepository _repository;

  /// Creates a [ThemeCubit] with the given [repository].
  ThemeCubit({required AppSettingsRepository repository})
    : _repository = repository,
      super(const AppSettings());

  /// Loads the persisted settings into the cubit.
  Future<void> load() async {
    final result = await _repository.getSettings();
    result.fold((_) {}, (settings) => emit(settings));
  }

  /// Updates and persists the selected theme [mode].
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (state.themeMode == mode) return;
    emit(state.copyWith(themeMode: mode));
    await _repository.saveThemeMode(mode);
  }
}
