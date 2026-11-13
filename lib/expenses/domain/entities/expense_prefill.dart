import 'package:equatable/equatable.dart';

/// Plain data holder used to prefill the expense form from a scanned receipt.
///
/// It lives in the expenses feature (and intentionally mirrors only the flat
/// fields we need) so that `ExpenseFormCubit` never depends on the `scan`
/// feature directly.
class ExpensePrefill extends Equatable {
  const ExpensePrefill({
    this.amount,
    this.gstin,
    this.vendorName,
    this.transactionDate,
  });

  /// Parsed printed total from the scan (tax-inclusive), when available.
  final double? amount;

  /// Extracted counterparty GSTIN, when available.
  final String? gstin;

  /// Extracted vendor/business name, when available.
  final String? vendorName;

  /// Parsed transaction date, when available.
  final DateTime? transactionDate;

  @override
  List<Object?> get props => [amount, gstin, vendorName, transactionDate];
}
