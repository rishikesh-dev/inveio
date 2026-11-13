import 'package:fpdart/fpdart.dart';
import 'package:inveio/settings/domain/entities/app_settings.dart';
import 'package:inveio/shared/errors/failure.dart';

/// Abstract repository for reading and writing app settings.
abstract class AppSettingsRepository {
  /// Loads the persisted app settings.
  Future<Either<Failure, AppSettings>> getSettings();

  /// Persists the selected theme mode.
  Future<Either<Failure, void>> saveThemeMode(AppThemeMode mode);
}
