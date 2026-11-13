part of 'receipt_scanner_cubit.dart';

sealed class ReceiptScannerState extends Equatable {
  const ReceiptScannerState();

  @override
  List<Object?> get props => [];
}

final class ReceiptScannerInitial extends ReceiptScannerState {}

class ScannerSuccess extends ReceiptScannerState {
  const ScannerSuccess(this.draft, {this.imagePath});
  final ParsedReceipt draft;

  /// Local path of the scanned document image, when available.
  final String? imagePath;

  /// Whether the scan found an amount that can prefill a form.
  ///
  /// A missing, zero or negative amount means there is nothing useful to open
  /// a form with; the caller should ask the user to retake or enter manually.
  bool get hasUsableAmount {
    final amount = draft.amount.value;
    return amount != null && amount > 0;
  }

  @override
  List<Object?> get props => [draft, imagePath];
}

class ScannerFailure extends ReceiptScannerState {
  const ScannerFailure(this.reason);
  final String reason;

  @override
  List<Object> get props => [reason];
}
