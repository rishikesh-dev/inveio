import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/onboarding/data/datasources/remote/onboarding_remote_data_source.dart';
import 'package:inveio/onboarding/data/models/onboarding_model.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Implementation of [OnboardingRepository] that combines local and remote data sources.
class OnboardingRepositoryImpl extends OnboardingRepository {
  final OnboardingLocalDataSource _local;
  final OnboardingRemoteDataSource _remote;

  /// Creates an [OnboardingRepositoryImpl] with the given local and remote sources.
  OnboardingRepositoryImpl({
    required OnboardingLocalDataSource local,
    required OnboardingRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  /// Saves onboarding data both remotely and locally, then marks onboarding complete.
  @override
  Future<Either<Failure, void>> saveOnboarding(OnboardingEntity data) async {
    try {
      final model = OnboardingModel.fromEntity(data);
      await _remote.saveOnboarding(model);
      await _local.saveBusinessName(data.businessName!);
      if (data.address != null) await _local.saveAddress(data.address!);
      if (data.logoPath != null) await _local.saveLogoPath(data.logoPath!);
      if (data.gstin != null) await _local.saveGstin(data.gstin!);
      if (data.gstinStatus != null) {
        await _local.saveGstinStatus(data.gstinStatus!.name);
      }
      if (data.stateCode != null) await _local.saveStateCode(data.stateCode!);
      if (data.workType != null) await _local.saveWorkType(data.workType!.name);
      await _local.markComplete();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Loads the persisted onboarding data, pulling from remote on first run.
  @override
  Future<Either<Failure, OnboardingEntity>> getOnboarding(String uid) async {
    try {
      await _syncFromRemoteIfNeeded(uid);
      return Right(await _readLocalEntity());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Checks whether the user has completed onboarding.
  @override
  Future<Either<Failure, bool>> isOnboardingComplete(String uid) async {
    try {
      await _syncFromRemoteIfNeeded(uid);
      return Right(_local.isComplete());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  /// Pulls onboarding data from the remote source when nothing is stored yet.
  Future<void> _syncFromRemoteIfNeeded(String uid) async {
    if (_local.isComplete()) return;
    final remoteData = await _remote.fetchOnboarding(uid);
    if (remoteData == null) return;
    await _local.saveBusinessName(remoteData.businessName ?? '');
    if (remoteData.address != null) {
      await _local.saveAddress(remoteData.address!);
    }
    if (remoteData.logoPath != null) {
      await _local.saveLogoPath(remoteData.logoPath!);
    }
    if (remoteData.gstin != null) {
      await _local.saveGstin(remoteData.gstin!);
    }
    if (remoteData.gstinStatus != null) {
      await _local.saveGstinStatus(remoteData.gstinStatus!.name);
    }
    if (remoteData.stateCode != null) {
      await _local.saveStateCode(remoteData.stateCode!);
    }
    if (remoteData.workType != null) {
      await _local.saveWorkType(remoteData.workType!);
    }
    await _local.markComplete();
  }

  /// Builds an [OnboardingEntity] from the locally persisted values.
  Future<OnboardingEntity> _readLocalEntity() async {
    final workTypeName = _local.getWorkType();
    final gstinStatusName = _local.getGstinStatus();
    return OnboardingEntity(
      businessName: _local.getBusinessName(),
      address: _local.getAddress(),
      logoPath: _local.getLogoPath(),
      gstin: _local.getGstin(),
      gstinStatus: gstinStatusName != null
          ? GstinStatus.values.byName(gstinStatusName)
          : null,
      workType: workTypeName != null
          ? WorkType.values.byName(workTypeName)
          : null,
      stateCode: await _local.getStateCode(),
      onboardingComplete: _local.isComplete(),
    );
  }

  /// Marks the onboarding flow as complete in local storage.
  @override
  Future<Either<Failure, void>> markComplete() async {
    try {
      await _local.markComplete();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
