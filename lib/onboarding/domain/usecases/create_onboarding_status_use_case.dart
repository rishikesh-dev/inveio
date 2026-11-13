import 'package:fpdart/fpdart.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/domain/repositories/onboarding_repository.dart';

/// Use case that loads the onboarding status and persisted business details.
class CheckOnboardingStatusUseCase {
  final OnboardingRepository _repository;

  CheckOnboardingStatusUseCase({required OnboardingRepository repository})
    : _repository = repository;

  Future<Either<Failure, OnboardingEntity>> call(String uid) async {
    return await _repository.getOnboarding(uid);
  }
}
