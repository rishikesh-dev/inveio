part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  /// Creates an [OnboardingEvent].
  const OnboardingEvent();

  @override
  /// The list of props used for equality comparison.
  List<Object?> get props => [];
}

//Event dispatched to check the onboarding status.
class CheckOnboardingStatus extends OnboardingEvent {
  /// Creates a [CheckOnboardingStatus] event.
  final String? uid;
  const CheckOnboardingStatus(this.uid);
}

/// Event dispatched when the business name field changes.
final class BusinessNameChanged extends OnboardingEvent {
  /// The new business name value.
  final String name;

  /// Creates a [BusinessNameChanged] with the given [name].
  const BusinessNameChanged(this.name);

  @override
  /// The list of props used for equality comparison.
  List<Object?> get props => [name];
}

/// Event dispatched when the GSTIN field changes.
final class GstinChanged extends OnboardingEvent {
  /// The new GSTIN value.
  final String gstin;

  /// Creates a [GstinChanged] with the given [gstin].
  const GstinChanged(this.gstin);

  @override
  /// The list of props used for equality comparison.
  List<Object?> get props => [gstin];
}

/// Event dispatched when the business address changes.
final class BusinessAddressChanged extends OnboardingEvent {
  /// The new address value.
  final String address;

  /// Creates a [BusinessAddressChanged] with the given [address].
  const BusinessAddressChanged(this.address);

  @override
  /// The list of props used for equality comparison.
  List<Object?> get props => [address];
}

/// Event dispatched when the business logo path changes.
final class BusinessLogoChanged extends OnboardingEvent {
  /// The new logo path, or `null` when the logo is removed.
  final String? logoPath;

  /// Creates a [BusinessLogoChanged] with the given [logoPath].
  const BusinessLogoChanged(this.logoPath);

  @override
  /// The list of props used for equality comparison.
  List<Object?> get props => [logoPath];
}

/// Event dispatched when a work type is selected.
final class WorkTypeSelected extends OnboardingEvent {
  /// The selected [WorkType].
  final WorkType type;

  /// Creates a [WorkTypeSelected] with the given [type].
  const WorkTypeSelected(this.type);

  @override
  /// The list of props used for equality comparison.
  List<Object?> get props => [type];
}

/// Event dispatched when the onboarding form is submitted.
final class OnboardingSubmitted extends OnboardingEvent {
  /// Creates an [OnboardingSubmitted].
  const OnboardingSubmitted();
}

/// Event dispatched when the GST registration status is set.
final class GstRegistrationStatusSet extends OnboardingEvent {
  /// The selected GST registration status.
  final GstinStatus status;

  /// Creates a [GstRegistrationStatusSet] with the given [status].
  const GstRegistrationStatusSet(this.status);

  @override
  List<Object?> get props => [status];
}
