import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';

class EditProfileRouteData {
  const EditProfileRouteData({
    required this.userData,
    required this.onboardingData,
  });
  final UserEntity userData;
  final OnboardingEntity onboardingData;
}
