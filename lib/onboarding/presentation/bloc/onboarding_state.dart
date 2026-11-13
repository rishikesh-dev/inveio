part of 'onboarding_bloc.dart';

/// Base state for all onboarding-related states.

sealed class OnboardingState extends Equatable {
  /// The current onboarding entity data.
  final OnboardingEntity onboarding;

  /// Creates an [OnboardingState] with the given [onboarding] data.
  const OnboardingState(this.onboarding);

  @override
  /// The list of props used for equality comparison.
  List<Object?> get props => [onboarding];
}

/// State indicating the onboarding flow is idle and ready for input.
final class OnboardingInitial extends OnboardingState {
  /// Creates an [OnboardingInitial] state.
  const OnboardingInitial(super.onboarding);
}

/// State indicating onboarding status hasn't been checked yet.
/// Distinct from OnboardingInitial's "checked, currently false" meaning.
final class OnboardingUnknown extends OnboardingState {
  /// Creates an [OnboardingUnknown] state.
  const OnboardingUnknown(super.onboarding);
}

/// State indicating onboarding data is being saved.
final class OnboardingLoading extends OnboardingState {
  /// Creates an [OnboardingLoading] state.
  const OnboardingLoading(super.onboarding);
}

/// State indicating onboarding completed successfully.
final class OnboardingSuccess extends OnboardingState {
  /// Creates an [OnboardingSuccess] state.
  const OnboardingSuccess(super.onboarding);
}

/// State indicating an error occurred during onboarding.
final class OnboardingFailure extends OnboardingState {
  /// A description of the failure.
  final String message;

  /// Creates an [OnboardingFailure] with the given [message].
  const OnboardingFailure(super.onboarding, this.message);

  @override
  /// The list of props used for equality comparison.
  List<Object?> get props => [super.onboarding, message];
}
