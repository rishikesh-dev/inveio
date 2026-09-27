import 'package:equatable/equatable.dart';

/// The result of a GST calculation for a transaction.
class GstBreakdown extends Equatable {
  /// Whether this is an inter-state supply.
  final bool isInterState;

  /// Central GST component (intra-state only).
  final double cgst;

  /// State GST component (intra-state only).
  final double sgst;

  /// Integrated GST component (inter-state only).
  final double igst;

  /// The taxable amount the calculation was based on.
  final double taxableAmount;

  const GstBreakdown({
    required this.isInterState,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.taxableAmount,
  });

  @override
  List<Object?> get props => [isInterState, cgst, sgst, igst, taxableAmount];
}

/// Pure service that calculates the GST breakdown for a transaction.
///
/// Has no dependency on Isar, Firestore, or Bloc — fully unit-testable.
class GstCalculator {
  const GstCalculator();

  /// Calculates the GST breakdown for the given inputs.
  GstBreakdown calculate({
    required double taxableAmount,
    required String counterpartyGstin,
    required String? sellerStateCode,
    required double gstRate,
  }) {
    final isInterState = _isInterState(counterpartyGstin, sellerStateCode);
    final totalTax = taxableAmount * gstRate;

    return GstBreakdown(
      isInterState: isInterState,
      cgst: isInterState ? 0 : totalTax / 2,
      sgst: isInterState ? 0 : totalTax / 2,
      igst: isInterState ? totalTax : 0,
      taxableAmount: taxableAmount,
    );
  }

  bool _isInterState(String gstin, String? sellerStateCode) {
    if (gstin.length < 2) return false;
    if (sellerStateCode == null || sellerStateCode.length < 2) return false;
    return sellerStateCode.substring(0, 2) != gstin.substring(0, 2);
  }
}
