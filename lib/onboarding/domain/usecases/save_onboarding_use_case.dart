import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case that saves onboarding data through the repository.
class SaveOnboardingUseCase {
  final OnboardingRepository _repository;

  /// Creates a [SaveOnboardingUseCase] with the given [repository].
  SaveOnboardingUseCase({required OnboardingRepository repository})
    : _repository = repository;

  /// Executes the use case with the given onboarding [data].
  Future<Either<Failure, void>> call(OnboardingEntity data) async {
    return await _repository.saveOnboarding(data);
  }
}
