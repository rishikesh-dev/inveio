import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract repository for onboarding persistence operations.
abstract class OnboardingRepository {
  /// Persists the given onboarding [data] to both remote and local storage.
  Future<Either<Failure, void>> saveOnboarding(OnboardingEntity data);

  /// Returns whether the user has completed the onboarding flow.
  Future<Either<Failure, bool>> isOnboardingComplete(String uid);

  /// Marks the onboarding flow as complete.
  Future<Either<Failure, void>> markComplete();
}
