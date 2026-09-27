part of 'receipt_scanner_cubit.dart';

sealed class ReceiptScannerState extends Equatable {
  const ReceiptScannerState();

  @override
  List<Object?> get props => [];
}

final class ReceiptScannerInitial extends ReceiptScannerState {}

class ScannerSuccess extends ReceiptScannerState {
  const ScannerSuccess(this.draft, {this.imagePath});
  final ScannedReceiptEntity draft;

  /// Local path of the scanned document image, when available.
  final String? imagePath;
  @override
  List<Object?> get props => [draft, imagePath];
}

class ScannerFailure extends ReceiptScannerState {
  const ScannerFailure(this.reason);
  final String reason;
  @override
  List<Object> get props => [reason];
}
