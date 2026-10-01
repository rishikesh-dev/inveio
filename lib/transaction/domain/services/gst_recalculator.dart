import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/transaction/domain/services/gst_calculator.dart';

/// Shared helper that recalculates a GST breakdown for a transaction form.
///
/// It combines [GstCalculator] with the persisted seller state code from
/// [OnboardingLocalDataSource] so that expense and invoice form cubits share a
/// single GST implementation (no duplicated GST code).
class GstRecalculator {
  GstRecalculator({
    required OnboardingLocalDataSource onboardingLocalDataSource,
    GstCalculator gstCalculator = const GstCalculator(),
    this.gstRate = 0.18,
  }) : _onboardingLocalDataSource = onboardingLocalDataSource,
       _gstCalculator = gstCalculator;

  final OnboardingLocalDataSource _onboardingLocalDataSource;
  final GstCalculator _gstCalculator;

  /// The GST slab rate applied to taxable amounts (default 18%).
  final double gstRate;

  /// The GST slab as an integer percentage (e.g. 18) derived from [gstRate].
  int get gstSlab => (gstRate * 100).round();

  /// Recomputes the [GstBreakdown] for the given [taxableAmount] and
  /// [counterpartyGstin] by reading the seller state code from onboarding.
  Future<GstBreakdown> recalculate({
    required double taxableAmount,
    required String counterpartyGstin,
  }) async {
    final sellerStateCode = await _onboardingLocalDataSource.getStateCode();
    return _gstCalculator.calculate(
      taxableAmount: taxableAmount,
      counterpartyGstin: counterpartyGstin,
      sellerStateCode: sellerStateCode,
      gstRate: gstRate,
    );
  }
}
