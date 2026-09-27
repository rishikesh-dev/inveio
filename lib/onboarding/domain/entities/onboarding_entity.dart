enum GstinStatus { yes, notYet }

enum WorkType { freelancer, consultant, business, contractor }

const _sentinel = Object();

class OnboardingEntity {
  final String? businessName;
  final String? gstin;
  final WorkType? workType;
  final String? stateCode;
  final GstinStatus? gstinStatus; // replaces isGstRegistered
  final bool onboardingComplete;

  const OnboardingEntity({
     this.businessName,
    this.gstin,
    this.workType,
    this.stateCode,
    this.gstinStatus,
    this.onboardingComplete = false,
  });

  const OnboardingEntity.empty()
    : businessName = '',
      gstin = null,
      workType = null,
      stateCode = null,
      gstinStatus = null,
      onboardingComplete = false;

  OnboardingEntity copyWith({
    String? businessName,
    Object? gstin = _sentinel,
    WorkType? workType,
    Object? stateCode = _sentinel,
    GstinStatus? gstinStatus,
    bool? onboardingComplete,
  }) {
    return OnboardingEntity(
      businessName: businessName ?? this.businessName,
      gstin: identical(gstin, _sentinel) ? this.gstin : gstin as String?,
      workType: workType ?? this.workType,
      stateCode: identical(stateCode, _sentinel)
          ? this.stateCode
          : stateCode as String?,
      gstinStatus: gstinStatus ?? this.gstinStatus,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }
}
