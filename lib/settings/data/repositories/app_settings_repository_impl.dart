import 'package:fpdart/fpdart.dart';
import 'package:inveio/settings/data/datasources/local/app_settings_local_data_source.dart';
import 'package:inveio/settings/domain/entities/app_settings.dart';
import 'package:inveio/settings/domain/repositories/app_settings_repository.dart';
import 'package:inveio/shared/errors/failure.dart';

/// Implementation of [AppSettingsRepository] backed by local storage.
class AppSettingsRepositoryImpl implements AppSettingsRepository {
  final AppSettingsLocalDataSource _local;

  /// Creates an [AppSettingsRepositoryImpl] with the given local source.
  AppSettingsRepositoryImpl({required AppSettingsLocalDataSource local})
    : _local = local;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      return Right(AppSettings(themeMode: _local.getThemeMode()));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveThemeMode(AppThemeMode mode) async {
    try {
      await _local.saveThemeMode(mode.name);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
