import 'package:fpdart/fpdart.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/onboarding/domain/repositories/onboarding_repository.dart';

class CheckOnboardingStatusUseCase {
  final OnboardingRepository _repository;

  CheckOnboardingStatusUseCase({required OnboardingRepository repository})
    : _repository = repository;

  Future<Either<Failure, bool>> call(String uid) async {
    return await _repository.isOnboardingComplete(uid);
  }
}
