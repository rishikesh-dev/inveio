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
  ///
  /// [gstRate] overrides the default [gstRate] for this calculation.
  Future<GstBreakdown> recalculate({
    required double taxableAmount,
    required String counterpartyGstin,
    double? gstRate,
  }) async {
    final sellerStateCode = await _onboardingLocalDataSource.getStateCode();
    return _gstCalculator.calculate(
      taxableAmount: taxableAmount,
      counterpartyGstin: counterpartyGstin,
      sellerStateCode: sellerStateCode,
      gstRate: gstRate ?? this.gstRate,
    );
  }

  /// Recomputes the [GstBreakdown] when [totalAmount] already includes GST.
  ///
  /// The taxable value is rounded to the paisa, then the tax is derived as the
  /// remaining part of the inclusive total. Any odd paisa goes to SGST so the
  /// split always adds back to the original total exactly.
  Future<GstBreakdown> recalculateFromInclusiveTotal({
    required double totalAmount,
    required String counterpartyGstin,
    double? gstRate,
  }) async {
    final rate = gstRate ?? this.gstRate;
    final totalPaisa = (totalAmount * 100).round();
    final taxablePaisa = (totalPaisa / (1 + rate)).round();
    final taxPaisa = totalPaisa - taxablePaisa;
    final taxableAmount = taxablePaisa / 100;

    final breakdown = await recalculate(
      taxableAmount: taxableAmount,
      counterpartyGstin: counterpartyGstin,
      gstRate: rate,
    );

    if (breakdown.isInterState) {
      return GstBreakdown(
        isInterState: true,
        cgst: 0,
        sgst: 0,
        igst: taxPaisa / 100,
        taxableAmount: taxableAmount,
      );
    }

    final cgstPaisa = taxPaisa ~/ 2;
    final sgstPaisa = taxPaisa - cgstPaisa;
    return GstBreakdown(
      isInterState: false,
      cgst: cgstPaisa / 100,
      sgst: sgstPaisa / 100,
      igst: 0,
      taxableAmount: taxableAmount,
    );
  }
}
