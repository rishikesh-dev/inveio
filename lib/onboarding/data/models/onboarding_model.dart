import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';

/// Data-layer model for onboarding information, convertible to/from JSON.
class OnboardingModel {
  /// The business name entered during onboarding.
  final String? businessName;

  /// The business address, or `null` if not provided.
  final String? address;

  /// Local path to the business logo, or `null` if not set.
  final String? logoPath;

  /// The GSTIN entered, or `null` if skipped.
  final String? gstin;

  /// The work type as a string, or `null` if not selected.
  final String? workType;

  /// The two-digit GST state code, or `null` if unknown.
  final String? stateCode;

  /// Whether the onboarding flow has been completed.
  final bool onboardingComplete;

  final GstinStatus? gstinStatus;

  /// Creates an [OnboardingModel] with the given fields.
  const OnboardingModel({
    required this.businessName,
    this.address,
    this.logoPath,
    this.gstin,
    this.gstinStatus,
    this.workType,
    this.stateCode,
    this.onboardingComplete = false,
  });

  /// Creates an [OnboardingModel] from a domain [OnboardingEntity].
  factory OnboardingModel.fromEntity(OnboardingEntity entity) {
    return OnboardingModel(
      businessName: entity.businessName,
      address: entity.address,
      logoPath: entity.logoPath,
      gstin: entity.gstin,
      gstinStatus: entity.gstinStatus,
      workType: entity.workType?.name,
      stateCode: entity.stateCode,
      onboardingComplete: entity.onboardingComplete,
    );
  }

  OnboardingEntity toEntity() {
    return OnboardingEntity(
      businessName: businessName,
      address: address,
      logoPath: logoPath,
      gstin: gstin,
      gstinStatus: gstinStatus,
      workType: workType != null ? WorkType.values.byName(workType!) : null,
      stateCode: stateCode,
      onboardingComplete: onboardingComplete,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'address': address,
      'logoPath': logoPath,
      'gstin': gstin,
      'gstinStatus': gstinStatus?.name,
      'workType': workType,
      'stateCode': stateCode,
      'onboardingComplete': onboardingComplete,
      'completedAt': DateTime.now().toIso8601String(),
    };
  }

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      businessName: json['businessName'] as String,
      address: json['address'] as String?,
      logoPath: json['logoPath'] as String?,
      gstin: json['gstin'] as String?,
      gstinStatus: json['gstinStatus'] != null
          ? GstinStatus.values.byName(json['gstinStatus'] as String)
          : null,
      workType: json['workType'] as String?,
      stateCode: json['stateCode'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
    );
  }
}
